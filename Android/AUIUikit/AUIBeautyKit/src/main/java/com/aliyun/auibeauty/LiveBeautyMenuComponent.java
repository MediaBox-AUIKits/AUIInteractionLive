package com.aliyun.auibeauty;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.core.base.Actions;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyunsdk.queen.menu.QueenBeautyMenu;
import com.aliyunsdk.queen.menu.QueenMenuPanel;

/**
 * @author puke
 * @version 2021/7/29
 */
public class LiveBeautyMenuComponent extends FrameLayout implements ComponentHolder {

    private final Component component = new Component();

    public LiveBeautyMenuComponent(@NonNull Context context) {
        this(context, null, 0);
    }

    public LiveBeautyMenuComponent(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveBeautyMenuComponent(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        View.inflate(context, R.layout.irl_beauty, LiveBeautyMenuComponent.this);

        QueenMenuPanel beautyMenuPanel = QueenBeautyMenu.getPanel(context);
        beautyMenuPanel.onHideMenu();
        beautyMenuPanel.onHideValidFeatures();
        beautyMenuPanel.onHideCopyright();

        QueenBeautyMenu beautyBeautyContainerView = findViewById(R.id.beauty_beauty_menuPanel);
        beautyBeautyContainerView.addView(beautyMenuPanel);
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private class Component extends BaseComponent {

        @Override
        public void onEnterRoomSuccess(LiveModel liveModel) {
            super.onEnterRoomSuccess(liveModel);
        }

        @Override
        public void onEvent(String action, Object... args) {
            switch (action) {
                case Actions.BEAUTY_CLICKED:
                    if (getVisibility() == View.VISIBLE) {
                        setVisibility(GONE);
                    } else {
                        setVisibility(VISIBLE);
                    }


            }
        }
    }
}
