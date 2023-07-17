package com.aliyun.auilinkmickit;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.core.base.Actions;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.auipusher.LiveContext;

/**
 * @author puke
 * @version 2021/7/29
 */
public class LiveLinkMicNumComponent extends FrameLayout implements ComponentHolder {

    private final Component component = new Component();
    private final TextView counter;

    public LiveLinkMicNumComponent(@NonNull Context context) {
        this(context, null, 0);
    }

    public LiveLinkMicNumComponent(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveLinkMicNumComponent(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        View.inflate(context, R.layout.ilr_view_live_linkmic_manage, this);
        counter = findViewById(R.id.manage_counter);
        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                component.handleClick();
            }
        });
    }

    @SuppressLint("SetTextI18n")
    private void updateCounter(int count) {
        if (count <= 0) {
            counter.setVisibility(GONE);
        } else {
            counter.setVisibility(VISIBLE);
            if (count > 99) {
                counter.setText("99+");
            } else {
                counter.setText(String.valueOf(count));
            }
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
            boolean showLinkMicManage = isOwner() && supportLinkMic() && !needPlayback();
            setVisibility(showLinkMicManage ? VISIBLE : GONE);
        }

        private void handleClick() {
            postEvent(Actions.LINK_MIC_MANAGE_CLICK);
        }

        @Override
        public void onEvent(String action, Object... args) {
            if (Actions.UPDATE_MANAGE_COUNTER.equals(action)) {
                updateCounter((int) args[0]);
            }
        }
    }
}
