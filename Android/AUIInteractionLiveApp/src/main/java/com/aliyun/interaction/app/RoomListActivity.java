package com.aliyun.interaction.app;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.widget.ContentLoadingProgressBar;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.alivc.auicommon.common.base.callback.Callbacks;
import com.alivc.auicommon.common.base.log.Logger;
import com.alivc.auicommon.common.base.util.CollectionUtil;
import com.alivc.auicommon.common.roombase.Const;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.model.base.InteractionError;
import com.aliyun.aliinteraction.app.R;
import com.aliyun.aliinteraction.uikit.uibase.activity.AppBaseActivity;
import com.aliyun.aliinteraction.uikit.uibase.util.AppUtil;
import com.aliyun.aliinteraction.uikit.uibase.util.ExStatusBarUtils;
import com.aliyun.aliinteraction.uikit.uibase.util.LastLiveSp;
import com.aliyun.aliinteraction.uikit.uibase.util.ViewUtil;
import com.aliyun.auiappserver.AppServerApi;
import com.aliyun.auiappserver.model.ListLiveRequest;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auipusher.LiveRole;
import com.aliyun.auipusher.config.AliLiveMediaStreamOptions;

import java.util.ArrayList;
import java.util.List;

/**
 * @author puke
 * @version 2021/5/11
 */
public class RoomListActivity extends AppBaseActivity {

    private static final String TAG = RoomListActivity.class.getSimpleName();

    private static final int PAGE_SIZE = 10;
    private ContentLoadingProgressBar loading;
    private SwipeRefreshLayout refreshLayout;
    private ImageView backBtn;
    private TabInfo roomType2TabInfo = new TabInfo();
    private Adapter adapter;
    private boolean isRequesting;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_room_list);
        ExStatusBarUtils.setStatusBarColor(this, AppUtil.getColor(R.color.bus_login_status_bar_color));

        loading = findViewById(R.id.loading);
        backBtn = findViewById(R.id.back_btn);
        backBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });

        RecyclerView recyclerView = findViewById(R.id.recycler_view);
        final GridLayoutManager layoutManager = new GridLayoutManager(this, 2);
        recyclerView.setLayoutManager(layoutManager);
        recyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrolled(@NonNull RecyclerView recyclerView, int dx, int dy) {
                super.onScrolled(recyclerView, dx, dy);
                int lastVisibleItemPosition = layoutManager.findLastVisibleItemPosition();
                int dataSize = CollectionUtil.size(getDataList());
                if ((lastVisibleItemPosition < 0 || dataSize == 0)) {
                    return;
                }

                if (lastVisibleItemPosition == dataSize - 1) {
                    // 最后一项可见
                    loadData(true);
                }
            }
        });
        adapter = new Adapter();
        recyclerView.setAdapter(adapter);

        notifyRadioChange();

        refreshLayout = findViewById(R.id.refresh_layout);
        refreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                RoomListActivity.this.loadData(false);
            }
        });

        TextView startCreateRoomButtonText = findViewById(R.id.startCreateRoomButtonText);
        ViewUtil.bindClickActionWithClickCheck(startCreateRoomButtonText,
                new Runnable() {
                    @Override
                    public void run() {
                        Intent intent = new Intent(context, ChooseRoomTypeActivity.class);
                        context.startActivity(intent);
                    }
                }
        );
    }

    /**
     * 跳转直播页面
     *
     * @param liveId   直播Id
     * @param anchorId 主播Id
     */
    private void gotoLivePage(final String liveId, final String anchorId) {
        final LivePrototype.OpenLiveParam param = new LivePrototype.OpenLiveParam();
        param.liveId = liveId;
        param.nick = asNick(Const.getUserId());
        final Callbacks.Lambda<String> callback = new Callbacks.Lambda<>(new Callbacks.Lambda.CallbackWrapper<String>() {
            @Override
            public void onCall(boolean success, String data, String errorMsg) {
                loading.hide();
                if (success) {
                    Logger.d(TAG, "onSuccess: " + data);
                    // 成功后, 记录该场直播, 便于下次快速进入
                    LastLiveSp lastLiveSp = LastLiveSp.INSTANCE;
                    lastLiveSp.setLastLiveId(liveId == null ? data : liveId);
                    lastLiveSp.setLastLiveAnchorId(anchorId);
                } else {
                    RoomListActivity.this.showToast(errorMsg);
                }
            }
        });

        boolean isAnchor = TextUtils.equals(Const.getUserId(), anchorId);
        if (isAnchor) {
            // 主播端: 开启直播
            param.role = LiveRole.ANCHOR;

            // 推流支持动态配置
            final AliLiveMediaStreamOptions pusherOptions = new AliLiveMediaStreamOptions();
            param.mediaPusherOptions = pusherOptions;
        } else {
            // 观众端: 观看直播
            param.role = LiveRole.AUDIENCE;
        }
        loading.show();
        if (isAnchor) {
            LivePrototype.getInstance().setup(context, param, callback);
        } else {
            LivePrototype.getInstance().setup(context, param, callback);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        setupLastLiveLogic();
    }

    public String asNick(String id) {
        return id;
    }


    /**
     * 启动上场直播的浮动条逻辑
     */
    private void setupLastLiveLogic() {

        LastLiveSp lastLiveSp = LastLiveSp.INSTANCE;
        final String lastLiveId = lastLiveSp.getLastLiveId();
        final String lastLiveAnchorId = lastLiveSp.getLastLiveAnchorId();
        if (TextUtils.isEmpty(lastLiveId) || TextUtils.isEmpty(lastLiveAnchorId)) {
            // 取不到上场直播, 直接不处理
            return;
        }

        final View lastLoginView = findViewById(R.id.to_last_live);
        lastLoginView.setVisibility(View.VISIBLE);
        lastLoginView.setAlpha(0);
        lastLoginView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                RoomListActivity.this.gotoLivePage(lastLiveId, lastLiveAnchorId);
            }
        });

        lastLoginView.postDelayed(new Runnable() {
            @Override
            public void run() {
                int width = lastLoginView.getWidth();
                lastLoginView.setTranslationX(width);
                lastLoginView.animate()
                        .setDuration(1000)
                        .translationX(0)
                        .withStartAction(new Runnable() {
                            @Override
                            public void run() {
                                lastLoginView.setAlpha(1);
                            }
                        })
                        .start();
            }
        }, 100);
    }

    private void notifyRadioChange() {
        if (roomType2TabInfo != null && CollectionUtil.isNotEmpty(roomType2TabInfo.dataList)) {
            // 当前tab已有数据, 直接更新
            adapter.notifyDataSetChanged();
            return;
        }

        loadData(false);
    }

    private void endRefreshing() {
        isRequesting = false;
        if (refreshLayout != null) {
            refreshLayout.setRefreshing(false);
        }
    }

    private void loadData(final boolean loadMore) {
        if (isRequesting) {
            return;
        }

        final TabInfo tabInfo = roomType2TabInfo;

        if (tabInfo != null && !tabInfo.hasMore && loadMore) {
            endRefreshing();
            return;
        }

        int currentPage = tabInfo == null ? 0 : tabInfo.pageNum;
        final int targetPage = loadMore ? (currentPage + 1) : 1;

        isRequesting = true;

        ListLiveRequest request = new ListLiveRequest();
        request.userId = Const.getUserId();
        request.pageNum = targetPage;
        request.pageSize = PAGE_SIZE;
        request.imServer.add("aliyun_new");
        AppServerApi.instance().fetchLiveList(request).invoke(new InteractionCallback<List<LiveModel>>() {
            @Override
            public void onSuccess(List<LiveModel> data) {
                isRequesting = false;
                loading.hide();
                endRefreshing();
                List<LiveModel> requestList = data;
                //  boolean hasMore = data != null && data;
                if (tabInfo == null) {
                    TabInfo newTabInfo = new TabInfo();
                    newTabInfo.pageNum = targetPage;
                    newTabInfo.dataList = requestList;
                    // newTabInfo.hasMore = hasMore;
                    roomType2TabInfo = newTabInfo;
                    adapter.notifyDataSetChanged();
                } else {
                    tabInfo.pageNum = targetPage;
                    tabInfo.hasMore = true;
                    if (loadMore) {
                        // 加载更多
                        if (CollectionUtil.isNotEmpty(requestList)) {
                            if (tabInfo.dataList == null) {
                                tabInfo.dataList = new ArrayList<>();
                            }
                            tabInfo.dataList.addAll(requestList);
                            adapter.notifyDataSetChanged();
                        }
                    } else {
                        // 刷新
                        tabInfo.dataList = requestList;
                        adapter.notifyDataSetChanged();
                    }
                }
            }

            @Override
            public void onError(InteractionError error) {
                showToast(error.msg);
                isRequesting = false;
                loading.hide();
                endRefreshing();
            }
        });
    }

    private List<LiveModel> getDataList() {
        return roomType2TabInfo == null ? null : roomType2TabInfo.dataList;
    }

    private static class ViewHolder extends RecyclerView.ViewHolder {


        final ImageView cover;
        final TextView title;
        //  final View isOwner;
        final TextView id;
        final TextView livePv;
        final ImageView liveStatus;

        ViewHolder(@NonNull View itemView) {
            super(itemView);
            cover = itemView.findViewById(R.id.item_cover);
            title = itemView.findViewById(R.id.item_title);
            // isOwner = itemView.findViewById(R.id.item_is_owner);
            id = itemView.findViewById(R.id.item_id);
            livePv = itemView.findViewById(R.id.live_pv);
            liveStatus = itemView.findViewById(R.id.live_status_icon);
        }
    }

    private static class TabInfo {
        int pageNum;
        List<LiveModel> dataList;
        boolean hasMore;
    }

    private class Adapter extends RecyclerView.Adapter<ViewHolder> {


        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            LayoutInflater inflater = LayoutInflater.from(parent.getContext());
            View view = inflater.inflate(R.layout.item_room, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            List<LiveModel> dataList = getDataList();
            if (dataList == null) {
                return;
            }

            final LiveModel model = dataList.get(position);
            holder.title.setText(model.title);
            final boolean isOwner = TextUtils.equals(Const.getUserId(), model.createdAt);
            //ViewUtil.setVisibilityIfNecessary(holder.isOwner, isOwner ? View.VISIBLE : View.GONE);
            holder.id.setText(model.anchorId);
            holder.livePv.setText(model.metrics.pv + "观看");
            if (model.status == 1 || model.status == 0) {
                holder.liveStatus.setBackgroundResource(R.drawable.ic_live);
            } else {
                holder.liveStatus.setBackgroundResource(R.drawable.ilr_icon_recently_viewed);
            }
            // avoid frequent click
            ViewUtil.bindClickActionWithClickCheck(holder.itemView, new Runnable() {
                @Override
                public void run() {
                    gotoLivePage(model.id, model.anchorId);
                }
            });

            holder.itemView.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    if (!isOwner) {
                        // 不是房主, 不能删除
                        return true;
                    }
                    return true;
                }
            });
        }

        @Override
        public int getItemCount() {
            return CollectionUtil.size(getDataList());
        }
    }
}
