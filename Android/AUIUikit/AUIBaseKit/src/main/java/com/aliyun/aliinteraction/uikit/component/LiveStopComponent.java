package com.aliyun.aliinteraction.uikit.component;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatImageView;

import com.alivc.auicommon.common.biz.exposable.enums.LiveStatus;
import com.alivc.auicommon.core.base.Actions;
import com.aliyun.aliinteraction.uikit.R;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.uibase.util.DialogUtil;
import com.aliyun.auiappserver.AppServerApi;
import com.aliyun.auiappserver.model.StopLiveRequest;
import com.aliyun.auipusher.LiveContext;
import com.aliyun.auipusher.SimpleLiveEventHandler;
import com.aliyun.auipusher.config.LiveEvent;
import com.alivc.auimessage.model.lwp.LeaveGroupRequest;

import java.util.Map;

/**
 * @author puke
 * @version 2021/7/29
 */
public class LiveStopComponent extends AppCompatImageView implements ComponentHolder {

    private static final int ORDER_STOP = 100;
    private static final String TAG = LiveStopComponent.class.getSimpleName();

    private final Component component = new Component();
    private boolean isFullViewStatus = false;

    public LiveStopComponent(@NonNull Context context) {
        this(context, null, 0);
    }

    public LiveStopComponent(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveStopComponent(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setImageResource(R.drawable.ilr_icon_close);

        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isFullViewStatus) {
                    component.postEvent(Actions.CHANGE_SMALL_MODE);
                    return;
                }
                component.handleCloseClick();
            }
        });
    }

    protected String getStopTips() {
        return "还有观众正在路上，确定要结束直播吗？";
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private class Component extends BaseComponent {
        @Override
        public void onInit(final LiveContext liveContext) {
            super.onInit(liveContext);

            liveService.addEventHandler(new SimpleLiveEventHandler() {
                @Override
                public void onPusherEvent(LiveEvent event, @Nullable Map<String, Object> extras) {
                    if (event == LiveEvent.PUSH_STARTED) {
                        liveContext.setPushing(true);
                    }
                }
            });
        }

        private void handleCloseClick() {
            activity.onBackPressed();
        }

        @Override
        public boolean interceptBackKey() {
            readyStop();
            // 拦截所有back操作
            return true;
        }

        private void readyStop() {
            // 是主播身份, 且正在推流, 则需要弹窗
            if (isOwner()) {
                if (getLiveStatus() == LiveStatus.END) {
                    doStop(true);
                } else {
                    DialogUtil.showCustomDialog(getContext(), getStopTips(), new Runnable() {
                        @Override
                        public void run() {
                            doStop(true);
                        }
                    }, null);
                }
            } else {
                doStop(false);
            }
        }

        private void doStop(boolean stopLive) {
            if (stopLive) {
                // 媒体
                liveService.getPusherService().stopLive(null);
                // IMSDK
                getMessageService().stopLive(null);
                // AppServer
                StopLiveRequest request = new StopLiveRequest();
                request.id = liveContext.getLiveId();
                request.userId = getUserId();
                AppServerApi.instance().stopLive(request).invoke(null);
            }
            if (isOwner() && !needPlayback()) {
                liveService.getPusherService().destroy();
            } else {
                getPlayerService().destroy();
            }

            LeaveGroupRequest request = new LeaveGroupRequest();
            request.groupId = getGroupId();
            getMessageService().getMessageService().leaveGroup(request, null);

            activity.finish();
        }

        @Override
        public int getOrder() {
            // 后置回调的优先级, 保证最后处理 interceptBackKey 事件
            return ORDER_STOP;
        }

        @Override
        public void onEvent(String action, Object... args) {
            switch (action) {
                case Actions.ENTER_ENTERPRISE:
                    setImageResource(R.drawable.back_arrow);
                    break;
                case Actions.IMMERSIVE_PLAYER:
                    if (args[0].equals(true)) {
                        setVisibility(View.GONE);
                    } else {
                        setVisibility(View.VISIBLE);
                    }
                    break;
                case Actions.CHANGE_SMALL_MODE:
                    isFullViewStatus = false;
                    break;
                case Actions.CHANGE_FULL_MODE:
                    isFullViewStatus = true;
                    break;
                default:
                    break;
            }
        }
    }
}
