package com.aliyun.auilinkmickit;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Process;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.alivc.auicommon.common.base.util.CommonUtil;
import com.alivc.auicommon.core.base.Actions;
import com.aliyun.aliinteraction.roompaas.message.listener.SimpleOnMessageListener;
import com.aliyun.aliinteraction.roompaas.message.model.CommandUpdateCameraModel;
import com.aliyun.aliinteraction.roompaas.message.model.CommandUpdateMicModel;
import com.aliyun.aliinteraction.roompaas.message.model.HandleApplyJoinLinkMicModel;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.uibase.helper.ExpandShrinkAnimationHelper;
import com.aliyun.aliinteraction.uikit.uibase.util.AppUtil;
import com.aliyun.aliinteraction.uikit.uibase.util.DialogUtil;
import com.aliyun.auipusher.LiveContext;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.model.base.AUIMessageModel;
import com.alivc.auimessage.model.base.InteractionError;

/**
 * 观众端右下角的连麦操作视图
 *
 * @author puke
 * @version 2022/11/15
 */
public class LiveLinkMicActionComponent extends LinearLayout implements ComponentHolder {

    private final View mainIcon;
    private final View actionLayout;
    private final View mic;
    private final View camera;
    private final View cameraSwitch;
    private final View textLayout;
    private final TextView text;

    private final ShrinkHelper shrinkHelper = new ShrinkHelper();
    private final Component component = new Component();
    private boolean isExpand;

    private boolean micOpened = true;
    private boolean cameraOpened = true;

    private State state = State.INIT;

    public LiveLinkMicActionComponent(Context context) {
        this(context, null, 0);
    }

    public LiveLinkMicActionComponent(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveLinkMicActionComponent(final Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setVisibility(GONE);
        setGravity(Gravity.CENTER_VERTICAL);
        setOrientation(HORIZONTAL);
        int padding = AppUtil.dp(6);
        setPadding(padding, padding, padding, padding);
        setBackgroundResource(R.drawable.ilr_bg_linkmic_action);
        inflate(context, R.layout.ilr_view_live_link_mic_action, this);

        mainIcon = findViewById(R.id.link_mic_action_main_icon);

        actionLayout = findViewById(R.id.link_mic_action_layout);
        mic = findViewById(R.id.link_mic_action_mic);
        mic.setSelected(micOpened);
        camera = findViewById(R.id.link_mic_action_camera);
        camera.setSelected(cameraOpened);
        cameraSwitch = findViewById(R.id.link_mic_action_camera_switch);

        textLayout = findViewById(R.id.link_mic_text_layout);
        text = findViewById(R.id.link_mic_action_text);

        // 点击展开
        mainIcon.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isExpand) {
                    shrinkHelper.cancelShrink();
                    setShrink();
                    return;
                }

                switch (state) {
                    case INIT:
                        setReadyToApply();
                        break;
                    case APPLYING:
                        shrinkHelper.readyShrink();
                        break;
                    case JOINED:
                        setJoined();
                        break;
                }
            }
        });

        // 点击文字
        text.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                switch (state) {
                    case INIT:
                        // 申请连麦
                        shrinkHelper.cancelShrink();
                        DialogUtil.confirm(context, "您确定要想主播申请连麦吗？",
                                new Runnable() {
                                    @Override
                                    public void run() {
                                        setApplying();
                                    }
                                },
                                new Runnable() {
                                    @Override
                                    public void run() {
                                        shrinkHelper.readyShrink();
                                    }
                                }
                        );
                        break;
                    case APPLYING:
                        // 取消连麦
                        shrinkHelper.cancelShrink();
                        DialogUtil.confirm(context, "是否取消连麦？",
                                new Runnable() {
                                    @Override
                                    public void run() {
                                        shrinkHelper.readyShrink();
                                        if (state == State.APPLYING) {
                                            reset();
                                            component.cancelApplyLinkMic();
                                        }
                                    }
                                },
                                new Runnable() {
                                    @Override
                                    public void run() {
                                        shrinkHelper.readyShrink();
                                    }
                                }
                        );
                        break;
                    case JOINED:
                        // 挂断
                        shrinkHelper.cancelShrink();
                        DialogUtil.confirm(context, "是否结束与主播连麦？",
                                new Runnable() {
                                    @Override
                                    public void run() {
                                        component.postEvent(Actions.LEAVE_LINK_MIC);
                                    }
                                },
                                new Runnable() {
                                    @Override
                                    public void run() {
                                        shrinkHelper.readyShrink();
                                    }
                                }
                        );
                        break;
                }
            }
        });

        mic.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                performUpdateMic(!micOpened, true);
            }
        });

        camera.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                performUpdateCamera(!cameraOpened, true);
            }
        });

        cameraSwitch.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                shrinkHelper.readyShrink();
                component.getLiveLinkMicPushManager().switchCamera();
            }
        });
    }

    private void performUpdateMic(boolean target, boolean showToast) {
        shrinkHelper.readyShrink();
        component.getLiveLinkMicPushManager().setMute(!target);
        micOpened = target;
        mic.setSelected(target);
        component.getMessageService().updateMicStatus(target, null);
        if (showToast) {
            component.showToast(String.format("麦克风已%s", target ? "开启" : "关闭"));
        }
    }

    private void performUpdateCamera(boolean target, boolean showToast) {
        shrinkHelper.readyShrink();
        if (target) {
            component.getLiveLinkMicPushManager().resume();
        } else {
            component.getLiveLinkMicPushManager().pause();
        }
        cameraOpened = target;
        camera.setSelected(target);
        component.getMessageService().updateCameraStatus(target, null);
        if (showToast) {
            component.showToast(String.format("摄像头已%s", target ? "开启" : "关闭"));
        }
    }

    // 准备申请连麦, 5s自动收起
    private void setReadyToApply() {
        isExpand = true;
        text.setText("申请连麦");
        shrinkHelper.readyShrink();
        textLayout.setVisibility(VISIBLE);
    }

    // 申请连麦
    private void setApplying() {
        if (noPermission(Manifest.permission.CAMERA)
                || noPermission(Manifest.permission.RECORD_AUDIO)) {
            CommonUtil.showToast(getContext(), "请在手机设置中开启摄像头权限");
            return;
        }

        state = State.APPLYING;
        isExpand = true;
        shrinkHelper.cancelShrink();
        text.setText("取消连麦");
        textLayout.setVisibility(VISIBLE);
        component.applyLinkMic();
    }

    private boolean noPermission(String permission) {
        int checkResult = getContext().checkPermission(
                permission, android.os.Process.myPid(), Process.myUid());
        return checkResult != PackageManager.PERMISSION_GRANTED;
    }

    // 连麦成功
    private void setJoined() {
        state = State.JOINED;
        isExpand = true;
        setActivated(false);
        text.setText("挂断");
        shrinkHelper.readyShrink();
        textLayout.setVisibility(VISIBLE);
        actionLayout.setVisibility(VISIBLE);
        mainIcon.setVisibility(GONE);
    }

    // 重置
    private void reset() {
        state = State.INIT;
        setShrink();
    }

    // 收起
    private void setShrink() {
        isExpand = false;
        mainIcon.setVisibility(VISIBLE);
        shrinkHelper.cancelShrink();
        ExpandShrinkAnimationHelper.doShrinkAnimation(actionLayout, null);
        ExpandShrinkAnimationHelper.doShrinkAnimation(textLayout, new Runnable() {
            @Override
            public void run() {
                setActivated(state == State.JOINED);
            }
        });
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private enum State {
        APPLYING,
        JOINED,
        INIT,
    }

    // 收起辅助类
    private class ShrinkHelper {
        void readyShrink() {
            cancelShrink();
            postDelayed(autoShrinkTask, 5000);
        }

        void cancelShrink() {
            removeCallbacks(autoShrinkTask);
        }

        final Runnable autoShrinkTask = new Runnable() {
            @Override
            public void run() {
                setShrink();
            }
        };
    }

    private class Component extends BaseComponent {
        @Override
        public void onInit(LiveContext liveContext) {
            super.onInit(liveContext);
            if (isOwner() || !supportLinkMic() || needPlayback()) {
                // 主播不展示, 非连麦场景不展示
                return;
            }

            setVisibility(VISIBLE);
            getMessageService().addMessageListener(new SimpleOnMessageListener() {
                @Override
                public void onHandleApplyJoinLinkMic(AUIMessageModel<HandleApplyJoinLinkMicModel> message) {
                    if (!message.data.agree) {
                        // 主播拒绝我的连麦申请
                        reset();
                    }
                }

                @Override
                public void onCommandMicUpdate(AUIMessageModel<CommandUpdateMicModel> message) {
                    if (state == State.JOINED) {
                        // 麦上观众, 收到主播命令后, 更改麦克风状态
                        performUpdateMic(message.data.needOpenMic, true);
                    }
                }

                @Override
                public void onCommandCameraUpdate(AUIMessageModel<CommandUpdateCameraModel> message) {
                    if (state == State.JOINED) {
                        // 麦上观众, 收到主播命令后, 更改摄像头状态
                        performUpdateCamera(message.data.needOpenCamera, true);
                    }
                }
            });
        }

        public void applyLinkMic() {
            postEvent(Actions.APPLY_JOIN_LINK_MIC);
            liveContext.getMessageService().applyJoinLinkMic(liveContext.getLiveModel().anchorId, new InteractionCallback<String>() {
                @Override
                public void onSuccess(String messageId) {
                    showToast("已发送连麦申请，等待主播操作");
                }

                @Override
                public void onError(InteractionError error) {
                    showToast(error.msg);
                }
            });
        }

        public void cancelApplyLinkMic() {
            getMessageService().cancelApplyJoinLinkMic(getAnchorId(), null);
            postEvent(Actions.CANCEL_APPLY_JOIN_LINK_MIC);
            showToast("连麦已取消");
        }

        @Override
        public void onEvent(String action, Object... args) {
            switch (action) {
                case Actions.JOIN_LINK_MIC:
                    setJoined();
                    showToast("连麦成功");
                    // 初始化麦克风摄像头状态 (刚上麦时默认声音和画面均打开)
                    performUpdateMic(true, false);
                    performUpdateCamera(true, false);
                    break;
                case Actions.LEAVE_LINK_MIC:
                case Actions.KICK_LINK_MIC:
                case Actions.REJECT_JOIN_LINK_MIC_WHEN_ANCHOR_AGREE:
                case Actions.JOIN_BUT_MAX_LIMIT_WHEN_ANCHOR_AGREE:
                case Actions.GET_MEMBERS_FAIL_WHEN_ANCHOR_AGREE:
                    reset();
                    break;
            }
        }

        @Override
        public boolean interceptBackKey() {
            if (!isOwner() && state == State.JOINED) {
                // 观众离开页面前, 如果在麦上, 就需要二次确认
                DialogUtil.confirm(activity, "是否结束与主播连麦，并退出直播间？", new Runnable() {
                    @Override
                    public void run() {
                        component.postEvent(Actions.LEAVE_LINK_MIC);
                        activity.onBackPressed();
                    }
                });
                return true;
            }
            return super.interceptBackKey();
        }
    }
}
