package com.aliyun.aliinteraction.uikit.component;

import android.content.Context;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import androidx.annotation.Nullable;

import com.aliyun.aliinteraction.uikit.R;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.uibase.util.KeyboardHelper;
import com.aliyun.auipusher.LiveContext;

/**
 * @author puke
 * @version 2021/7/30
 */
public class LiveBottomComponent extends LinearLayout implements ComponentHolder {

    private final Component component = new Component();

    public LiveBottomComponent(Context context) {
        this(context, null, 0);
    }

    public LiveBottomComponent(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveBottomComponent(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        setClipChildren(false);
        setGravity(Gravity.BOTTOM);
        setOrientation(HORIZONTAL);
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private class Component extends BaseComponent {
        @Override
        public void onInit(LiveContext liveContext) {
            super.onInit(liveContext);
            initKeyboard();
        }

        private void initKeyboard() {
            KeyboardHelper keyboardHelper = new KeyboardHelper(activity);
            keyboardHelper.setOnSoftKeyBoardChangeListener(new KeyboardHelper.OnSoftKeyBoardChangeListener() {
                @Override
                public void keyBoardShow(int height) {
                    ViewGroup.MarginLayoutParams layoutParams = (ViewGroup.MarginLayoutParams) getLayoutParams();
                    layoutParams.bottomMargin = 12;
                    setLayoutParams(layoutParams);
                }

                @Override
                public void keyBoardHide(int height) {
                    ViewGroup.MarginLayoutParams layoutParams = (ViewGroup.MarginLayoutParams) getLayoutParams();
                    layoutParams.bottomMargin = getResources().getDimensionPixelOffset(R.dimen.room_bottom_layout_margin_bottom);
                    setLayoutParams(layoutParams);
                }
            });
        }
    }
}
