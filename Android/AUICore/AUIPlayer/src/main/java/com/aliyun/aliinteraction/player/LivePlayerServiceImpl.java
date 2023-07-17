package com.aliyun.aliinteraction.player;

import android.content.Context;
import android.view.SurfaceView;

import com.alivc.auicommon.common.base.EventHandler;
import com.alivc.auicommon.common.base.EventHandlerManager;
import com.alivc.auicommon.common.base.log.Logger;
import com.alivc.auicommon.common.base.network.NetworkAvailableManager;
import com.alivc.auicommon.common.base.network.OnNetworkAvailableChangeListener;
import com.aliyun.aliinteraction.player.exposable.CanvasScale;
import com.aliyun.player.bean.ErrorInfo;

public class LivePlayerServiceImpl extends EventHandlerManager<LivePlayerEventHandler> implements LivePlayerService {

    private static final String TAG = LivePlayerServiceImpl.class.getSimpleName();

    private final Context context;

    private LivePlayerManager livePlayerManager;
    private int maxRetryPlayCount = 3;
    private int retryPlayCount;
    // 该变量用来判断, 在监听到断流重连时是否需要刷新播放
    private boolean needPlay = false;

    private final OnNetworkAvailableChangeListener availableChangeListener = new OnNetworkAvailableChangeListener() {
        @Override
        public void onNetworkAvailableChanged(boolean available) {
            // 网络恢复时, 刷新播放器
            if (available && livePlayerManager != null && isNeedPlay()) {
                refreshPlay();
            }
        }
    };

    public LivePlayerServiceImpl(final Context context) {
        this.context = context;
        NetworkAvailableManager.instance().register(availableChangeListener);
    }

    private void retryPlay() {
        if (retryPlayCount++ < maxRetryPlayCount) {
            refreshPlay();
        }
    }

    @Override
    public void refreshPlay() {
        setNeedPlay(true);
        getOrCreatePlayerManager().stopPlay();
        getOrCreatePlayerManager().preparePlay();
    }

    @Override
    public void resumePlay() {
        Logger.i(TAG, "resumePlay");
        setNeedPlay(true);
        getOrCreatePlayerManager().startPlay();
    }

    @Override
    public void pausePlay() {
        Logger.i(TAG, "pausePlay");
        setNeedPlay(false);
        getOrCreatePlayerManager().pausePlay();
    }

    @Override
    public void stopPlay() {
        Logger.i(TAG, "stopPlay");
        setNeedPlay(false);
        if (livePlayerManager != null) {
            livePlayerManager.stopPlay();
        }
    }

    @Override
    public void setMutePlay(boolean mute) {
        getOrCreatePlayerManager().setMute(mute);
    }

    @Override
    public SurfaceView playUrl(String url) {
        setNeedPlay(true);
        return getOrCreatePlayerManager().startPlay(url);
    }

    @Override
    public void setViewContentMode(@CanvasScale.Mode int mode) {
        getOrCreatePlayerManager().setViewContentMode(mode);
    }

    @Override
    public void updatePositionTimerInternalMs(long internal) {
        getOrCreatePlayerManager().updatePositionTimerInternalMs(internal);
    }

    @Override
    public void setUtcTimeListener(LivePlayerManager.UtcTimeListener utcTimeListener) {
        getOrCreatePlayerManager().setUtcTimeListener(utcTimeListener);
    }

    @Override
    public void seekTo(long position) {
        getOrCreatePlayerManager().seekTo(position);
    }

    @Override
    public long getDuration() {
        return getOrCreatePlayerManager().getDuration();
    }

    @Override
    public void setPlayerConfig(AliLivePlayerConfig playerConfig) {
        if (playerConfig != null) {
            maxRetryPlayCount = playerConfig.networkRetryCount;
        }
        getOrCreatePlayerManager().setPlayerConfig(playerConfig);
    }

    @Override
    public void destroy() {
        // 离开房间，上报离开直播
        if (livePlayerManager != null) {
            livePlayerManager.destroy();
        }
        setNeedPlay(false);
        retryPlayCount = 0;
        NetworkAvailableManager.instance().unregister(availableChangeListener);
    }

    public boolean isNeedPlay() {
        return needPlay;
    }

    private void setNeedPlay(boolean needPlay) {
        this.needPlay = needPlay;
    }

    // 懒加载处理, 使用时再获取
    private LivePlayerManager getOrCreatePlayerManager() {
        if (livePlayerManager == null) {
            livePlayerManager = new LivePlayerManager(context);
            bindPlayerManagerListener(livePlayerManager);
        }
        return livePlayerManager;
    }

    private void bindPlayerManagerListener(final LivePlayerManager playerManager) {
        playerManager.setCallback(new LivePlayerManager.Callback() {
            @Override
            public void onRtsPlayerError() {
                // RTS播放失败，downgrade 降级策略
                Logger.d(TAG, "RTS play error");
                // 移除rtc播放失败后的降低逻辑, 对齐iOS端
                retryPlay();
            }

            @Override
            public void onPlayerHttpRangeError() {
                // Http range error
                Logger.d(TAG, "aliPlayer error network http range.");
                retryPlay();
            }
        });

        playerManager.clearEventHandler();
        playerManager.addEventHandler(new EventHandler<PlayerEvent>() {
            @Override
            public void onEvent(PlayerEvent event, final Object obj) {
                switch (event) {
                    case RENDER_START:
                        LivePlayerServiceImpl.this.dispatch(new Consumer<LivePlayerEventHandler>() {
                            @Override
                            public void consume(LivePlayerEventHandler livePlayerEventHandler) {
                                livePlayerEventHandler.onRenderStart();
                            }
                        });
                        break;
                    case PLAYER_LOADING_BEGIN:
                        LivePlayerServiceImpl.this.dispatch(new Consumer<LivePlayerEventHandler>() {
                            @Override
                            public void consume(LivePlayerEventHandler livePlayerEventHandler) {
                                livePlayerEventHandler.onLoadingBegin();
                            }
                        });
                        break;
                    case PLAYER_LOADING_PROGRESS:
                        if (obj instanceof Integer) {
                            LivePlayerServiceImpl.this.dispatch(new Consumer<LivePlayerEventHandler>() {
                                @Override
                                public void consume(LivePlayerEventHandler eventHandler) {
                                    eventHandler.onLoadingProgress((Integer) obj);
                                }
                            });
                        }
                        break;
                    case PLAYER_LOADING_END:
                        LivePlayerServiceImpl.this.dispatch(new Consumer<LivePlayerEventHandler>() {
                            @Override
                            public void consume(LivePlayerEventHandler livePlayerEventHandler) {
                                livePlayerEventHandler.onLoadingEnd();
                            }
                        });
                        break;
                    case PLAYER_ERROR:
                        LivePlayerServiceImpl.this.dispatch(new Consumer<LivePlayerEventHandler>() {
                            @Override
                            public void consume(LivePlayerEventHandler livePlayerEventHandler) {
                                livePlayerEventHandler.onPlayerError();
                            }
                        });
                        break;
                    case PLAYER_ERROR_RAW:
                        if (obj instanceof ErrorInfo) {
                            LivePlayerServiceImpl.this.dispatch(new Consumer<LivePlayerEventHandler>() {
                                @Override
                                public void consume(LivePlayerEventHandler eventHandler) {
                                    eventHandler.onPlayerError((ErrorInfo) obj);
                                }
                            });
                        }
                        break;
                    case PLAYER_PREPARED:
                        // 重置重试次数
                        retryPlayCount = 0;
                        LivePlayerServiceImpl.this.dispatch(new Consumer<LivePlayerEventHandler>() {
                            @Override
                            public void consume(LivePlayerEventHandler livePlayerEventHandler) {
                                livePlayerEventHandler.onPrepared();
                            }
                        });
                        break;
                    case PLAYER_END:
                        LivePlayerServiceImpl.this.dispatch(new Consumer<LivePlayerEventHandler>() {
                            @Override
                            public void consume(LivePlayerEventHandler livePlayerEventHandler) {
                                livePlayerEventHandler.onPlayerEnd();
                            }
                        });
                        break;
                    case CURRENT_POSITION:
                        LivePlayerServiceImpl.this.dispatch(new Consumer<LivePlayerEventHandler>() {
                            @Override
                            public void consume(LivePlayerEventHandler eventHandler) {
                                eventHandler.onPlayerCurrentPosition((Long) obj);
                            }
                        });
                        break;
                    case BUFFERED_POSITION:
                        LivePlayerServiceImpl.this.dispatch(new Consumer<LivePlayerEventHandler>() {
                            @Override
                            public void consume(LivePlayerEventHandler eventHandler) {
                                eventHandler.onPlayerBufferedPosition((Long) obj);
                            }
                        });
                        break;
                    case PLAYER_VIDEO_SIZE:
                        LivePlayerManager.VideoSize videoSize = (LivePlayerManager.VideoSize) obj;
                        final int width = videoSize.width;
                        final int height = videoSize.height;
                        // 外部回调
                        LivePlayerServiceImpl.this.dispatch(new Consumer<LivePlayerEventHandler>() {
                            @Override
                            public void consume(LivePlayerEventHandler eventHandler) {
                                eventHandler.onPlayerVideoSizeChanged(width, height);
                            }
                        });
                        break;
                    case PLAYER_STATUS_CHANGE:
                        final int status = (Integer) obj;
                        LivePlayerServiceImpl.this.dispatch(new Consumer<LivePlayerEventHandler>() {
                            @Override
                            public void consume(LivePlayerEventHandler eventHandler) {
                                eventHandler.onPlayerStatusChange(status);
                            }
                        });
                        Logger.i(TAG, "PLAYER_STATUS_CHANGE, status = " + status);
                        break;
                    case PLAYER_DOWNLOAD_SPEED_CHANGE:
                        final long downloadSpeed = (long) obj;
                        LivePlayerServiceImpl.this.dispatch(new Consumer<LivePlayerEventHandler>() {
                            @Override
                            public void consume(LivePlayerEventHandler eventHandler) {
                                eventHandler.onPlayerDownloadSpeedChanged(downloadSpeed);
                            }
                        });
                        break;
                }
            }
        });
    }
}
