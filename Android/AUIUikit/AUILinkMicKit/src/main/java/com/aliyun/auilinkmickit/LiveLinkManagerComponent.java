package com.aliyun.auilinkmickit;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.uibase.util.AppUtil;
import com.aliyun.auiappserver.model.LiveModel;
import com.google.android.material.bottomsheet.BottomSheetBehavior;

public class LiveLinkManagerComponent extends RelativeLayout implements ComponentHolder {


    private final LiveLinkManagerComponent.Component component = new LiveLinkManagerComponent.Component();

    private BottomSheetBehavior behavior;
    //状态监听，通过这个监听菜单是否消失
    private BottomSheetBehavior.BottomSheetCallback bottomSheetCallback = new BottomSheetBehavior.BottomSheetCallback() {
        @Override
        public void onStateChanged(@NonNull View bottomSheet, int newState) {
            if (newState == BottomSheetBehavior.STATE_HIDDEN) {
                if (!isBehaviorShowing(behavior)) {
                    //菜单已经消失
                }
            }
        }

        @Override
        public void onSlide(@NonNull View bottomSheet, float slideOffset) {
            //滑动监听
        }
    };

    public LiveLinkManagerComponent(@NonNull Context context) {
        this(context, null, 0);
    }

    public LiveLinkManagerComponent(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveLinkManagerComponent(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        View.inflate(context, R.layout.ilr_view_link_manager, this);
        //找到BottomSheetBehavior
        behavior = BottomSheetBehavior.from(findViewById(R.id.bottom_sheet));

        //设置弹出高度
        behavior.setPeekHeight(AppUtil.getScreenHeight() / 2);
        //默认隐藏
        behavior.setState(BottomSheetBehavior.STATE_HIDDEN);
        //添加消失监听
        behavior.setBottomSheetCallback(bottomSheetCallback);

        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });
    }

    private Boolean isBehaviorShowing(BottomSheetBehavior behavior) {
        return behavior.getState() == BottomSheetBehavior.STATE_COLLAPSED
                || behavior.getState() == BottomSheetBehavior.STATE_EXPANDED
                || behavior.getState() == BottomSheetBehavior.STATE_SETTLING;
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

    }
}
