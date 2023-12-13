package com.aliyun.aliinteraction.uikit.component;

import android.app.Dialog;
import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.core.base.Actions;
import com.aliyun.aliinteraction.uikit.R;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.uibase.util.DialogUtil;
import com.aliyun.auiappserver.ClickLookUtils;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auipusher.LivePusherService;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.model.base.InteractionError;
import com.alivc.auimessage.model.lwp.GroupMuteStatusResponse;

/**
 * @author puke
 * @version 2021/7/29
 */
public class LiveMoreComponent extends FrameLayout implements ComponentHolder {

    private final Component component = new Component();
    private final Dialog dialog;

    private boolean isMutePush = false;
    private boolean isMutePlay = false;
    private boolean isMirror = false;
    private boolean isPlaying = false;
    private boolean isMuteGroupAll = false;
    private boolean isCloseCamera = false;


    public LiveMoreComponent(@NonNull Context context) {
        this(context, null, 0);
    }

    public LiveMoreComponent(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveMoreComponent(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        View.inflate(context, R.layout.ilr_view_live_more, this);

        dialog = DialogUtil.createDialogOfBottom(context, LayoutParams.WRAP_CONTENT,
                R.layout.ilr_view_float_live_more, true);
        setMoreToolbarListener();

        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                LiveMoreComponent.this.onMore();
            }
        });
    }

    private void onMore() {
        if (!component.isOwner()) {
            dialog.findViewById(R.id.live_tool_switch).setVisibility(View.GONE);
            dialog.findViewById(R.id.live_tool_mirror).setVisibility(View.GONE);
            dialog.findViewById(R.id.live_tool_ban_all).setVisibility(View.GONE);
        }
        dialog.show();
    }

    private void changeBandAllUI() {
        ((TextView) dialog.findViewById(R.id.live_tool_band_txt)).setText(isMuteGroupAll ? "取消禁言" : "全员禁言");
        if (isMuteGroupAll) {
            dialog.findViewById(R.id.comment_image).setBackgroundResource(R.drawable.ilr_icon_more_comment_closed);
        } else {
            dialog.findViewById(R.id.comment_image).setBackgroundResource(R.drawable.ilr_icon_more_comment_opened);
        }

    }

    private void setMoreToolbarListener() {
        dialog.findViewById(R.id.live_tool_mute).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (component.isOwner()) {
                    onMuteLive(view);
                }
            }
        });
        dialog.findViewById(R.id.live_tool_switch).setOnClickListener(new OnClickListener() {//避免频繁点击造成sdk crash
            @Override
            public void onClick(View v) {
                if (!ClickLookUtils.isFastClick()) {
                    return;
                }
                onSwitch(dialog.findViewById(R.id.live_tool_switch));
            }
        });
        dialog.findViewById(R.id.live_tool_mirror).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                LiveMoreComponent.this.onMirrorLive(view);
            }
        });
        dialog.findViewById(R.id.live_tool_ban_all).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                component.handleBanAll();
            }
        });
        dialog.findViewById(R.id.live_tool_close_camera).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                isCloseCamera = !isCloseCamera;
                ((TextView) view.findViewById(R.id.live_tool_camera_txt)).setText(isCloseCamera ? "关闭摄像头" : "开启摄像头");

                // 连麦场景, 通知观众自己的推流状态
                if (component.supportLinkMic()) {
                    component.getMessageService().updateCameraStatus(!isCloseCamera, null);
                }

                if (isCloseCamera) {
                    dialog.findViewById(R.id.mic_camera).setBackgroundResource(R.drawable.ilr_icon_more_camera_closed);
                    component.getPusherService().closeCamera();
                } else {
                    dialog.findViewById(R.id.mic_camera).setBackgroundResource(R.drawable.ilr_icon_more_camera_opened);
                    component.getPusherService().openCamera();
                }
            }
        });
    }

    public void onMuteLive(View view) {
        isMutePush = !isMutePush;
        component.getPusherService().setMutePush(isMutePush);
        if (component.supportLinkMic()) {
            // 在连麦场景禁音时, 要同步IM消息给直播间其他成员
            component.getMessageService().updateMicStatus(!isMutePush, null);
        }
        ((TextView) view.findViewById(R.id.live_tool_mute_txt)).setText(isMutePush ? "取消静音" : "静音");
        if (isMutePush) {
            view.findViewById(R.id.mic_image).setBackgroundResource(R.drawable.ilr_icon_more_mic_closed);
        } else {
            view.findViewById(R.id.mic_image).setBackgroundResource(R.drawable.ilr_icon_more_mic_opened);
        }
    }

    public void onMirrorLive(View view) {
        isMirror = !isMirror;
        component.getPusherService().setPreviewMirror(isMirror);
        component.getPusherService().setPushMirror(isMirror);
        ((TextView) view.findViewById(R.id.live_tool_mirror_txt)).setText(isMirror ? "开启镜像" : "关闭镜像");
        if (isMirror) {
            view.findViewById(R.id.mirror_image).setBackgroundResource(R.drawable.ilr_icon_more_mirror_opened);
        } else {
            view.findViewById(R.id.mirror_image).setBackgroundResource(R.drawable.ilr_icon_more_mirror_closed);
        }
    }

    public void onSwitch(View view) {
        component.getPusherService().switchCamera();
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private class Component extends BaseComponent {

        @Override
        public void onEnterRoomSuccess(LiveModel liveModel) {
            // 只有主播端, 且不是回放状态的情况, 才展示更多视图
            boolean showMore = isOwner() && !needPlayback();
            setVisibility(showMore ? VISIBLE : GONE);
        }

        private void handleBanAll() {
            if (isMuteGroupAll) {
                component.getMessageService().cancelMuteAll(new InteractionCallback<Boolean>() {
                    @Override
                    public void onSuccess(Boolean data) {
                        isMuteGroupAll = false;
                        changeBandAllUI();
                    }

                    @Override
                    public void onError(InteractionError interactionError) {
                        showToast("取消全员禁言失败, " + interactionError);
                    }
                });
            } else {
                DialogUtil.confirm(activity, "是否开启全员禁言？", new Runnable() {
                    @Override
                    public void run() {
                        component.getMessageService().muteAll(new InteractionCallback<Boolean>() {
                            @Override
                            public void onSuccess(Boolean data) {
                                isMuteGroupAll = true;
                                changeBandAllUI();
                            }

                            @Override
                            public void onError(InteractionError interactionError) {
                                showToast("全员禁言失败, " + interactionError);
                            }
                        });
                    }
                });
            }
        }

        @Override
        public void onEvent(String action, Object... args) {
            if (Actions.GET_GROUP_STATISTICS_SUCCESS.equals(action)) {
                if (args.length > 0 && args[0] instanceof GroupMuteStatusResponse) {
                    GroupMuteStatusResponse groupMuteStatusResponse = (GroupMuteStatusResponse) args[0];
                    isMuteGroupAll = groupMuteStatusResponse.isMuteAll;
                    changeBandAllUI();
                }
            }
        }

        private boolean isPushing() {
            return liveContext.isPushing();
        }

        private void setPushing(boolean isPushing) {
            liveContext.setPushing(isPushing);
        }

        private LivePusherService getPusherService() {
            return liveService.getPusherService();
        }
    }
}
