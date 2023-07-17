package com.aliyun.auilinkmickit;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.alivc.auicommon.common.base.base.Function;
import com.alivc.auicommon.common.base.log.Logger;
import com.alivc.auicommon.common.base.util.CollectionUtil;
import com.alivc.auicommon.common.base.util.ThreadUtil;
import com.alivc.auicommon.core.base.Actions;
import com.aliyun.aliinteraction.roompaas.message.listener.SimpleOnMessageListener;
import com.aliyun.aliinteraction.roompaas.message.model.CameraStatusUpdateModel;
import com.aliyun.aliinteraction.roompaas.message.model.HandleApplyJoinLinkMicModel;
import com.aliyun.aliinteraction.roompaas.message.model.JoinLinkMicModel;
import com.aliyun.aliinteraction.roompaas.message.model.KickUserFromLinkMicModel;
import com.aliyun.aliinteraction.roompaas.message.model.LeaveLinkMicModel;
import com.aliyun.aliinteraction.roompaas.message.model.MicStatusUpdateModel;
import com.aliyun.aliinteraction.roompaas.message.model.StartLiveModel;
import com.aliyun.aliinteraction.roompaas.message.model.StopLiveModel;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.core.MultiComponentHolder;
import com.aliyun.aliinteraction.uikit.uibase.helper.RecyclerViewHelper;
import com.aliyun.aliinteraction.uikit.uibase.util.AppUtil;
import com.aliyun.aliinteraction.uikit.uibase.util.DialogUtil;
import com.aliyun.aliinteraction.uikit.uibase.util.ViewUtil;
import com.aliyun.auiappserver.AppServerApi;
import com.aliyun.auiappserver.model.GetMeetingInfoRequest;
import com.aliyun.auiappserver.model.LinkMicItemModel;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auiappserver.model.MeetingInfo;
import com.aliyun.auipusher.LiveContext;
import com.aliyun.auipusher.config.LiveEvent;
import com.aliyun.auipusher.manager.LiveLinkMicPushManager;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.model.base.AUIMessageModel;
import com.alivc.auimessage.model.base.InteractionError;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * @author puke
 * @version 2022/9/29
 */
public class LiveLinkMicRenderComponent extends FrameLayout implements MultiComponentHolder {

    public static final Object PAYLOAD_REFRESH_MIC_STATUS = new Object();

    private static final int SPAN_COUNT = 6;

    private final Component component = new Component();
    private final LinkMicManageController linkMicManageController;
    private final RecyclerViewHelper<LinkMicItemModel> recyclerViewHelper;
    private FrameLayout previewContainer;
    private LiveModel liveModel;
    private String anchorId;
    private LiveLinkMicPushManager pushManager;
    private boolean isJoinedLinkMic;
    private boolean isApplying;

    public LiveLinkMicRenderComponent(@NonNull Context context) {
        this(context, null, 0);
    }

    public LiveLinkMicRenderComponent(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public LiveLinkMicRenderComponent(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        previewContainer = new FrameLayout(context);
        inflate(context, R.layout.ilr_view_live_link_mic, this);
        final RecyclerView recyclerView = findViewById(R.id.link_mic_container);
        final GridLayoutManager layoutManager = new GridLayoutManager(context, SPAN_COUNT);
        layoutManager.setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
            @Override
            public int getSpanSize(int position) {
                int itemCount = recyclerViewHelper.getItemCount();
                if (itemCount <= 4) {
                    return 3;
                } else {
                    return 2;
                }
            }
        });
        recyclerView.setLayoutManager(layoutManager);

        recyclerViewHelper = RecyclerViewHelper.of(recyclerView, R.layout.ilr_item_link_mic,
                new RecyclerViewHelper.HolderRenderer<LinkMicItemModel>() {
                    @Override
                    public void render(RecyclerViewHelper<LinkMicItemModel> viewHelper, final RecyclerViewHelper.ViewHolder holder, LinkMicItemModel model, int position, int itemCount, List<Object> payloads) {
                        if (payloads.contains(PAYLOAD_REFRESH_MIC_STATUS)) {
                            // 局部刷新麦克风状态
                            holder.getView(R.id.item_mic).setSelected(model.micOpened);
                            return;
                        }

                        if (component.isOwner()) {
                            if (itemCount == 1) {
                                // 主播端只有一个视图, 不做刷新
                                return;
                            } else {
                                View previewView = component.getAnchorPreviewView();
                                ViewParent parent = previewView.getParent();
                                if (parent != null) {
                                    ((ViewGroup) parent).removeView(previewView);
                                }
                                previewContainer.removeAllViews();
                                previewContainer.addView(previewView);
                            }
                        }

                        // 设置布局
                        MarginLayoutParams layoutParams = (MarginLayoutParams) holder.itemView.getLayoutParams();
                        int totalWidth = AppUtil.getScreenWidth() - 2 * getResources().getDimensionPixelOffset(R.dimen.ilr_link_mic_item_margin);
                        int spanSize = layoutManager.getSpanSizeLookup().getSpanSize(position);
                        final int itemSize = totalWidth * spanSize / SPAN_COUNT;

                        // 设置正方形展示
                        layoutParams.width = itemSize;
                        layoutParams.height = itemSize;

                        // 设置左侧偏移
                        int columns = SPAN_COUNT / spanSize;
                        boolean gridFilled = itemCount % columns == 0;
                        int secondLastRowValve = (int) Math.floor(itemCount * 1f / columns);
                        float actualRow = (position + 1f) / columns;
                        boolean isLastRow = actualRow > secondLastRowValve;
                        if (!gridFilled && isLastRow) {
                            int itemCountOfLastRow = itemCount % columns;
                            int totalWidthOfHolderView = itemCountOfLastRow * itemSize;
                            layoutParams.leftMargin = (totalWidth - totalWidthOfHolderView) / 2;
                        } else {
                            layoutParams.leftMargin = 0;
                        }

                        holder.itemView.setLayoutParams(layoutParams);

                        boolean isAnchor = TextUtils.equals(model.userId, anchorId);
                        holder.getView(R.id.item_anchor_flag).setVisibility(isAnchor ? VISIBLE : GONE);

                        FrameLayout container = holder.getView(R.id.item_container);
                        container.removeAllViews();
                        TextView nick = holder.getView(R.id.item_nick);
                        nick.setText(model.userNick);

                        holder.getView(R.id.item_mic).setSelected(model.micOpened);

                        Logger.i("XXXXXX", String.format("userId=%s, container=%s", model.userId, Integer.toHexString(container.hashCode())));
                        boolean isSelf = TextUtils.equals(model.userId, component.getUserId());
                        if (isSelf) {
                            // 自己的画面
                            ViewParent parent = previewContainer.getParent();
                            if (parent != container) {
                                if (parent != null) {
                                    ((ViewGroup) parent).removeView(previewContainer);
                                }
                                container.addView(previewContainer);
                            }
                        } else {
                            // 别人的画面
                            String rtcPullUrl = model.rtcPullUrl;
                            if (TextUtils.isEmpty(rtcPullUrl)) {
                                container.removeAllViews();
                            } else {
                                // 暂存key-player的映射关系
                                pushManager.linkMic(container, rtcPullUrl);
                            }
                        }
                    }
                }
        );

        linkMicManageController = new LinkMicManageController(context, new LinkMicManageController.Callback() {
            @Override
            public LinkMicItemModel getAnchorItemModel() {
                List<LinkMicItemModel> dataList = recyclerViewHelper.getDataList();
                int anchorIndex = CollectionUtil.findIndex(dataList, new Function<LinkMicItemModel, Boolean>() {
                    @Override
                    public Boolean apply(LinkMicItemModel model) {
                        return TextUtils.equals(model.userId, LiveLinkMicRenderComponent.this.anchorId);
                    }
                });
                return anchorIndex >= 0 ? dataList.get(anchorIndex) : null;
            }
        });
    }

    @Override
    public List<IComponent> getComponents() {
        return Arrays.asList(component, linkMicManageController.getComponent());
    }

    private class Component extends BaseComponent {

        @Override
        public void onInit(final LiveContext liveContext) {
            super.onInit(liveContext);
            if (!supportLinkMic()) {
                return;
            }

            liveModel = liveContext.getLiveModel();
            anchorId = liveModel.anchorId;
            pushManager = liveContext.getLiveLinkMicPushManager();
            pushManager.setCallback(new LiveLinkMicPushManager.Callback() {
                @Override
                public void onEvent(LiveEvent event, @Nullable Map<String, Object> extras) {
                    switch (event) {
                        case PUSH_STARTED:
                            // 拉流 todo
                            // pushManager.linkMic(bigContainer, anchorPullUrl);
                            break;
                    }
                }
            });

            liveContext.getMessageService().addMessageListener(new SimpleOnMessageListener() {

                @Override
                public void onStartLive(AUIMessageModel<StartLiveModel> message) {
                    if (isOwner()) {
                        // 混流
                        pushManager.addAnchorMixTranscodingConfig(liveContext.getLiveModel().anchorId);
                    }
                }

                @Override
                public void onStopLive(AUIMessageModel<StopLiveModel> message) {
                    postEvent(Actions.LEAVE_LINK_MIC);
                }

                @Override
                public void onHandleApplyJoinLinkMic(final AUIMessageModel<HandleApplyJoinLinkMicModel> message) {
                    if (isOwner()) {
                        // 主播不处理该事件
                        return;
                    }

                    if (!isApplying) {
                        // 我申请后又取消申请, 此时即使主播同意, 我也不响应处理
                        return;
                    }

                    HandleApplyJoinLinkMicModel model = message.data;
                    if (!model.agree) {
                        showToast("主播拒绝了您的连麦申请");
                        return;
                    }

                    if (isJoinedLinkMic) {
                        // 业务异常, 不做处理
                        return;
                    }

                    DialogUtil.confirm(getContext(), "连麦申请通过，是否开始连麦？",
                            new Runnable() {
                                @Override
                                public void run() {
                                    // 确认上麦
                                    GetMeetingInfoRequest request = new GetMeetingInfoRequest();
                                    request.id = getLiveId();
                                    AppServerApi.instance().getMeetingInfo(request).invoke(new InteractionCallback<MeetingInfo>() {
                                        @Override
                                        public void onSuccess(MeetingInfo meetingInfo) {
                                            List<LinkMicItemModel> members = meetingInfo == null ? null : meetingInfo.members;
                                            if (CollectionUtil.size(members) < LinkMicManageController.maxLinkMicLimit) {
                                                // 没达到限制, 执行正常上麦操作
                                                performJoinLinkMic(message);
                                            } else {
                                                // 达到最大人数限制, 不再上麦
                                                showToast("当前连麦人数已经超过最大限制");
                                                isApplying = false;
                                                postEvent(Actions.JOIN_BUT_MAX_LIMIT_WHEN_ANCHOR_AGREE);
                                            }
                                        }

                                        @Override
                                        public void onError(InteractionError error) {
                                            showToast(error.msg);
                                            isApplying = false;
                                            postEvent(Actions.GET_MEMBERS_FAIL_WHEN_ANCHOR_AGREE);
                                        }
                                    });
                                }
                            },
                            new Runnable() {
                                @Override
                                public void run() {
                                    // 取消上麦
                                    isApplying = false;
                                    postEvent(Actions.REJECT_JOIN_LINK_MIC_WHEN_ANCHOR_AGREE);
                                }
                            }
                    );
                }

                private void performJoinLinkMic(AUIMessageModel<HandleApplyJoinLinkMicModel> message) {
                    // 显示当前视图
                    List<LinkMicItemModel> initDataList = new ArrayList<>();

                    // 更新RecyclerView中自己的预览图
                    pushManager.startPreview(previewContainer);
                    String myUserId = getUserId();
                    LinkMicItemModel selfItem = new LinkMicItemModel();
                    selfItem.userId = myUserId;
                    selfItem.userNick = liveContext.getNick();
                    selfItem.micOpened = true;
                    selfItem.cameraOpened = true;
                    initDataList.add(selfItem);

                    recyclerViewHelper.setData(initDataList);

                    updateVisible();

                    // 推流
                    pushManager.startPublish(liveModel.linkInfo.rtcPushUrl);
                    // 通知LiveRenderView结束cdn拉流
                    postEvent(Actions.JOIN_LINK_MIC);
                    // 改状态
                    isApplying = false;

                    // todo 通过延时模拟推流成功
                    ThreadUtil.postUiDelay(300, new Runnable() {
                        @Override
                        public void run() {
                            afterPushSuccess();
                        }
                    });
                }

                @Override
                public void onJoinLinkMic(final AUIMessageModel<JoinLinkMicModel> message) {
                    boolean isSelf = TextUtils.equals(message.senderInfo.userId, getUserId());
//                    if (isSelf) {
//                        // 忽略自己的上麦通知消息
//                        return;
//                    }

                    if (isOwner()) {
                        // 混流
                        ThreadUtil.postUiDelay(500, new Runnable() {
                            @Override
                            public void run() {
                                updateMixStreamLayout();
                            }
                        });
                    } else {
                        // 观众
                        if (!isJoinedLinkMic) {
                            // 自己未上麦, 不处理
                            return;
                        }
                    }

                    // 去重处理, 移除已经存在的麦上观众
                    int indexOfAlreadyExistUserId = findIndexFromRecyclerView(message.senderInfo.userId);
                    if (indexOfAlreadyExistUserId >= 0) {
                        recyclerViewHelper.removeData(indexOfAlreadyExistUserId);
                    }

                    // 开始拉别人上麦的流
                    LinkMicItemModel otherItem = new LinkMicItemModel();
                    otherItem.userId = message.senderInfo.userId;
                    otherItem.userNick = message.senderInfo.userNick;
                    otherItem.userAvatar = message.senderInfo.userAvatar;
                    otherItem.rtcPullUrl = message.data.rtcPullUrl;
                    otherItem.micOpened = true;
                    otherItem.cameraOpened = true;
                    recyclerViewHelper.addDataWithoutAnimation(Collections.singletonList(otherItem));

                    updateVisible();
                }

                @Override
                public void onMicStatusUpdate(AUIMessageModel<MicStatusUpdateModel> message) {
                    if (isOwner() || isJoinedLinkMic) {
                        List<LinkMicItemModel> dataList = recyclerViewHelper.getDataList();
                        for (int i = 0; i < dataList.size(); i++) {
                            LinkMicItemModel model = dataList.get(i);
                            if (TextUtils.equals(model.userId, message.senderInfo.userId)) {
                                // 更新表格视图
                                model.micOpened = message.data.micOpened;
                                recyclerViewHelper.updateData(i, PAYLOAD_REFRESH_MIC_STATUS);
                            }
                        }
                    }
                }

                @Override
                public void onCameraStatusUpdate(AUIMessageModel<CameraStatusUpdateModel> message) {
                    if (isOwner() || isJoinedLinkMic) {
                        List<LinkMicItemModel> dataList = recyclerViewHelper.getDataList();
                        for (int i = 0; i < dataList.size(); i++) {
                            LinkMicItemModel model = dataList.get(i);
                            if (TextUtils.equals(model.userId, message.senderInfo.userId)) {
                                model.cameraOpened = message.data.cameraOpened;
                                recyclerViewHelper.updateData(i);
                            }
                        }
                    }
                }

                @Override
                public void onLeaveLinkMic(final AUIMessageModel<LeaveLinkMicModel> message) {
                    // 停止下麦观众的拉流; 移除布局;
                    if (isOwner() || isJoinedLinkMic) {
                        int leaveIndex = findIndexFromRecyclerView(message.senderInfo.userId);
                        if (leaveIndex >= 0) {
                            // 停止拉当前用户的流
                            LinkMicItemModel model = recyclerViewHelper.getDataList().get(leaveIndex);
                            getLiveLinkMicPushManager().stopPull(model.rtcPullUrl);
                            // 移除RecyclerView布局
                            recyclerViewHelper.removeDataWithoutAnimation(leaveIndex, 1);
                            updateVisible();
                        }
                    }

                    if (isOwner()) {
                        // 主播移除下麦观众的混流
                        ThreadUtil.postUiDelay(500, new Runnable() {
                            @Override
                            public void run() {
                                updateMixStreamLayout();
                            }
                        });
                    }
                }

                @Override
                public void onKickUserFromLinkMic(AUIMessageModel<KickUserFromLinkMicModel> message) {
                    if (isJoinedLinkMic) {
                        postEvent(Actions.KICK_LINK_MIC);
                    }
                }
            });
        }

        private int findIndexFromRecyclerView(String userId) {
            List<LinkMicItemModel> dataList = recyclerViewHelper.getDataList();
            return LinkMicItemModel.findIndexByUserId(dataList, userId);
        }

        // 更新表格布局的可见性
        private void updateVisible() {
            int itemCount = recyclerViewHelper.getItemCount();
            if (itemCount <= 0) {
                setVisibility(GONE);
                return;
            }

            if (isOwner()) {
                if (itemCount == 1) {
                    // 麦上一个人
                    setVisibility(GONE);
                    liveContext.getAnchorPreviewHolder().returnBigContainer();
                } else {
                    // 麦上多个人
                    setVisibility(VISIBLE);
                }
            } else {
                setVisibility(VISIBLE);
            }
        }

        private void returnAnchorPreviewViewIfNeed() {
//            previewContainer
        }

        // 推流成功之后
        private void afterPushSuccess() {
            updateVisible();
            // 1. 更改内部状态
            isJoinedLinkMic = true;

            // 2. 通知别人, 自己已上麦
            getMessageService().joinLinkMic(liveModel.linkInfo.rtcPullUrl, null);

            // 3. 开始拉已上麦观众的流
            GetMeetingInfoRequest infoRequest = new GetMeetingInfoRequest();
            infoRequest.id = getLiveId();
            AppServerApi.instance().getMeetingInfo(infoRequest).invoke(new InteractionCallback<MeetingInfo>() {
                @Override
                public void onSuccess(MeetingInfo meetingInfo) {
                    List<LinkMicItemModel> members = meetingInfo.members;
                    if (CollectionUtil.isEmpty(members)) {
                        return;
                    }

                    List<LinkMicItemModel> holderModels = new ArrayList<>();
                    Set<String> userIds = new HashSet<>();
                    // 添加已在麦上的成员
                    for (LinkMicItemModel model : members) {
                        String userId = model.userId;
                        if (userIds.contains(userId)) {
                            // 去重
                            continue;
                        }
                        if (isOwner() && TextUtils.equals(userId, anchorId)) {
                            // 主播端不再重复展示自己的画面
                            continue;
                        }
                        holderModels.add(model);
                        userIds.add(userId);
                    }
                    // 添加当前列表成员
                    List<LinkMicItemModel> dataList = recyclerViewHelper.getDataList();
                    for (LinkMicItemModel model : dataList) {
                        String userId = model.userId;
                        if (userIds.contains(userId)) {
                            // 去重
                            continue;
                        }
                        holderModels.add(model);
                        userIds.add(userId);
                    }
                    // 排序: 主播放到第一位
                    Collections.sort(holderModels, new Comparator<LinkMicItemModel>() {
                        @Override
                        public int compare(LinkMicItemModel o1, LinkMicItemModel o2) {
                            boolean isAnchor1 = TextUtils.equals(o1.userId, anchorId);
                            boolean isAnchor2 = TextUtils.equals(o2.userId, anchorId);
                            if (isAnchor1 ^ isAnchor2) {
                                return isAnchor1 ? -1 : 1;
                            }
                            return 0;
                        }
                    });
                    recyclerViewHelper.setData(holderModels);
                }

                @Override
                public void onError(InteractionError error) {
                    showToast("获取麦上成员列表失败");
                }
            });
        }

        @Override
        public void onEvent(String action, Object... args) {
            switch (action) {
                case Actions.APPLY_JOIN_LINK_MIC:
                    isApplying = true;
                    break;
                case Actions.CANCEL_APPLY_JOIN_LINK_MIC:
                    isApplying = false;

                    break;
                case Actions.LEAVE_LINK_MIC:
                case Actions.KICK_LINK_MIC:
                    // 下麦
                    if (Actions.KICK_LINK_MIC.equals(action)) {
                        showToast("您已被主播下麦");
                    }
                    // 停止推
                    pushManager.stopPublish();
                    // 停止预览
                    previewContainer.removeAllViews();
                    ViewUtil.removeSelfSafely(previewContainer);
                    // 停止拉
                    pushManager.stopPull();
                    // 改状态
                    isJoinedLinkMic = false;
                    isApplying = false;
                    // 移除视图
                    recyclerViewHelper.removeAll();
                    // 发送自己的下线通知
                    String reason = Actions.LEAVE_LINK_MIC.equals(action)
                            ? LeaveLinkMicModel.REASON_BY_SELF : LeaveLinkMicModel.REASON_BY_KICK;
                    liveContext.getMessageService().leaveLinkMic(reason, null);
                    // 隐藏当前视图
                    updateVisible();
                    break;
                case Actions.LINK_MIC_MANAGE_CLICK:
                    linkMicManageController.show();
                    break;
                case Actions.ANCHOR_PUSH_SUCCESS:
                    if (supportLinkMic()) {
                        afterPushSuccess();
                    }
                    break;
            }
        }

        @Override
        public void onActivityFinish() {
            super.onActivityFinish();
            if (supportLinkMic() && isJoinedLinkMic && pushManager != null) {
                pushManager.stopPublish();
                pushManager.stopPull();
                pushManager.release();
                liveContext.getMessageService().leaveLinkMic(LeaveLinkMicModel.REASON_BY_SELF, null);
            }
        }

        private void updateMixStreamLayout() {
            List<LiveLinkMicPushManager.MixItem> mixItems = new ArrayList<>();
            List<LinkMicItemModel> dataList = recyclerViewHelper.getDataList();
            for (int i = 0; i < dataList.size(); i++) {
                LinkMicItemModel model = dataList.get(i);
                LiveLinkMicPushManager.MixItem mixItem = new LiveLinkMicPushManager.MixItem();
                mixItem.userId = model.userId;
                mixItem.isAnchor = TextUtils.equals(model.userId, anchorId);
                RecyclerView.ViewHolder holder = recyclerViewHelper.getRecyclerView().findViewHolderForAdapterPosition(i);
                if (holder != null) {
                    mixItem.renderContainer = holder.itemView.findViewById(R.id.item_container);
                }
                mixItems.add(mixItem);
            }
            pushManager.updateMixItems(mixItems);
        }

        public View getAnchorPreviewView() {
            return liveContext.getAnchorPreviewHolder().getPreviewView();
        }
    }
}
