package com.aliyun.auienterprisekit;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.core.base.Actions;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auipusher.LiveContext;

public class IntroductionComponet extends FrameLayout implements ComponentHolder {
    private final Component component = new Component();
    private TextView mIntroTitle;
    private TextView mIntroNotice;
    private TextView mIntroTime;

    public IntroductionComponet(@NonNull Context context) {
        this(context, null, 0);
    }

    public IntroductionComponet(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public IntroductionComponet(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        inflate(context, R.layout.ilr_intro_layout, this);
        mIntroTitle = findViewById(R.id.intro_title);
        mIntroNotice = findViewById(R.id.intro_notice);
        mIntroTime = findViewById(R.id.intro_time);
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

        }

        @Override
        public void onEnterRoomSuccess(LiveModel liveModel) {
            mIntroTitle.setText(liveModel.title);
            mIntroNotice.setText(liveModel.notice);
            if (!TextUtils.isEmpty(liveModel.createdAt) && liveModel.createdAt.length() > 9) {
                mIntroTime.setText(liveModel.createdAt.replaceAll("T", " ").substring(0, liveModel.createdAt.length() - 9));
            }
        }

        @Override
        public void onEvent(String action, Object... args) {
            switch (action) {
                case Actions.SHOW_ENTERPRISE_CHAT:
                    setVisibility(GONE);
                    break;
                case Actions.SHOW_ENTERPRISE_INTRO:
                    setVisibility(VISIBLE);
                    break;
                default:
                    break;
            }
        }
    }
}
