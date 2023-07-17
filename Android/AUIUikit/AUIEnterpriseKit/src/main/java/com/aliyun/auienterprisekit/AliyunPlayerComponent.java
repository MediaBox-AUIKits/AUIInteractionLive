package com.aliyun.auienterprisekit;

import android.content.Context;
import android.content.res.Configuration;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.common.biz.exposable.enums.LiveStatus;
import com.alivc.auicommon.core.base.Actions;
import com.aliyun.aliinteraction.player.LivePlayerService;
import com.aliyun.aliinteraction.player.exposable.CanvasScale;
import com.aliyun.aliinteraction.roompaas.message.listener.SimpleOnMessageListener;
import com.aliyun.aliinteraction.roompaas.message.model.StartLiveModel;
import com.aliyun.aliinteraction.roompaas.message.model.StopLiveModel;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.uibase.util.AppUtil;
import com.aliyun.auiappserver.ThreadUtil;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auipusher.LiveContext;
import com.alivc.auimessage.model.base.AUIMessageModel;

public class AliyunPlayerComponent extends FrameLayout implements ComponentHolder {
    private final Component component = new Component();
    /**
     * 播放View
     */
    public AliyunPlayerView mAliyunPlayerView;
    public RelativeLayout mBottomLayout;
    private RelativeLayout mContainLayout;
    private int countClicked = 1;
    private ImageView shadow;//阴影
    private RelativeLayout playbackRenderBg;
    private ImageView playBackImage;
    private TextView playBackText;
    private boolean isLive = false;//是否开播中

    public AliyunPlayerComponent(@NonNull Context context) {
        this(context, null, 0);
    }

    public AliyunPlayerComponent(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public AliyunPlayerComponent(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        inflate(context, R.layout.ilr_player_layout, this);
        mAliyunPlayerView = findViewById(R.id.video_view);
        playbackRenderBg = findViewById(R.id.playback_render_bg);
        playBackText = findViewById(R.id.play_back_tv);
        playBackImage = findViewById(R.id.play_back_image);
        shadow = findViewById(R.id.shadow);
        mContainLayout = findViewById(R.id.contain_layout);
        mContainLayout.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (component.getLiveStatus().equals(LiveStatus.NOT_START) && !isLive) {
                    return;
                }
                countClicked++;
                if (countClicked % 2 == 0) {
                    component.postEvent(Actions.IMMERSIVE_PLAYER, true);
                    shadow.setVisibility(View.GONE);
                } else {
                    component.postEvent(Actions.IMMERSIVE_PLAYER, false);
                    shadow.setVisibility(View.VISIBLE);
                }
            }
        });
        mBottomLayout = findViewById(R.id.bottom_layout);
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private void updatePlayerViewMode() {
        if (mAliyunPlayerView != null) {
            int orientation = getResources().getConfiguration().orientation;
            //转为竖屏了。
            if (orientation == Configuration.ORIENTATION_PORTRAIT) {
                //设置view的布局，宽高之类
                RelativeLayout.LayoutParams aliVcVideoViewLayoutParams = (RelativeLayout.LayoutParams) mAliyunPlayerView.getLayoutParams();
                aliVcVideoViewLayoutParams.height = ViewGroup.LayoutParams.MATCH_PARENT;
                aliVcVideoViewLayoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT;
                RelativeLayout.LayoutParams aliViewLayoutParams = (RelativeLayout.LayoutParams) mContainLayout.getLayoutParams();
                aliViewLayoutParams.height = ViewGroup.LayoutParams.MATCH_PARENT;
                aliViewLayoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT;

            } else if (orientation == Configuration.ORIENTATION_LANDSCAPE) {
                //设置view的布局，宽高
                RelativeLayout.LayoutParams aliVcVideoViewLayoutParams = (RelativeLayout.LayoutParams) mAliyunPlayerView.getLayoutParams();
                aliVcVideoViewLayoutParams.height = AppUtil.dp(210);
                aliVcVideoViewLayoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT;
                RelativeLayout.LayoutParams aliViewLayoutParams = (RelativeLayout.LayoutParams) mContainLayout.getLayoutParams();
                aliViewLayoutParams.height = AppUtil.dp(210);
                aliViewLayoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT;
            }
        }
    }

    private class Component extends BaseComponent {


        @Override
        public void onInit(LiveContext liveContext) {
            super.onInit(liveContext);
            getMessageService().addMessageListener(new SimpleOnMessageListener() {
                @Override
                public void onStartLive(AUIMessageModel<StartLiveModel> message) {
                    // 观众监听到直播开始时, 开始尝试拉流
                    if (!isOwner()) {
                        ThreadUtil.postUiDelay(2000, new Runnable() {
                            @Override
                            public void run() {//暂时delay，保证拉流可以拉到
                                tryPlayLive();
                            }
                        });
                    }
                    isLive = true;
                }


                @Override
                public void onStopLive(AUIMessageModel<StopLiveModel> message) {
                    if (!isOwner()) {
                        getPlayerService().stopPlay();
                    }
                    mAliyunPlayerView.setVisibility(View.INVISIBLE);
                    playbackRenderBg.setVisibility(View.VISIBLE);
                    playBackText.setVisibility(View.GONE);
                    playBackImage.setVisibility(View.GONE);
                    isLive = false;
                }
            });

        }

        @Override
        public void onEvent(String action, Object... args) {
            switch (action) {
                case Actions.CHANGE_SMALL_MODE:
                case Actions.CHANGE_FULL_MODE:
                    mAliyunPlayerView.changeScreenMode();
                    updatePlayerViewMode();
                    break;
                default:
                    break;
            }
        }


        @Override
        public void onEnterRoomSuccess(LiveModel liveModel) {
            mAliyunPlayerView.setKeepScreenOn(true);
            component.postEvent(Actions.ENTER_ENTERPRISE);
            if (needPlayback()) {
                playbackRenderBg.setVisibility(View.VISIBLE);
                playbackRenderBg.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        // 回放逻辑
                        LivePlayerService playerService = getPlayerService();
                        // 设置显示模式
                        playerService.setViewContentMode(CanvasScale.Mode.SCALE_FILL);
                        String playUrl = getPlaybackUrl();
                        SurfaceView surfaceView = playerService.playUrl(playUrl);
                        mAliyunPlayerView.createRenderView(surfaceView);
                        playbackRenderBg.setVisibility(View.GONE);
                        component.postEvent(Actions.PLAYBACK_MESSAGE);
                    }
                });
            } else {
                tryPlayLive();
            }
        }

        private void tryPlayLive() {
            LivePlayerService playerService = getPlayerService();
            // 设置显示模式
            playerService.setViewContentMode(CanvasScale.Mode.SCALE_FILL);
            String playUrl;
            LiveModel liveModel = liveService.getLiveModel();
            String cdnPullUrl = liveModel.getCdnPullUrl();
            if (!TextUtils.isEmpty(cdnPullUrl)) {
                playUrl = cdnPullUrl;
            } else {
                playUrl = liveModel.getPullUrl();
            }
            SurfaceView surfaceView = playerService.playUrl(playUrl);
            mAliyunPlayerView.removeAllViews();
            mAliyunPlayerView.createRenderView(surfaceView);
        }
    }
}
