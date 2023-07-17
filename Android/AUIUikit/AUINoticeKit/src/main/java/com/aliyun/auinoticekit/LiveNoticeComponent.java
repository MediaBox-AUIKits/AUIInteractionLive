package com.aliyun.auinoticekit;

import android.content.Context;
import android.graphics.Color;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.common.base.util.CommonUtil;
import com.aliyun.aliinteraction.roompaas.message.listener.SimpleOnMessageListener;
import com.aliyun.aliinteraction.roompaas.message.model.UpdateNoticeModel;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.uibase.util.AppUtil;
import com.aliyun.aliinteraction.uikit.uibase.util.DialogUtil;
import com.aliyun.auiappserver.AppServerApi;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auiappserver.model.UpdateLiveRequest;
import com.aliyun.auipusher.LiveContext;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.model.base.AUIMessageModel;
import com.alivc.auimessage.model.base.InteractionError;


/**
 * 直播公告视图, 封装直播视图的展开收起状态
 *
 * @author puke
 * @version 2021/6/30
 */
public class LiveNoticeComponent extends LinearLayout implements ComponentHolder {

    private static final String PLACE_HOLDER = "向观众介绍你的直播间吧～";

    private final Component component = new Component();
    private final View expand;
    private final View occupy;
    private final View edit;
    private final TextView notice;

    private boolean isExpand = false;
    private String content;
    private LiveModel mLiveModel;

    public LiveNoticeComponent(@NonNull final Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        setOrientation(VERTICAL);
        setMinimumHeight(AppUtil.dp(20f));
        setBackgroundResource(R.drawable.ilr_bg_live_notice);
        inflate(context, R.layout.ilr_view_live_notice, this);

        expand = findViewById(R.id.view_expand);
        occupy = findViewById(R.id.view_occupy);
        edit = findViewById(R.id.view_edit);
        notice = findViewById(R.id.view_notice);
        refreshView();

        setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                isExpand = !isExpand;
                refreshView();
            }
        });

        edit.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!component.isOwner()) {
                    return;
                }

                String currentNotice = getNotice();
                DialogUtil.input(context, "更改房间公告", currentNotice, new DialogUtil.InputCallback() {
                    @Override
                    public void onInput(String value) {
                        component.updateNotice(value);
                    }
                });
            }
        });
    }

    public void setExpand(boolean expand) {
        if (isExpand != expand) {
            isExpand = expand;
            refreshView();
        }
    }

    private void refreshView() {
        if (isExpand) {
            // 展开
            expand.setVisibility(GONE);
            occupy.setVisibility(VISIBLE);
            edit.setVisibility(component.isOwner() ? VISIBLE : GONE);
            notice.setVisibility(VISIBLE);
        } else {
            // 收起
            expand.setVisibility(VISIBLE);
            occupy.setVisibility(GONE);
            edit.setVisibility(GONE);
            notice.setVisibility(GONE);
        }

        ViewGroup.LayoutParams layoutParams = getLayoutParams();
        if (layoutParams != null) {
            layoutParams.width = isExpand ? AppUtil.dp(166) : ViewGroup.LayoutParams.WRAP_CONTENT;
            setLayoutParams(layoutParams);
        }
    }

    public String getNotice() {
        return content;
    }

    /**
     * 设置公告内容
     *
     * @param content 公告内容
     */
    public void setNotice(String content) {
        this.content = content;
        if (TextUtils.isEmpty(content)) {
            notice.setTextColor(Color.parseColor("#E7E7E7"));
            notice.setText(PLACE_HOLDER);
        } else {
            notice.setTextColor(Color.WHITE);
            notice.setText(content);
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
            setNotice(liveContext.getLiveModel().notice);
            getMessageService().addMessageListener(new SimpleOnMessageListener() {

                @Override
                public void onNoticeUpdate(AUIMessageModel<UpdateNoticeModel> message) {
                    setNotice(message.data.notice);
                }
            });
        }

        @Override
        public void onEnterRoomSuccess(LiveModel liveModel) {
            mLiveModel = liveModel;
            refreshView();
        }

        private void updateNotice(String notice) {
            if (TextUtils.isEmpty(notice)) {
                CommonUtil.showToast(getContext(), "更新失败，公告内容不能为空");
                return;
            }
            UpdateLiveRequest updateLiveRequest = new UpdateLiveRequest();
            updateLiveRequest.id = mLiveModel.id;
            //updateLiveRequest.anchor = liveContext.anchorId;
            updateLiveRequest.title = mLiveModel.title;
            updateLiveRequest.extend = mLiveModel.extend;
            updateLiveRequest.notice = notice;
            AppServerApi.instance().updateLive(updateLiveRequest).invoke(new InteractionCallback<LiveModel>() {
                @Override
                public void onSuccess(LiveModel data) {
                    showToast("更新公告成功");
                }

                @Override
                public void onError(InteractionError error) {
                    showToast("更新公告失败, " + error.msg);
                }
            });
            setNotice(notice);
            getMessageService().updateNotice(notice, null);
        }
    }
}
