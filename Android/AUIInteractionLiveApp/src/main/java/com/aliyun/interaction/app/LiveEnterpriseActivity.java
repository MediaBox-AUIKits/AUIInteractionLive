package com.aliyun.interaction.app;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.WindowManager;

import androidx.annotation.Nullable;

import com.alivc.auicommon.common.base.log.Logger;
import com.alivc.auicommon.common.base.util.Utils;
import com.alivc.auicommon.common.biz.exposable.enums.LiveStatus;
import com.alivc.auicommon.common.roombase.Const;
import com.alivc.auicommon.core.base.Actions;
import com.alivc.auicommon.core.event.EventManager;
import com.alivc.auimessage.MessageService;
import com.alivc.auimessage.MessageServiceFactory;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.model.base.InteractionError;
import com.alivc.auimessage.model.lwp.GetGroupInfoRequest;
import com.alivc.auimessage.model.lwp.GetGroupInfoResponse;
import com.alivc.auimessage.model.lwp.JoinGroupRequest;
import com.alivc.auimessage.model.lwp.JoinGroupResponse;
import com.aliyun.aliinteraction.app.R;
import com.aliyun.aliinteraction.player.LivePlayerService;
import com.aliyun.aliinteraction.player.LivePlayerServiceImpl;
import com.aliyun.aliinteraction.roompaas.message.AUIMessageService;
import com.aliyun.aliinteraction.roompaas.message.AUIMessageServiceFactory;
import com.aliyun.aliinteraction.uikit.core.ComponentManager;
import com.aliyun.aliinteraction.uikit.core.LiveConst;
import com.aliyun.aliinteraction.uikit.uibase.activity.BaseActivity;
import com.aliyun.aliinteraction.uikit.uibase.util.DialogUtil;
import com.aliyun.auiappserver.model.LiveModel;
import com.aliyun.auipusher.AnchorPreviewHolder;
import com.aliyun.auipusher.LiveContext;
import com.aliyun.auipusher.LiveParam;
import com.aliyun.auipusher.LiveRole;
import com.aliyun.auipusher.LiveService;
import com.aliyun.auipusher.LiveServiceImpl;
import com.aliyun.auipusher.manager.LiveLinkMicPushManager;

public class LiveEnterpriseActivity extends BaseActivity {
    private static final String TAG = LiveEnterpriseActivity.class.getSimpleName();
    private final ComponentManager componentManager = new ComponentManager();
    private final AnchorPreviewHolder anchorPreviewHolder = new AnchorPreviewHolder();
    private LiveContext liveContext;
    private LiveRole role;
    private LiveStatus liveStatus;
    private String liveId;
    private LiveModel liveModel;
    private String userNick;
    private String userExtension;
    private String groupId;
    private String tips;
    private boolean isPushing = false;
    private AUIMessageService auiMessageService;
    private MessageService messageService;
    private LiveService liveService;
    private LivePlayerService livePlayerService;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        parseParams(getIntent());
        super.onCreate(savedInstanceState);
    }

    @Override
    protected Runnable asPermissionGrantedAction() {
        return new Runnable() {
            @Override
            public void run() {
                init();
            }
        };
    }


    private void init() {
        // 获取RoomChannel
        messageService = MessageServiceFactory.getMessageService();
        if (!messageService.isLogin()) {
            Logger.e(TAG, "Not login");
            showToast("未登录");
            return;
        }

        liveContext = new LiveContextImpl();
        setContentView(R.layout.activity_live_enterprise);

        View decorView = getWindow().getDecorView();
        componentManager.scanComponent(decorView);
        componentManager.dispatchInit(liveContext);
        getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_VISIBLE);
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);

        joinGroup();
    }

    private void parseParams(Intent intent) {
        LiveParam pageParam = (LiveParam) intent.getSerializableExtra(LiveConst.PARAM_KEY_LIVE_PARAM);
        liveId = pageParam.liveId;
        liveModel = pageParam.liveModel;
        role = pageParam.role;
        liveStatus = LiveStatus.of(liveModel.status);
        userNick = pageParam.userNick;
        userExtension = pageParam.userExtension;
        tips = pageParam.notice;

        groupId = liveModel.chatId;
        Logger.i(TAG, String.format("liveModel=%s", liveModel));
    }

    private void joinGroup() {
        JoinGroupRequest request = new JoinGroupRequest();
        request.groupId = groupId;
        messageService.joinGroup(request, new InteractionCallback<JoinGroupResponse>() {
            @Override
            public void onSuccess(JoinGroupResponse response) {
                if (isActivityValid()) {
                    onEnterRoomSuccess(liveModel);
                }
            }

            @Override
            public void onError(InteractionError error) {
                if (isActivityValid()) {
                    onEnterRoomError(error.msg);

                    // 进入失败时, 退出房间
                    String message = String.format("进入房间失败：\n%s", error.msg);
                    DialogUtil.confirm(LiveEnterpriseActivity.this, message,
                            new Runnable() {
                                @Override
                                public void run() {
                                    finish();
                                }
                            },
                            new Runnable() {
                                @Override
                                public void run() {
                                    finish();
                                }
                            }
                    );
                }
            }
        });
    }

    private void onEnterRoomSuccess(LiveModel liveModel) {
        this.liveModel = liveModel;
        componentManager.dispatchEnterRoomSuccess(liveModel);

        GetGroupInfoRequest request = new GetGroupInfoRequest();
        request.groupId = groupId;
        auiMessageService.getMessageService().getGroupInfo(request, new InteractionCallback<GetGroupInfoResponse>() {
            @Override
            public void onSuccess(GetGroupInfoResponse response) {
                if (Utils.isActivityValid(LiveEnterpriseActivity.this)) {
                    componentManager.post(Actions.GET_GROUP_STATISTICS_SUCCESS, response);
                }
            }

            @Override
            public void onError(InteractionError error) {

            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        componentManager.dispatchActivityResult(requestCode, resultCode, data);
    }

    @Override
    protected void onPause() {
        super.onPause();
        componentManager.dispatchActivityPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        componentManager.dispatchActivityResume();
    }

    @Override
    public void onBackPressed() {
        if (!componentManager.interceptBackKey()) {
            super.onBackPressed();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        componentManager.dispatchActivityDestroy();
        liveContext.getMessageService().removeAllMessageListeners();
    }

    @Override
    public void finish() {
        super.finish();
        componentManager.dispatchActivityFinish();
    }

    private void onEnterRoomError(String errorMsg) {
        componentManager.dispatchEnterRoomError(errorMsg);
    }

    private class LiveContextImpl implements LiveContext {

        @Override
        public Activity getActivity() {
            return LiveEnterpriseActivity.this;
        }

        @Override
        public LiveRole getRole() {
            return role;
        }

        @Override
        public String getNick() {
            return userNick;
        }

        @Override
        public String getTips() {
            return tips;
        }

        @Override
        public LiveStatus getLiveStatus() {
            return liveStatus;
        }

        @Override
        public EventManager getEventManager() {
            return componentManager;
        }

        @Override
        public boolean isPushing() {
            return isPushing;
        }

        @Override
        public void setPushing(boolean isPushing) {
            LiveEnterpriseActivity.this.isPushing = isPushing;
        }

        @Override
        public boolean isLandscape() {
            return context.getResources().getConfiguration().orientation == Configuration.ORIENTATION_LANDSCAPE;
        }

        @Override
        public void setLandscape(boolean landscape) {
            if (landscape) {
                // 竖屏 => 横屏
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
            } else {
                // 横屏 => 竖屏
                setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
            }
        }

        @Override
        public String getLiveId() {
            return liveId;
        }

        @Override
        public String getGroupId() {
            return groupId;
        }

        @Override
        public String getUserId() {
            return Const.getUserId();
        }

        @Override
        public LiveService getLiveService() {
            if (liveService == null) {
                liveService = new LiveServiceImpl(LiveEnterpriseActivity.this, liveContext);
            }
            return liveService;
        }

        @Override
        public LivePlayerService getLivePlayerService() {
            if (livePlayerService == null) {
                livePlayerService = new LivePlayerServiceImpl(LiveEnterpriseActivity.this);
            }
            return livePlayerService;
        }

        @Override
        public AUIMessageService getMessageService() {
            if (auiMessageService == null) {
                auiMessageService = AUIMessageServiceFactory.getMessageService(groupId);
            }
            return auiMessageService;
        }

        @Override
        public LiveLinkMicPushManager getLiveLinkMicPushManager() {
            // 企业直播，没有推流场景，因此传空
            return null;
        }

        @Override
        public LiveModel getLiveModel() {
            return liveModel;
        }

        @Override
        public AnchorPreviewHolder getAnchorPreviewHolder() {
            return anchorPreviewHolder;
        }

        @Override
        public boolean isOwner(String userId) {
            if (liveModel != null) {
                String anchorId = liveModel.anchorId;
                if (!TextUtils.isEmpty(anchorId)) {
                    return TextUtils.equals(anchorId, userId);
                }
            }
            return false;
        }
    }
}