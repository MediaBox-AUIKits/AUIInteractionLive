package com.aliyun.aliinteraction.uikit.component;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.graphics.Color;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewTreeObserver;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.StringRes;

import com.alivc.auicommon.common.base.log.Logger;
import com.alivc.auicommon.common.roombase.Const;
import com.alivc.auicommon.core.base.Actions;
import com.alivc.auicommon.core.base.MessageModel;
import com.aliyun.aliinteraction.roompaas.message.listener.SimpleOnMessageListener;
import com.aliyun.aliinteraction.uikit.R;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.uibase.listener.SimpleTextWatcher;
import com.aliyun.aliinteraction.uikit.uibase.util.DialogUtil;
import com.aliyun.aliinteraction.uikit.uibase.util.KeyboardUtil;
import com.aliyun.aliinteraction.uikit.uibase.util.ViewUtil;
import com.aliyun.aliinteraction.uikit.uibase.util.immersionbar.ImmersionBar;
import com.aliyun.aliinteraction.uikit.uibase.view.IImmersiveSupport;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auipusher.LiveContext;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.model.base.AUIMessageModel;
import com.alivc.auimessage.model.base.InteractionError;
import com.alivc.auimessage.model.lwp.GroupMuteStatusResponse;
import com.alivc.auimessage.model.message.MuteGroupMessage;
import com.alivc.auimessage.model.message.UnMuteGroupMessage;

/**
 * @author puke
 * @version 2021/7/29
 */
public class LiveInputComponent extends FrameLayout implements ComponentHolder {

    private static final String TAG = "LiveInputComponent";
    private static final int SEND_COMMENT_MAX_LENGTH = 50;
    private static final int MINI_KEYBOARD_ALTER = 200;
    private final Component component = new Component();
    private final TextView commentInput;
    private Dialog dialog;
    private int largestInputLocationY;
    private CharSequence latestUnsentInputContent;

    // 自己是否被禁言
    private boolean isMute;
    // 全员是否被禁言
    private boolean isMuteAll;

    public LiveInputComponent(@NonNull Context context) {
        this(context, null, 0);
    }

    public LiveInputComponent(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveInputComponent(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);

        View.inflate(context, R.layout.ilr_view_live_input, this);
        commentInput = findViewById(R.id.room_comment_input);
        ViewUtil.bindClickActionWithClickCheck(commentInput, new Runnable() {
            @Override
            public void run() {
                LiveInputComponent.this.onInputClick();
            }
        });
    }

    private static Dialog createDialog(Context context) {
        // 自定义dialog显示布局
        @SuppressLint("InflateParams")
        View view = LayoutInflater.from(context).inflate(R.layout.iub_dialog_input, null);
        // 自定义dialog显示风格
        Dialog dialog = new Dialog(context, R.style.Dialog4Input);
        // 弹窗点击周围空白处弹出层自动消失弹窗消失(false时为点击周围空白处弹出层不自动消失)
        dialog.setCanceledOnTouchOutside(true);
        // 将布局设置给Dialog
        dialog.setContentView(view);
        // 获取当前Activity所在的窗体
        Window window = dialog.getWindow();
        WindowManager.LayoutParams wlp = window.getAttributes();
        wlp.gravity = Gravity.BOTTOM;
        wlp.width = LayoutParams.MATCH_PARENT;
        wlp.height = LayoutParams.MATCH_PARENT;
        window.setAttributes(wlp);
        return dialog;
    }

    protected void onInputClick() {
        Context context = getContext();
        dialog = createDialog(context);
        final EditText dialogInput = dialog.findViewById(R.id.dialog_comment_input);
        dialogInput.setHint(R.string.live_input_default_tips);
        View dialogRootView = dialog.findViewById(R.id.dialog_root);

        // 点击空白区域, 隐藏键盘和dialog
        dialogRootView.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                LiveInputComponent.this.hideKeyboardAndDismissDialog(dialogInput);
            }
        });

        // 键盘消失, 隐藏dialog
        exitWhenKeyboardCollapse(dialogInput);

        // 添加最大长度限制
        dialogInput.addTextChangedListener(new SimpleTextWatcher() {
            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                latestUnsentInputContent = s;
                int maxLength = SEND_COMMENT_MAX_LENGTH;
                if (s.length() > maxLength) {
                    dialogInput.setText(s.subSequence(0, maxLength));
                    dialogInput.setSelection(maxLength);
                    component.showToast(String.format("最多输入%s个字符", maxLength));
                }
            }
        });
        if (!TextUtils.isEmpty(latestUnsentInputContent)) {
            dialogInput.setText(latestUnsentInputContent);
            dialogInput.setSelection(latestUnsentInputContent.length());
        }

        // 添加提交事件处理
        dialogInput.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_SEND) {
                    component.onCommentSubmit(dialogInput);
                    return true;
                }
                return false;
            }
        });

        View sendButton = dialog.findViewById(R.id.sendButton);
        ViewUtil.bindClickActionWithClickCheck(sendButton, new Runnable() {
            @Override
            public void run() {
                component.onCommentSubmit(dialogInput);
            }
        });

        ViewUtil.addOnGlobalLayoutListener(dialogInput, new Runnable() {
            @Override
            public void run() {
                KeyboardUtil.showUpSoftKeyboard(dialogInput, (Activity) LiveInputComponent.this.getContext());
                dialogInput.animate().setStartDelay(150).setDuration(150).alpha(1).start();
            }
        });
        clearFlags(dialog.getWindow(), WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE | WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM);
        applySoftInputMode(dialog.getWindow(), WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);

        dialog.show();

        boolean disableImmersive = context instanceof IImmersiveSupport && ((IImmersiveSupport) context).shouldDisableImmersive();
        if (!disableImmersive && immersiveInsteadOfShowingStatusBar()) {
            ImmersionBar.with((Activity) getContext(), dialog).init();
        } else {
            dialog.getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        }
    }

    protected boolean immersiveInsteadOfShowingStatusBar() {
        return true;
    }

    private void exitWhenKeyboardCollapse(final EditText dialogInput) {
        largestInputLocationY = 0;
        final long startT = System.currentTimeMillis();
        final long shownDelay = 300;
        dialogInput.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                int[] location = new int[2];
                dialogInput.getLocationInWindow(location);
                int locationY = location[1];
                Logger.i(TAG, "onGlobalLayout: locationY=" + locationY);

                largestInputLocationY = Math.max(largestInputLocationY, locationY);

                if (System.currentTimeMillis() - startT > shownDelay
                        && largestInputLocationY - locationY > MINI_KEYBOARD_ALTER
                        && locationY > 0
                        && !KeyboardUtil.isKeyboardShown(dialogInput)) {
                    dismissAndRelease();
                    dialogInput.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                }
            }
        });
    }

    private void hideKeyboardAndDismissDialog(EditText dialogInput) {
        KeyboardUtil.hideKeyboard((Activity) getContext(), dialogInput);
        dismissAndRelease();
    }

    private void dismissAndRelease() {
        if (dialog != null) {
            DialogUtil.dismiss(dialog);
            applySoftInputMode(dialog.getWindow(), WindowManager.LayoutParams.SOFT_INPUT_STATE_UNSPECIFIED);
            dialog = null;
        }
    }

    private void clearFlags(Window window, int flags) {
        if (window != null) {
            window.clearFlags(flags);
        }
    }

    private void applySoftInputMode(Window window, int mode) {
        if (window != null) {
            window.setSoftInputMode(mode);
        }
    }

    private void updateMuteState() {
        if (isMuteAll) {
            // 全员被禁言
            setInputStyle(false, R.string.live_ban_all_tips);
        } else if (isMute) {
            // 自己被禁言
            setInputStyle(false, R.string.live_ban_tips);
        } else {
            // 未被禁言
            setInputStyle(true, R.string.live_input_default_tips);
        }
    }

    private void setInputStyle(boolean enable, @StringRes int hintRes) {
        commentInput.setEnabled(enable);
        commentInput.setText(hintRes);
        commentInput.setEnabled(enable);
        commentInput.setTextColor(enable ? Color.parseColor("#747A8C") : Color.parseColor("#66747A8C"));
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private class Component extends BaseComponent {

        @Override
        public void onInit(LiveContext liveContext) {
            super.onInit(liveContext);

            getMessageService().addMessageListener(new SimpleOnMessageListener() {
                @Override
                public void onMuteGroup(AUIMessageModel<MuteGroupMessage> message) {
                    super.onMuteGroup(message);
                    isMuteAll = true;
                    updateMuteState();
                }

                @Override
                public void onUnMuteGroup(AUIMessageModel<UnMuteGroupMessage> message) {
                    super.onUnMuteGroup(message);
                    isMuteAll = false;
                    updateMuteState();
                }
            });
        }

        @Override
        public void onEnterRoomSuccess(LiveModel liveModel) {
            queryUserMuteState();
            setVisibility(needPlayback() ? INVISIBLE : VISIBLE);
        }

        private void queryUserMuteState() {
            // 当前不做点对点禁言
            getMessageService().queryMuteAll(new InteractionCallback<Boolean>() {
                @Override
                public void onSuccess(Boolean data) {
                    isMuteAll = data;
                    updateMuteState();
                }

                @Override
                public void onError(InteractionError interactionError) {
                    showToast("获取禁言状态失败，" + interactionError);
                }
            });
        }

        private void onCommentSubmit(final EditText dialogInput) {
            if (isMuteAll) {
                component.showToast("当前全局禁言中");
                return;
            }
            final String inputText = dialogInput.getText().toString().trim();
            if (TextUtils.isEmpty(inputText)) {
                component.showToast("请输入评论内容");
                return;
            }

            latestUnsentInputContent = "";
            getMessageService().sendComment(inputText, new InteractionCallback<String>() {
                @Override
                public void onSuccess(String messageId) {
                    // 通知面板, 自己发送的弹幕信息
                    String userId = Const.getUserId();
                    String currentNick = liveContext.getNick();
                    String userNick = currentNick == null ? "" : currentNick;
                    MessageModel messageModel = new MessageModel(userId, userNick, inputText);
                    postEvent(Actions.SHOW_MESSAGE, messageModel, true);
                }

                @Override
                public void onError(InteractionError error) {
                    showToast(error.msg);
                }
            });
            hideKeyboardAndDismissDialog(dialogInput);
        }

        @Override
        public void onEvent(String action, Object... args) {
            switch (action) {
                case Actions.GET_GROUP_STATISTICS_SUCCESS: {
                    if (args.length > 0 && args[0] instanceof GroupMuteStatusResponse) {
                        GroupMuteStatusResponse rsp = (GroupMuteStatusResponse) args[0];
                        isMuteAll = rsp.isMuteAll;
                        updateMuteState();
                    }
                    break;
                }
                case Actions.SHOW_ENTERPRISE_CHAT: {
                    setVisibility(VISIBLE);
                    break;
                }
                case Actions.SHOW_ENTERPRISE_INTRO: {
                    setVisibility(INVISIBLE);
                    break;
                }
            }
        }
    }
}
