package com.aliyun.auipusherkit;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.common.biz.exposable.enums.LiveStatus;
import com.aliyun.aliinteraction.roompaas.message.listener.SimpleOnMessageListener;
import com.aliyun.aliinteraction.roompaas.message.model.StartLiveModel;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.auipusher.LiveContext;
import com.aliyun.auipusher.SimpleLiveEventHandler;
import com.aliyun.auipusher.config.LiveEvent;
import com.alivc.auimessage.model.base.AUIMessageModel;

import java.util.Map;

/**
 * 直播准备图层
 *
 * @author puke
 * @version 2021/7/30
 */
public class LiveReadyLayerComponent extends RelativeLayout implements ComponentHolder {

    private final Component component = new Component();

    public LiveReadyLayerComponent(@NonNull Context context) {
        this(context, null, 0);
    }

    public LiveReadyLayerComponent(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveReadyLayerComponent(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private class Component extends BaseComponent {
        @Override
        public void onInit(LiveContext liveContext) {
            super.onInit(liveContext);
            if (!isOwner() || needPlayback() || getLiveStatus() == LiveStatus.END) {
                // 观众身份 或者 观看直播回放, 都不显示该图层
                setVisibility(GONE);
                return;
            }

            // 以下是主播的开播逻辑
            setVisibility(VISIBLE);
            liveService.addEventHandler(new SimpleLiveEventHandler() {
                @Override
                public void onPusherEvent(LiveEvent event, @Nullable Map<String, Object> extras) {
                    if (event == LiveEvent.PUSH_STARTED) {
                        setVisibility(View.GONE);
                    }
                }
            });

            getMessageService().addMessageListener(new SimpleOnMessageListener() {
                @Override
                public void onStartLive(AUIMessageModel<StartLiveModel> message) {
                    setVisibility(GONE);
                }
            });
        }
    }
}
