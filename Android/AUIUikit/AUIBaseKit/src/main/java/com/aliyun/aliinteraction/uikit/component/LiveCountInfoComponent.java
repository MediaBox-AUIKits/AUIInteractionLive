package com.aliyun.aliinteraction.uikit.component;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.core.base.Actions;
import com.alivc.auimessage.model.base.AUIMessageModel;
import com.alivc.auimessage.model.lwp.GetGroupInfoResponse;
import com.aliyun.aliinteraction.roompaas.message.listener.SimpleOnMessageListener;
import com.aliyun.aliinteraction.roompaas.message.model.LiveRoomInfoUpdateModel;
import com.aliyun.aliinteraction.uikit.R;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.uibase.util.AppUtil;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auipusher.LiveContext;

import java.util.Locale;

public class LiveCountInfoComponent extends FrameLayout implements ComponentHolder {

    private final Component component = new Component();
    private final TextView anchorCount;

    public LiveCountInfoComponent(@NonNull final Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        setMinimumHeight(AppUtil.dp(24));
        setBackgroundResource(R.drawable.ilr_bg_anchor_profile);
        inflate(context, R.layout.ilr_view_live_count_info, this);
        anchorCount = findViewById(R.id.anchor_count);
    }

    /**
     * 设置观看人数
     *
     * @param count 观看人数
     */
    public void setViewCount(long count) {
        anchorCount.setText(formatNumber(count));
    }

    private String formatNumber(long number) {
        if ((number < 0)) {
            // 兜底保护
            return String.valueOf(0);
        } else if (number >= 10000) {
            // 1w+ 格式化
            return String.format(Locale.getDefault(), "%.1fw", number / 10000f);
        } else {
            return String.valueOf(number);
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

            // 监听互动信息变化
            getMessageService().addMessageListener(new SimpleOnMessageListener() {
                @Override
                public void onPVReceived(AUIMessageModel<LiveRoomInfoUpdateModel> message) {
                    super.onPVReceived(message);
                    if (message != null && message.data != null) {
                        LiveRoomInfoUpdateModel liveRoomInfoUpdateModel = message.data;
                        setViewCount(liveRoomInfoUpdateModel.pv);
                    }
                }
            });
        }

        @Override
        public void onEnterRoomSuccess(LiveModel liveModel) {
            // 进入房间后, 填充房间基本信息
            // TODO keria 客户反馈这地方有问题
            setViewCount(liveModel.pv);
        }

        @Override
        public void onEvent(String action, Object... args) {
            super.onEvent(action, args);
            switch (action) {
                case Actions.IMMERSIVE_PLAYER: {
                    if (args[0].equals(true)) {
                        setVisibility(View.GONE);
                    } else {
                        setVisibility(View.VISIBLE);
                    }
                    break;
                }
                case Actions.GET_GROUP_STATISTICS_SUCCESS: {
                    if (args.length > 0 && args[0] instanceof GetGroupInfoResponse) {
                        GetGroupInfoResponse rsp = (GetGroupInfoResponse) args[0];
                        setViewCount(rsp.pv);
                    }
                    break;
                }
                default:
                    break;
            }
        }
    }
}
