package com.aliyun.aliinteraction.uikit.component;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.common.biz.exposable.enums.LiveStatus;
import com.alivc.auicommon.core.base.Actions;
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
 * 直播内容图层
 *
 * @author puke
 * @version 2021/7/30
 */
public class LiveContentLayerComponent extends RelativeLayout implements ComponentHolder {

    private final Component component = new Component();

    public LiveContentLayerComponent(@NonNull Context context) {
        this(context, null, 0);
    }

    public LiveContentLayerComponent(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveContentLayerComponent(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setClipChildren(false);
        this.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (component.needPlayback()) {
                    setVisibility(INVISIBLE);
                }
            }
        });
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
                // 观众身份, 一直显示该图层
                setVisibility(VISIBLE);
                return;
            }


            // 以下是主播逻辑
            setVisibility(GONE);
            liveService.addEventHandler(new SimpleLiveEventHandler() {
                @Override
                public void onPusherEvent(LiveEvent event, @Nullable Map<String, Object> extras) {
                    if (event == LiveEvent.PUSH_STARTED) {
                        setVisibility(View.VISIBLE);
                    }
                }
            });

            getMessageService().addMessageListener(new SimpleOnMessageListener() {
                @Override
                public void onStartLive(AUIMessageModel<StartLiveModel> message) {
                    setVisibility(VISIBLE);
                }
            });
        }

        @Override
        public void onEvent(String action, Object... args) {
            switch (action) {
                case Actions.SHOW_LIVE_MENU:
                    setVisibility(VISIBLE);
                    break;
                default:
                    break;
            }
        }
    }
}
