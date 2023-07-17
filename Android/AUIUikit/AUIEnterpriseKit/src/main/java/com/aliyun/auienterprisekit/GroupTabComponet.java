package com.aliyun.auienterprisekit;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.common.biz.exposable.enums.LiveStatus;
import com.alivc.auicommon.core.base.Actions;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auipusher.LiveContext;

public class GroupTabComponet extends FrameLayout implements ComponentHolder {
    private final Component component = new Component();
    private RadioButton mChatBtn;//聊天tab
    private View mChatLine;
    private RadioButton mIntroductionBtn;//简介tab
    private View mIntroductionLine;
    private TextView mUnreadMessageCount;//未读消息数量
    private int mMessageNum;//消息数量
    private LinearLayout mChatLayout;//聊天tab

    public GroupTabComponet(@NonNull Context context) {
        this(context, null, 0);
    }

    public GroupTabComponet(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public GroupTabComponet(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        inflate(context, R.layout.ilr_group_layout, this);
        mChatBtn = findViewById(R.id.checkbox_chat);
        mUnreadMessageCount = findViewById(R.id.unread_message_count);
        mChatLayout = findViewById(R.id.chat_layout);
        mChatBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                mChatLine.setVisibility(View.VISIBLE);
                mIntroductionLine.setVisibility(View.INVISIBLE);
                component.postEvent(Actions.SHOW_ENTERPRISE_CHAT);
                mUnreadMessageCount.setVisibility(View.GONE);
                mMessageNum = 0;
            }
        });
        mChatLine = findViewById(R.id.chat_line);
        mIntroductionBtn = findViewById(R.id.checkbox_introduction);
        mIntroductionBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                mChatLine.setVisibility(View.INVISIBLE);
                mIntroductionLine.setVisibility(View.VISIBLE);
                component.postEvent(Actions.SHOW_ENTERPRISE_INTRO);

            }
        });
        mIntroductionLine = findViewById(R.id.introduction_line);
    }

    private void initView() {

    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private class Component extends BaseComponent {

        @Override
        public void onInit(LiveContext liveContext) {
            super.onInit(liveContext);

            LiveStatus status = liveService.getLiveModel().getLiveStatus();
            switch (status) {
                case END:
                    mChatLayout.setVisibility(View.GONE);
                    mIntroductionLine.setVisibility(View.GONE);
                    break;
                default:
                    break;
            }
        }

        @Override
        public void onEnterRoomSuccess(LiveModel liveModel) {
            component.postEvent(Actions.SHOW_ENTERPRISE_INTRO);
            if (needPlayback()) {
                mChatLayout.setVisibility(View.GONE);
                mIntroductionLine.setVisibility(View.GONE);
            }
        }

        @Override
        public void onEvent(String action, Object... args) {
            if (Actions.SHOW_MESSAGE_TIPS.equals(action) && mIntroductionLine.getVisibility() == View.VISIBLE) {
                mUnreadMessageCount.setVisibility(View.VISIBLE);
                mMessageNum++;
                mUnreadMessageCount.setText(String.valueOf(mMessageNum));
            }
        }
    }
}
