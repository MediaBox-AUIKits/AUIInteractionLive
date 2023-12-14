package com.aliyun.auipusherkit;

import android.animation.ValueAnimator;
import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.view.animation.LinearInterpolator;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.common.base.exposable.Callback;
import com.alivc.auicommon.common.base.util.Utils;
import com.alivc.auicommon.common.roombase.Const;
import com.alivc.auicommon.core.base.Actions;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.model.base.InteractionError;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.uibase.util.ExStatusBarUtils;
import com.aliyun.aliinteraction.uikit.uibase.view.IImmersiveSupport;
import com.aliyun.auiappserver.AppServerApi;
import com.aliyun.auiappserver.ClickLookUtils;
import com.aliyun.auiappserver.model.StartLiveRequest;
import com.aliyun.auipusher.LiveContext;
import com.aliyun.auipusher.SimpleLiveEventHandler;
import com.aliyun.auipusher.config.LiveEvent;
import com.aliyunsdk.queen.menu.QueenBeautyMenu;
import com.aliyunsdk.queen.menu.QueenMenuPanel;

import java.util.Map;


/**
 * @author puke
 * @version 2021/7/30
 */
public class LiveStartComponent extends FrameLayout implements ComponentHolder {

    private final Component component = new Component();
    private TextView timeCount;//倒计时
    private LinearLayout timeDownLayout;//倒计时layout
    private TextView roomTitle;//房间title
    private TextView roomTips;//房间公告

    // 美颜menu
    private QueenBeautyMenu beautyBeautyContainerView;
    private QueenMenuPanel queenMenuPanel;

    private LinearLayout beautyFaceLayout;//美颜layout

    public LiveStartComponent(@NonNull Context context) {
        this(context, null, 0);
    }

    public LiveStartComponent(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveStartComponent(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        View.inflate(context, R.layout.ilr_view_live_start, this);

        queenMenuPanel = QueenBeautyMenu.getPanel(context);
        queenMenuPanel.onHideMenu();
        queenMenuPanel.onHideValidFeatures();
        queenMenuPanel.onHideCopyright();

        beautyBeautyContainerView = findViewById(R.id.beauty_beauty_menuPanel);
        beautyBeautyContainerView.addView(queenMenuPanel);

        timeCount = findViewById(R.id.time_down);
        beautyFaceLayout = findViewById(R.id.beauty_face_layout);
        beautyFaceLayout.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                changeBeautyContainerVisibility();
            }
        });
        timeDownLayout = findViewById(R.id.time_down_layout);
        roomTitle = findViewById(R.id.room_title);
        roomTips = findViewById(R.id.room_tips);

        findViewById(R.id.start_live).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                timeDownLayout.setVisibility(View.VISIBLE);
                //倒计时显示
                ValueAnimator animator = ValueAnimator.ofInt(3, 1);
                //设置时间
                animator.setDuration(2500);
                //均匀显示
                animator.setInterpolator(new LinearInterpolator());
                animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                    @Override
                    public void onAnimationUpdate(ValueAnimator animation) {
                        int value = (Integer) animation.getAnimatedValue();
                        timeCount.setText(String.valueOf(value));
                        if (value == 1) {
                            component.handleStartLive();
                        }
                    }
                });
                animator.start();
            }
        });
        findViewById(R.id.icon_back).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                component.backPressed();
            }
        });
        findViewById(R.id.switch_camera).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {//避免频繁点击造成sdk crash
                if (!ClickLookUtils.isFastClick()) {
                    return;
                }
                component.handleSwitchCamera();
            }
        });

        boolean disableImmersive = false;
        if (context instanceof IImmersiveSupport) {
            disableImmersive = ((IImmersiveSupport) context).shouldDisableImmersive();
        }
        if (!disableImmersive) {
            ExStatusBarUtils.adjustTopPaddingForImmersive(this);
        }

        this.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (beautyBeautyContainerView.getVisibility() == View.VISIBLE) {
                    queenMenuPanel.onHideMenu();
                    beautyBeautyContainerView.setVisibility(View.GONE);
                }
            }
        });

    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private void changeBeautyContainerVisibility() {
        if (beautyBeautyContainerView.getVisibility() == View.VISIBLE) {
            queenMenuPanel.onHideMenu();
            beautyBeautyContainerView.setVisibility(View.GONE);
        } else {
            queenMenuPanel.onShowMenu();
            beautyBeautyContainerView.setVisibility(View.VISIBLE);
        }
    }

    private class Component extends BaseComponent {

        @Override
        public void onInit(final LiveContext liveContext) {
            super.onInit(liveContext);
            roomTitle.setText(liveContext.getLiveModel().title);
            if (TextUtils.isEmpty(liveContext.getTips())) {
                roomTips.setVisibility(View.GONE);
            } else {
                roomTips.setText(liveContext.getTips());
            }

            liveService.addEventHandler(new SimpleLiveEventHandler() {
                @Override
                public void onPusherEvent(LiveEvent event, @Nullable Map<String, Object> extras) {
                    if (isOwner() && event == LiveEvent.PUSH_STARTED) {
                        // 推流成功后, 通知观众端拉流, 服务端更新状态
                        getMessageService().startLive(null);
                        StartLiveRequest request = new StartLiveRequest();
                        request.id = liveContext.getLiveId();
                        request.userId = Const.getUserId();
                        AppServerApi.instance().startLive(request).invoke(new InteractionCallback<Void>() {
                            @Override
                            public void onSuccess(Void unused) {

                            }

                            @Override
                            public void onError(InteractionError error) {

                            }

                        });
                    }
                }
            });
        }

        private void handleStartLive() {
            liveService.getPusherService().startLive(new Callback<View>() {
                @Override
                public void onSuccess(View data) {
                    postEvent(Actions.ANCHOR_PUSH_SUCCESS);
                }

                @Override
                public void onError(String errorMsg) {
                    showToast("开始直播失败: " + errorMsg);
                }
            });
        }


        private void handleSwitchCamera() {
            liveService.getPusherService().switchCamera();
        }

        public void backPressed() {
            if (Utils.isActivityInvalid(activity)) {
                return;
            }
            activity.onBackPressed();
        }
    }
}
