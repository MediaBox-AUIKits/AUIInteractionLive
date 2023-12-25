package com.aliyun.aliinteraction.uikit.component;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;

import com.alivc.auimessage.model.base.AUIMessageModel;
import com.aliyun.aliinteraction.player.SimpleLivePlayerEventHandler;
import com.aliyun.aliinteraction.roompaas.message.listener.SimpleOnMessageListener;
import com.aliyun.aliinteraction.roompaas.message.model.StartLiveModel;
import com.aliyun.aliinteraction.roompaas.message.model.StopLiveModel;
import com.aliyun.aliinteraction.uikit.R;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.uibase.util.AnimUtil;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auipusher.LiveContext;
import com.aliyun.auipusher.config.LiveEvent;
import com.aliyun.auipusher.manager.LiveLinkMicPushManager;

import java.util.Map;

/**
 * @author puke
 * @version 2021/7/29
 */
public class LiveCurtainComponent extends View implements ComponentHolder {

    private final Component component = new Component();

    public LiveCurtainComponent(Context context) {
        this(context, null, 0);
    }

    public LiveCurtainComponent(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveCurtainComponent(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setBackgroundResource(R.drawable.ilr_live_bg_alic);
    }

    private void showCurtain() {
        AnimUtil.animIn(LiveCurtainComponent.this);
    }

    private void hideCurtain() {
        AnimUtil.animOut(LiveCurtainComponent.this);
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private class Component extends BaseComponent {

        private void innerStopLive() {
            if (!isOwner()) {
                showCurtain();
            }
        }

        @Override
        public void onInit(LiveContext liveContext) {
            super.onInit(liveContext);

            getMessageService().addMessageListener(new SimpleOnMessageListener() {
                @Override
                public void onStartLive(AUIMessageModel<StartLiveModel> message) {
                    hideCurtain();
                }

                @Override
                public void onStopLive(AUIMessageModel<StopLiveModel> message) {
                    innerStopLive();
                }
            });

            getPlayerService().addEventHandler(new SimpleLivePlayerEventHandler() {
                @Override
                public void onRenderStart() {
                    hideCurtain();
                }

                @Override
                public void onPlayerError() {
                    showCurtain();
                }
            });
        }

        @Override
        public void onEnterRoomSuccess(LiveModel liveModel) {
            if (isOwner()) {
                hideCurtain();
            }
        }
    }
}
