package com.aliyun.auipusherkit;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.common.base.network.NetworkAvailableManager;
import com.alivc.auicommon.common.base.network.OnNetworkAvailableChangeListener;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.uibase.util.DialogUtil;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auipusher.LiveContext;
import com.aliyun.auipusher.SimpleLiveEventHandler;
import com.aliyun.auipusher.config.LiveEvent;

import java.util.Map;

/**
 * 直播推流状态视图<hr>
 *
 * @author puke
 * @version 2021/9/29
 */
public class LivePusherStatusComponent extends LinearLayout implements ComponentHolder {

    private final Component component = new Component();

    private final View networkIcon;
    private final TextView networkText;

    private boolean needShowRetryDialog;
    private boolean isDialogShowing;

    private final OnNetworkAvailableChangeListener networkChangeListener = new OnNetworkAvailableChangeListener() {

        @Override
        public void onNetworkAvailableChanged(boolean available) {
            onNetworkChanged(available);
        }
    };

    public LivePusherStatusComponent(@NonNull Context context) {
        this(context, null, 0);
    }

    public LivePusherStatusComponent(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LivePusherStatusComponent(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setVisibility(GONE);
        setOrientation(LinearLayout.HORIZONTAL);
        inflate(context, R.layout.ilr_view_pusher_status, this);
        networkIcon = findViewById(R.id.network_icon);
        networkText = findViewById(R.id.network_text);

        NetworkAvailableManager.instance().register(networkChangeListener);
    }

    protected void showRetryDialog(String message) {
        if (isDialogShowing || !component.isOwner()) {
            // 不重复弹窗, 观众不弹窗
            return;
        }

        isDialogShowing = true;
        DialogUtil.confirm(getContext(), message,
                new Runnable() {
                    @Override
                    public void run() {
                        isDialogShowing = false;
                        // 通知Loading组件显示加载状态
                        component.postEvent(LiveLoadingComponent.ACTION_SHOW_LOADING);
                        // 尝试重连
                        // component.getPusherService().restartLive();
                    }
                },
                new Runnable() {
                    @Override
                    public void run() {
                        isDialogShowing = false;
                    }
                }
        );
    }

    protected void onNetworkChanged(boolean available) {
        // 网络 不可用=>可用 时, 弹窗重试
        if (available && needShowRetryDialog) {
            showRetryDialog("检测到您的网络已恢复，是否恢复推流");
        }
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private class Component extends BaseComponent {
        @Override
        public void onInit(LiveContext liveContext) {
            super.onInit(liveContext);
            setVisibility(GONE);
            liveService.addEventHandler(new SimpleLiveEventHandler() {
                @Override
                public void onPusherEvent(LiveEvent event, @Nullable Map<String, Object> extras) {
                    switch (event) {
                        case NETWORK_RECOVERY:
                        case RECONNECT_SUCCESS:
                        case FIRST_FRAME_PUSHED:
                            needShowRetryDialog = false;
                            networkIcon.setBackgroundResource(R.drawable.ilr_bg_network_status_good);
                            networkText.setText("网络良好");
                            break;
                        case NETWORK_POOR:
                            networkIcon.setBackgroundResource(R.drawable.ilr_bg_network_status_pool);
                            networkText.setText("网络不佳");
                            break;
                        case RECONNECT_START:
                            needShowRetryDialog = false;
                            networkIcon.setBackgroundResource(R.drawable.ilr_bg_network_status_disconnect);
                            networkText.setText("网络异常");
                            break;
                        case CONNECTION_FAIL:
                        case RECONNECT_FAIL:
                            needShowRetryDialog = true;
                            networkIcon.setBackgroundResource(R.drawable.ilr_bg_network_status_disconnect);
                            networkText.setText("网络异常");
                            showRetryDialog("直播中断，请检查网络状态后重试");
                            break;
                    }
                }
            });
        }

        @Override
        public void onEnterRoomSuccess(LiveModel liveModel) {
            setVisibility(isOwner() ? VISIBLE : GONE);
        }

        @Override
        public void onActivityDestroy() {
            NetworkAvailableManager.instance().unregister(networkChangeListener);
        }
    }
}
