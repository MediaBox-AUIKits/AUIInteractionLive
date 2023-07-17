package com.aliyun.auilinkmickit;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewpager.widget.PagerAdapter;
import androidx.viewpager.widget.ViewPager;

import com.alivc.auicommon.common.base.base.Consumer;
import com.alivc.auicommon.common.base.util.CollectionUtil;
import com.alivc.auicommon.common.base.util.CommonUtil;
import com.alivc.auicommon.core.base.Actions;
import com.aliyun.aliinteraction.roompaas.message.AUIMessageService;
import com.aliyun.aliinteraction.roompaas.message.listener.SimpleOnMessageListener;
import com.aliyun.aliinteraction.roompaas.message.model.ApplyJoinLinkMicModel;
import com.aliyun.aliinteraction.roompaas.message.model.CameraStatusUpdateModel;
import com.aliyun.aliinteraction.roompaas.message.model.CancelApplyJoinLinkMicModel;
import com.aliyun.aliinteraction.roompaas.message.model.JoinLinkMicModel;
import com.aliyun.aliinteraction.roompaas.message.model.LeaveLinkMicModel;
import com.aliyun.aliinteraction.roompaas.message.model.MicStatusUpdateModel;
import com.aliyun.aliinteraction.uikit.core.BaseComponent;
import com.aliyun.aliinteraction.uikit.core.ComponentHolder;
import com.aliyun.aliinteraction.uikit.core.IComponent;
import com.aliyun.aliinteraction.uikit.uibase.helper.RecyclerViewHelper;
import com.aliyun.aliinteraction.uikit.uibase.util.BottomSheetDialogUtil;
import com.aliyun.auiappserver.AppServerApi;
import com.aliyun.auiappserver.model.GetMeetingInfoRequest;
import com.aliyun.auiappserver.model.LinkMicItemModel;
import com.aliyun.auiappserver.model.MeetingInfo;
import com.aliyun.auiappserver.model.UpdateMeetingInfoRequest;
import com.aliyun.auipusher.LiveContext;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.model.base.AUIMessageModel;
import com.alivc.auimessage.model.base.InteractionError;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.google.android.material.tabs.TabLayout;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;

/**
 * 主播端的连麦管理控制器
 *
 * @author puke
 * @version 2022/11/19
 */
public class LinkMicManageController implements ComponentHolder {

    private static final int TAB_INDEX_APPLY = 0;
    private static final int TAB_INDEX_ONLINE = 1;
    private static final List<String> TAB_TITLES = Arrays.asList("连麦申请", "麦上成员");
    public static int maxLinkMicLimit = 6;
    private final List<RecyclerViewHelper<LinkMicItemModel>> viewHelpers;
    private final Component component = new Component();
    private final Context context;
    private final Callback callback;
    private final ViewPager viewPager;
    private final BottomSheetDialog dialog;
    private final TabLayout tabLayout;

    private AUIMessageService messageService;

    public LinkMicManageController(Context context, Callback callback) {
        this.context = context;
        this.callback = callback;
        this.viewHelpers = new ArrayList<>();

        dialog = BottomSheetDialogUtil.create(context, R.layout.ilr_layout_linkmic_manage);
        tabLayout = dialog.findViewById(R.id.manage_tab_layout);
        viewPager = dialog.findViewById(R.id.manage_view_pager);

        tabLayout.setTabMode(TabLayout.MODE_FIXED);
        for (int i = 0; i < TAB_TITLES.size(); i++) {
            tabLayout.addTab(tabLayout.newTab());
            viewHelpers.add(createViewHelper(context, i));
        }

        tabLayout.setupWithViewPager(viewPager);

        PagerAdapterImpl pagerAdapter = new PagerAdapterImpl();
        viewPager.setAdapter(pagerAdapter);

        for (int i = 0; i < TAB_TITLES.size(); i++) {
            updateTabTitle(i);
        }
    }

    private static String formatTabTitleWithCount(String title, int count) {
        if (count <= 0) {
            return title;
        } else {
            return String.format(Locale.getDefault(), "%s(%d)", title, count);
        }
    }

    public void show() {
        dialog.show();
    }

    private RecyclerViewHelper<LinkMicItemModel> createViewHelper(final Context context, final int tabPosition) {
        RecyclerView view = new RecyclerView(context);
        view.setOverScrollMode(View.OVER_SCROLL_NEVER);
        return RecyclerViewHelper.of(view, R.layout.ilr_item_link_mic_manage,
                new RecyclerViewHelper.HolderRenderer<LinkMicItemModel>() {
                    @Override
                    public void render(final RecyclerViewHelper<LinkMicItemModel> viewHelper, final RecyclerViewHelper.ViewHolder holder, final LinkMicItemModel model, final int position, int itemCount, List<Object> payloads) {
                        TextView nick = holder.getView(R.id.item_nick);
                        nick.setText(model.userNick);

                        View applyLayout = holder.getView(R.id.item_apply_layout);
                        View onlineLayout = holder.getView(R.id.item_online_layout);
                        if (tabPosition == 0) {
                            // 连麦申请
                            applyLayout.setVisibility(View.VISIBLE);
                            onlineLayout.setVisibility(View.GONE);

                            holder.getView(R.id.item_reject).setOnClickListener(new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    component.performHandleApply(model.userId, false);
                                }
                            });
                            holder.getView(R.id.item_agree).setOnClickListener(new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    component.performHandleApply(model.userId, true);
                                }
                            });
                        } else {
                            // 麦上成员
                            ViewGroup.LayoutParams itemViewLp = holder.itemView.getLayoutParams();
                            boolean isAnchor = TextUtils.equals(component.getAnchorId(), model.userId);
                            itemViewLp.height = isAnchor ? 0 : context.getResources().getDimensionPixelOffset(R.dimen.ilr_link_mic_online_item_height);
                            holder.itemView.setLayoutParams(itemViewLp);

                            onlineLayout.setVisibility(View.VISIBLE);
                            applyLayout.setVisibility(View.GONE);

                            View mic = holder.getView(R.id.item_mic);
                            final View camera = holder.getView(R.id.item_camera);

                            final boolean micOpened = model.micOpened;
                            final boolean cameraOpened = model.cameraOpened;

                            mic.setSelected(micOpened);
                            camera.setSelected(cameraOpened);

                            mic.setOnClickListener(new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    boolean target = !micOpened;
                                    getMessageService().commandUpdateMic(model.userId, target, null);
                                }
                            });
                            camera.setOnClickListener(new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    boolean target = !cameraOpened;
                                    getMessageService().commandUpdateCamera(model.userId, target, null);
                                }
                            });
                            holder.getView(R.id.item_kick).setOnClickListener(new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    showToast("下麦");
                                    getMessageService().kickUserFromLinkMic(model.userId, null);
                                }
                            });
                        }
                    }
                }
        );
    }

    public AUIMessageService getMessageService() {
        if (messageService == null) {
            messageService = component.getMessageService();
        }
        return messageService;
    }

    @Override
    public IComponent getComponent() {
        return component;
    }

    private RecyclerViewHelper<LinkMicItemModel> getApplyViewHelper() {
        return viewHelpers.get(TAB_INDEX_APPLY);
    }

    private RecyclerViewHelper<LinkMicItemModel> getOnlineViewHelper() {
        return viewHelpers.get(TAB_INDEX_ONLINE);
    }

    private void addToApplyList(LinkMicItemModel added) {
        RecyclerViewHelper<LinkMicItemModel> viewHelper = getApplyViewHelper();
        int index = LinkMicItemModel.findIndexByUserId(viewHelper.getDataList(), added.userId);
        if (index < 0) {
            viewHelper.addData(Collections.singletonList(added));
            updateTabTitle(TAB_INDEX_APPLY);
            updateManageCounter();
        }
    }

    private void removeFromApplyList(String userId) {
        RecyclerViewHelper<LinkMicItemModel> viewHelper = getApplyViewHelper();
        int index = LinkMicItemModel.findIndexByUserId(viewHelper.getDataList(), userId);
        if (index >= 0) {
            viewHelper.removeData(index);
            updateTabTitle(TAB_INDEX_APPLY);
            updateManageCounter();
        }
    }

    private void addToOnlineList(LinkMicItemModel added) {
        if (TextUtils.equals(added.userId, component.getAnchorId())) {
            // 连麦管理中不包含主播自己
            return;
        }
        RecyclerViewHelper<LinkMicItemModel> viewHelper = getOnlineViewHelper();
        int index = LinkMicItemModel.findIndexByUserId(viewHelper.getDataList(), added.userId);
        if (index < 0) {
            viewHelper.addData(Collections.singletonList(added));
            updateTabTitle(TAB_INDEX_ONLINE);
        }
    }

    private void removeFromOnlineList(String userId) {
        RecyclerViewHelper<LinkMicItemModel> viewHelper = getOnlineViewHelper();
        int index = LinkMicItemModel.findIndexByUserId(viewHelper.getDataList(), userId);
        if (index >= 0) {
            viewHelper.removeData(index);
            updateTabTitle(TAB_INDEX_ONLINE);
        }
    }

    private void updateOnlineList(String userId, Consumer<LinkMicItemModel> consumer) {
        RecyclerViewHelper<LinkMicItemModel> viewHelper = getOnlineViewHelper();
        List<LinkMicItemModel> dataList = viewHelper.getDataList();
        int index = LinkMicItemModel.findIndexByUserId(dataList, userId);
        if (index >= 0) {
            LinkMicItemModel model = dataList.get(index);
            consumer.accept(model);
            viewHelper.updateData(index);
        }
    }

    private void updateTabTitle(int tabIndex) {
        TabLayout.Tab tab = tabLayout.getTabAt(tabIndex);
        if (tab != null) {
            String tabName = TAB_TITLES.get(tabIndex);
            int itemCount = viewHelpers.get(tabIndex).getItemCount();
            if (tabIndex == TAB_INDEX_ONLINE) {
                tab.setText(tabName);
            } else {
                tab.setText(formatTabTitleWithCount(tabName, itemCount));
            }
        }
    }

    // 更新连麦管理图标的计数器
    private void updateManageCounter() {
        int count = getApplyViewHelper().getItemCount();
        component.postEvent(Actions.UPDATE_MANAGE_COUNTER, count);
    }

    private void showToast(String text) {
        CommonUtil.showToast(context, text);
    }

    public interface Callback {
        LinkMicItemModel getAnchorItemModel();
    }

    private class Component extends BaseComponent {
        @Override
        public void onInit(final LiveContext liveContext) {
            super.onInit(liveContext);

            getMessageService().addMessageListener(new SimpleOnMessageListener() {

                @Override
                public void onApplyJoinLinkMic(AUIMessageModel<ApplyJoinLinkMicModel> message) {
                    if (isOwner()) {
                        RecyclerViewHelper<LinkMicItemModel> viewHelper = getOnlineViewHelper();
                        // -1是因为连麦管理列表不包含主播本人
                        if (viewHelper.getItemCount() >= maxLinkMicLimit - 1) {
                            // 超过连麦人数上限后, 直接拒绝连麦
                            performHandleApply(message.senderInfo.userId, false);
                        } else {
                            // 未超过时, 添加至申请列表
                            LinkMicItemModel model = new LinkMicItemModel();
                            model.userId = message.senderInfo.userId;
                            model.userNick = message.senderInfo.userNick;
                            model.userAvatar = message.senderInfo.userAvatar;
                            addToApplyList(model);

                            show();
                            if (viewPager != null) {
                                viewPager.setCurrentItem(TAB_INDEX_APPLY);
                            }
                        }
                    }
                }

                @Override
                public void onCancelApplyJoinLinkMic(AUIMessageModel<CancelApplyJoinLinkMicModel> message) {
                    if (isOwner()) {
                        // 收到观众取消申请时, 从申请列表移除该观众
                        removeFromApplyList(message.senderInfo.userId);
                    }
                }

                @Override
                public void onJoinLinkMic(AUIMessageModel<JoinLinkMicModel> message) {
                    if (isOwner()) {
                        // 1. 刷新连麦管理列表数据
                        LinkMicItemModel model = new LinkMicItemModel();
                        model.userId = message.senderInfo.userId;
                        model.userNick = message.senderInfo.userNick;
                        model.userAvatar = message.senderInfo.userAvatar;
                        model.rtcPullUrl = message.data.rtcPullUrl;
                        model.micOpened = true;
                        model.cameraOpened = true;
                        addToOnlineList(model);

                        boolean isSelf = TextUtils.equals(message.senderInfo.userId, getUserId());
                        if (isSelf) {
                            // 2.1 主播自己上麦, 先拉取历史数据, 再更新
                            GetMeetingInfoRequest request = new GetMeetingInfoRequest();
                            request.id = getLiveId();
                            AppServerApi.instance().getMeetingInfo(request).invoke(new InteractionCallback<MeetingInfo>() {
                                @Override
                                public void onSuccess(MeetingInfo meetingInfo) {
                                    List<LinkMicItemModel> members = meetingInfo.members;
                                    if (CollectionUtil.isNotEmpty(members)) {
                                        Iterator<LinkMicItemModel> iterator = members.iterator();
                                        while (iterator.hasNext()) {
                                            LinkMicItemModel next = iterator.next();
                                            if (TextUtils.equals(getAnchorId(), next.userId)) {
                                                iterator.remove();
                                            }
                                        }

                                        if (CollectionUtil.isNotEmpty(members)) {
                                            getOnlineViewHelper().addData(members);
                                            updateTabTitle(TAB_INDEX_ONLINE);
                                        }
                                    }
                                    // merge存量数据后, 更新AppServer的麦上成员列表
                                    updateMeetingInfo();
                                }

                                @Override
                                public void onError(InteractionError error) {
                                    // 拉不到数据也更新
                                    updateMeetingInfo();
                                }
                            });
                        } else {
                            // 2.2 别人上麦, 直接更新AppServer数据
                            updateMeetingInfo();
                        }
                    }
                }

                @Override
                public void onLeaveLinkMic(AUIMessageModel<LeaveLinkMicModel> message) {
                    if (isOwner()) {
                        // 1. 刷新连麦管理列表数据
                        removeFromOnlineList(message.senderInfo.userId);

                        // 2. 主播更新AppServer数据
                        updateMeetingInfo();
                    }
                }

                @Override
                public void onMicStatusUpdate(final AUIMessageModel<MicStatusUpdateModel> message) {
                    if (isOwner()) {
                        // 1. 刷新连麦管理列表的状态
                        updateOnlineList(message.senderInfo.userId, new Consumer<LinkMicItemModel>() {
                            @Override
                            public void accept(LinkMicItemModel model) {
                                model.micOpened = message.data.micOpened;
                            }
                        });

                        // 2. 主播更新AppServer数据
                        updateMeetingInfo();
                    }
                }

                @Override
                public void onCameraStatusUpdate(final AUIMessageModel<CameraStatusUpdateModel> message) {
                    if (isOwner()) {
                        // 1. 刷新连麦管理列表的状态
                        updateOnlineList(message.senderInfo.userId, new Consumer<LinkMicItemModel>() {
                            @Override
                            public void accept(LinkMicItemModel model) {
                                model.cameraOpened = message.data.cameraOpened;
                            }
                        });

                        // 2. 主播更新AppServer数据
                        updateMeetingInfo();
                    }
                }
            });
        }

        private void updateMeetingInfo() {
            // 主播将最新的麦上成员列表更新到AppServer端
            List<LinkMicItemModel> dataList = new ArrayList<>(getOnlineViewHelper().getDataList());
            // 添加主播数据
            LinkMicItemModel model = callback.getAnchorItemModel();
            if (model != null) {
                dataList.add(0, model);
            }
            UpdateMeetingInfoRequest request = new UpdateMeetingInfoRequest();
            request.id = getLiveId();
            request.members = dataList;
            AppServerApi.instance().updateMeetingInfo(request).invoke(null);
        }

        private void performHandleApply(String applyUserId, boolean agree) {
            if (agree) {
                // 同意申请
                int itemCount = getOnlineViewHelper().getItemCount();
                if (itemCount >= maxLinkMicLimit - 1) {
                    // 超过最大限制时, 即使同意, 也做拒绝处理
                    showToast("当前连麦人数已经超过最大限制");
                    return;
                } else {
                    String rtcPullUrl = liveContext.getLiveModel().linkInfo.rtcPullUrl;
                    getMessageService().handleApplyJoinLinkMic(true, applyUserId, rtcPullUrl, null);
                }
            } else {
                // 拒绝申请
                getMessageService().handleApplyJoinLinkMic(false, applyUserId, null, null);
            }
            // 处理之后, 从申请列表中移除
            removeFromApplyList(applyUserId);
        }
    }

    private class PagerAdapterImpl extends PagerAdapter {

        @Override
        public int getCount() {
            return TAB_TITLES.size();
        }

        @Override
        public boolean isViewFromObject(@NonNull View view, @NonNull Object o) {
            return view == o;
        }

        @NonNull
        @Override
        public Object instantiateItem(@NonNull ViewGroup container, int position) {
            RecyclerViewHelper<LinkMicItemModel> viewHelper = viewHelpers.get(position);
            FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
            );
            RecyclerView view = viewHelper.getRecyclerView();
            container.addView(view, layoutParams);
            return view;
        }

        @Override
        public void destroyItem(@NonNull ViewGroup container, int position, @NonNull Object object) {
            container.removeView((View) object);
        }
    }
}
