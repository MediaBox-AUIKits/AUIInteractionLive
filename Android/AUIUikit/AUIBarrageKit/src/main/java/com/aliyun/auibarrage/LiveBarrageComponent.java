package com.aliyun.auibarrage;

import android.content.Context;
import android.graphics.Color;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.util.AttributeSet;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.alibaba.fastjson.JSON;
import com.alivc.auicommon.common.base.log.Logger;
import com.alivc.auicommon.common.base.util.CommonUtil;
import com.alivc.auicommon.common.roombase.Const;
import com.alivc.auicommon.core.base.Actions;
import com.alivc.auicommon.core.base.LimitSizeRecyclerView;
import com.alivc.auicommon.core.base.MessageModel;
import com.alivc.auicommon.core.utils.MessageHelper;
import com.aliyun.aliinteraction.roompaas.message.listener.SimpleOnMessageListener;
import com.aliyun.aliinteraction.roompaas.message.model.CommentModel;
import com.aliyun.aliinteraction.roompaas.message.model.StartLiveModel;
import com.aliyun.aliinteraction.roompaas.message.model.StopLiveModel;
import com.aliyun.aliinteraction.uikit.core.AppConfig;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.core.LiveConst;
import com.aliyun.aliinteraction.uikit.uibase.helper.RecyclerViewHelper;
import com.aliyun.aliinteraction.uikit.uibase.util.AppUtil;
import com.aliyun.auipusher.LiveContext;
import com.alivc.auimessage.model.base.AUIMessageModel;
import com.alivc.auimessage.model.message.MuteGroupMessage;
import com.alivc.auimessage.model.message.UnMuteGroupMessage;
import com.aliyun.auipusher.config.LiveEvent;
import com.aliyun.auipusher.manager.LiveLinkMicPushManager;

import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * @author puke
 * @version 2021/7/29
 */
public class LiveBarrageComponent extends RelativeLayout implements ComponentHolder {

    private static final String TAG = LiveBarrageComponent.class.getSimpleName();
    private static final int NICK_SHOW_MAX_LENGTH = 15;
    private static final String WELCOME_TEXT = "欢迎来到直播间，直播内容和评论禁止政治、低俗色情、吸烟酗酒或发布虚假信息等内容，若有违反将禁播、封停账号。";

    protected final FlyView flyView;
    protected final LimitSizeRecyclerView recyclerView;

    private final MessageHelper<MessageModel> messageHelper;
    private final Component component = new Component();
    private final LinearLayoutManager layoutManager;
    private final RecyclerViewHelper<MessageModel> recyclerViewHelper;
    private final int commentMaxHeight = AppUtil.getScreenHeight() / 3;
    private final Runnable refreshUITask = new Runnable() {
        @Override
        public void run() {
            recyclerView.invalidate();
        }
    };

    private int lastPosition;
    private boolean forceHover;

    public LiveBarrageComponent(Context context) {
        this(context, null, 0);
    }

    public LiveBarrageComponent(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveBarrageComponent(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);

        View.inflate(context, R.layout.ilr_view_live_message, this);
        flyView = findViewById(R.id.message_fly_view);
        recyclerView = findViewById(R.id.message_recycler_view);

        // 弹幕面板
        recyclerView.setMaxHeight(commentMaxHeight);
        layoutManager = new LinearLayoutManager(context);
        layoutManager.setStackFromEnd(true);
        recyclerView.setLayoutManager(layoutManager);
        recyclerViewHelper = RecyclerViewHelper.of(recyclerView, R.layout.ilr_item_message,
                new RecyclerViewHelper.HolderRenderer<MessageModel>() {
                    @Override
                    public void render(RecyclerViewHelper<MessageModel> viewHelper, RecyclerViewHelper.ViewHolder holder, final MessageModel model, int position, int itemCount, List<Object> payloads) {
                        TextView content = holder.getView(R.id.item_content);
                        content.setMovementMethod(new LinkMovementMethod());
                        content.setTextColor(model.contentColor);

                        if (TextUtils.isEmpty(model.userNick)) {
                            content.setText(model.content);
                        } else {
                            String prefix = model.userNick + "：";
                            String postfix = model.content;

                            SpannableString spannableString = new SpannableString(prefix + postfix);
                            spannableString.setSpan(new ForegroundColorSpan(model.color), 0,
                                    prefix.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
                            if (component.isOwner()) {
                                ClickableSpan clickableSpan = new ClickableSpan() {
                                    @Override
                                    public void onClick(@NonNull View widget) {
                                        component.handleUserClick(model);
                                    }

                                    @Override
                                    public void updateDrawState(@NonNull TextPaint ds) {
                                        ds.setUnderlineText(false);
                                    }
                                };
                                spannableString.setSpan(clickableSpan,
                                        0, prefix.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
                            }
                            content.setText(spannableString);
                        }

                        content.setOnLongClickListener(new OnLongClickListener() {
                            @Override
                            public boolean onLongClick(View v) {
                                if (!TextUtils.isEmpty(model.userId)) {
                                    // do something
                                }
                                return true;
                            }
                        });

                        content.setOnClickListener(new OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                if (!TextUtils.isEmpty(model.userId)) {
                                    // do something
                                }
                            }
                        });
                    }
                });

        // 维度消息控制逻辑
        recyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(RecyclerView recyclerView, int newState) {
                refreshUnreadTips();
            }

            @Override
            public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
                forceHover = false;
                refreshUnreadTips();
            }
        });

        // 消息控制辅助类
        messageHelper = new MessageHelper<MessageModel>()
                .setCallback(new MessageHelper.Callback<MessageModel>() {
                    @Override
                    public int getTotalSize() {
                        return recyclerViewHelper.getItemCount();
                    }

                    @Override
                    public void onMessageAdded(MessageModel message) {
                        addMessageToPanel(Collections.singletonList(message));
                    }

                    @Override
                    public void onMessageRemoved(int suggestRemoveCount) {
                        lastPosition -= suggestRemoveCount;
                        if (forceHover) {
                            postDelayed(new Runnable() {
                                @Override
                                public void run() {
                                    forceHover = true;
                                }
                            }, 10);
                        }
                        recyclerViewHelper.removeDataWithoutAnimation(0, suggestRemoveCount);
                    }
                });


    }

    protected static String truncateNick(String nick) {
        if (!TextUtils.isEmpty(nick) && nick.length() > NICK_SHOW_MAX_LENGTH) {
            nick = nick.substring(0, NICK_SHOW_MAX_LENGTH);
        }
        return nick;
    }

    /**
     * @return 是否开启未读提示条逻辑
     */
    protected boolean enableUnreadTipsLogic() {
        return true;
    }

    /**
     * @return 是否开启系统消息显示逻辑
     */
    protected boolean enableSystemLogic() {
        return true;
    }

    private void refreshUnreadTips() {
        if (!enableUnreadTipsLogic()) {
            // 未开启未读提示条逻辑时, 不做额外处理
            return;
        }

        int itemCount = recyclerViewHelper.getItemCount();
        int lastVisibleItemPosition = layoutManager.findLastVisibleItemPosition();
        if (lastPosition >= itemCount) {
            lastPosition = lastVisibleItemPosition;
        } else {
            lastPosition = Math.max(lastVisibleItemPosition, lastPosition);
        }

        if (forceHover || (lastPosition >= 0 && lastPosition < itemCount - 1)) {
            // 一旦悬停, 就要等到列表滚动后, 才能解除悬停状态
            forceHover = true;
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int height = MeasureSpec.getSize(heightMeasureSpec);
        final int maxMessageHeight;
        if (component.isLandscape()) {
            // 横屏
            maxMessageHeight = AppUtil.getScreenHeight() / 3;
            // 宽度为屏幕一半
            widthMeasureSpec = MeasureSpec.makeMeasureSpec(
                    AppUtil.getScreenWidth() / 2, MeasureSpec.getMode(widthMeasureSpec)
            );
        } else {
            // 竖屏
            int systemMaxHeight = enableSystemLogic() ? (getResources().getDimensionPixelOffset(R.dimen.live_message_fly_height) + getResources().getDimensionPixelOffset(R.dimen.message_fly_bottom_margin)) : 0;
            maxMessageHeight = commentMaxHeight + systemMaxHeight;
        }
        if (height > maxMessageHeight) {
            heightMeasureSpec = MeasureSpec.makeMeasureSpec(
                    maxMessageHeight, MeasureSpec.getMode(heightMeasureSpec)
            );
        }
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    }

    protected void addSystemMessage(CharSequence content) {
        FlyView.FlyItem item = new FlyView.FlyItem();
        item.content = content;
        addSystemMessage(item);
    }

    protected void addSystemMessage(FlyView.FlyItem item) {
        if (enableSystemLogic()) {
            // 开启系统消息显示逻辑, 才做处理
            flyView.addItem(item);
        }
    }

    protected void addMessage(String type, String content) {
        addMessage(new MessageModel(type, content));
    }

    protected void addMessage(MessageModel messageModel) {
        messageHelper.addMessage(messageModel);
    }

    protected void addMessageByUserId(String userId, String type, String content) {
        messageHelper.addMessage(new MessageModel(userId, type, content));
    }

    /**
     * 弹幕信息添加到面板
     *
     * @param addedList 弹幕信息
     */
    protected void addMessageToPanel(final List<MessageModel> addedList) {
        boolean isLastCompletelyVisible = layoutManager.findLastVisibleItemPosition()
                == recyclerViewHelper.getItemCount() - 1;
        recyclerViewHelper.addData(addedList);
        if (!forceHover && isLastCompletelyVisible) {
            // 已触底时, 随消息联动
            layoutManager.scrollToPositionWithOffset(
                    recyclerViewHelper.getItemCount() - 1, Integer.MIN_VALUE);
            postDelayed(refreshUITask, 100);
            lastPosition = 0;
        } else {
            refreshUnreadTips();
        }
    }

    /**
     * @return 首条系统消息 (返回null时, 不展示)
     */
    @Nullable
    protected MessageModel getSystemAlertMessageModel() {
        MessageModel systemMessage = new MessageModel(
                LiveConst.SYSTEM_NOTICE_NICKNAME, LiveConst.SYSTEM_NOTICE_ALERT);
        systemMessage.contentColor = Color.parseColor("#12DBE6");
        return systemMessage;
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private class Component extends BaseComponent {

        private void innerStopLive() {
            if (!isOwner()) {
                addSystemMessage("直播已结束");
            }
        }

        @Override
        public void onInit(LiveContext liveContext) {
            super.onInit(liveContext);

            // 回放不展示信息面板
            setVisibility(VISIBLE);

            if (!needPlayback()) {
                MessageModel model = new MessageModel(null, WELCOME_TEXT);
                model.contentColor = Color.parseColor("#A4E0A7");
                addMessageToPanel(Collections.singletonList(model));
            }

            liveContext.getLiveLinkMicPushManager().setCallback(new LiveLinkMicPushManager.Callback() {
                @Override
                public void onEvent(LiveEvent event, @Nullable Map<String, Object> extras) {
                    switch (event) {
                        case LIVE_PLAYER_ERROR:
                            if (!isOwner()) {
                                innerStopLive();
                            }
                            break;
                    }
                }
            });

            getMessageService().addMessageListener(new SimpleOnMessageListener() {
                @Override
                public void onCommentReceived(AUIMessageModel<CommentModel> message) {
                    String senderId = message.senderInfo.userId;
                    if (AppConfig.INSTANCE.showSelfCommentFromLocal()
                            && TextUtils.equals(senderId, Const.getUserId())) {
                        // 自己发送的消息不做上屏显示
                        return;
                    }
                    String nick = truncateNick(message.senderInfo.userNick);
                    addMessageByUserId(senderId, nick, message.data.content);
                }

                @Override
                public void onStopLive(AUIMessageModel<StopLiveModel> message) {
                    innerStopLive();
                }

                @Override
                public void onStartLive(AUIMessageModel<StartLiveModel> message) {
                    if (!isOwner()) {
                        addSystemMessage("直播已开始");
                    }
                }

                @Override
                public void onMuteGroup(AUIMessageModel<MuteGroupMessage> message) {
                    super.onMuteGroup(message);
                    addSystemMessage("主播开启了全体禁言");
                }

                @Override
                public void onUnMuteGroup(AUIMessageModel<UnMuteGroupMessage> message) {
                    super.onUnMuteGroup(message);
                    addSystemMessage("主播取消了全体禁言");
                }

                @Override
                public void onRawMessageReceived(AUIMessageModel<String> message) {
                    // 监听全部消息, 仅用于开发测试阶段
                    if (AppConfig.INSTANCE.enableAllMessageReceived()) {
                        addMessageToPanel(Collections.singletonList(new MessageModel(
                                message.senderInfo.userId,
                                String.format("Raw(%s)", message.type),
                                message.data
                        )));
                    }
                }
            });
        }

        @Override
        public void onEvent(String action, Object... args) {
            if (Actions.SHOW_MESSAGE.equals(action)) {
                if (!AppConfig.INSTANCE.showSelfCommentFromLocal()) {
                    // 非本地上屏, 不处理
                    return;
                }

                if (args.length >= 1) {
                    MessageModel messageModel = (MessageModel) args[0];
                    // 判断是否忽略弹幕频率限制
                    boolean ignoreFreqLimit = args.length > 1 && Boolean.TRUE.equals(args[1]);
                    if (ignoreFreqLimit) {
                        // 忽略限流控制时, 直接上屏
                        addMessageToPanel(Collections.singletonList(messageModel));
                    } else {
                        // 默认是交给消息流控
                        addMessage(messageModel);
                    }
                } else {
                    Logger.w(TAG, "Received invalid message param: " + JSON.toJSONString(args));
                }
            }
        }

        @Override
        public void onActivityDestroy() {
            if (messageHelper != null) {
                messageHelper.destroy();
            }
        }

        private void handleUserClick(final MessageModel model) {
            String userId = model.userId;
            if (TextUtils.isEmpty(userId)) {
                CommonUtil.showToast(getContext(), "用户ID为空");
                return;
            }

            // 当前不做点对点禁言
        }
    }
}
