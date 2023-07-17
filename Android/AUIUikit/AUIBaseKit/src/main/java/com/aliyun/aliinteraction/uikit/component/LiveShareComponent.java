package com.aliyun.aliinteraction.uikit.component;

import android.app.Dialog;
import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.aliyun.aliinteraction.uikit.R;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.uibase.util.BottomSheetDialogUtil;
import com.aliyun.aliinteraction.uikit.uibase.util.DialogUtil;
import com.aliyun.auipusher.LiveContext;

/**
 * @author puke
 * @version 2021/7/29
 */
public class LiveShareComponent extends FrameLayout implements ComponentHolder {

    private final Component component = new Component();

    public LiveShareComponent(@NonNull Context context) {
        this(context, null, 0);
    }

    public LiveShareComponent(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveShareComponent(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        View.inflate(context, R.layout.ilr_view_share, this);

        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                component.handleShareClick();
            }
        });
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private class Component extends BaseComponent {

        private Dialog dialog;

        @Override
        public void onInit(LiveContext liveContext) {
            super.onInit(liveContext);
            setVisibility(isOwner() ? GONE : VISIBLE);
        }

        private void handleShareClick() {
            if (dialog == null) {
                dialog = (Dialog) BottomSheetDialogUtil.create(activity, R.layout.ilr_share_view);

                View panel = dialog.findViewById(R.id.share_panel);
                if (panel != null) {
                    panel.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            showToast("仅展示，需要对接分享功能");
                        }
                    });
                }

                View cancel = dialog.findViewById(R.id.share_cancel);
                if (cancel != null) {
                    cancel.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            dialog.dismiss();
                        }
                    });
                }
            }
            dialog.show();
        }

        @Override
        public void onActivityDestroy() {
            DialogUtil.dismiss(dialog);
            dialog = null;
        }
    }
}
