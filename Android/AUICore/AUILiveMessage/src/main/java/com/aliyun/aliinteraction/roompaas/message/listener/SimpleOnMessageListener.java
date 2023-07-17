package com.aliyun.aliinteraction.roompaas.message.listener;

import com.aliyun.aliinteraction.roompaas.message.model.ApplyJoinLinkMicModel;
import com.aliyun.aliinteraction.roompaas.message.model.CameraStatusUpdateModel;
import com.aliyun.aliinteraction.roompaas.message.model.CancelApplyJoinLinkMicModel;
import com.aliyun.aliinteraction.roompaas.message.model.CommandUpdateCameraModel;
import com.aliyun.aliinteraction.roompaas.message.model.CommandUpdateMicModel;
import com.aliyun.aliinteraction.roompaas.message.model.CommentModel;
import com.aliyun.aliinteraction.roompaas.message.model.HandleApplyJoinLinkMicModel;
import com.aliyun.aliinteraction.roompaas.message.model.JoinLinkMicModel;
import com.aliyun.aliinteraction.roompaas.message.model.KickUserFromLinkMicModel;
import com.aliyun.aliinteraction.roompaas.message.model.LeaveLinkMicModel;
import com.aliyun.aliinteraction.roompaas.message.model.LikeModel;
import com.aliyun.aliinteraction.roompaas.message.model.LiveRoomInfoUpdateModel;
import com.aliyun.aliinteraction.roompaas.message.model.MicStatusUpdateModel;
import com.aliyun.aliinteraction.roompaas.message.model.StartLiveModel;
import com.aliyun.aliinteraction.roompaas.message.model.StopLiveModel;
import com.aliyun.aliinteraction.roompaas.message.model.UpdateNoticeModel;
import com.alivc.auimessage.model.base.AUIMessageModel;
import com.alivc.auimessage.model.message.JoinGroupMessage;
import com.alivc.auimessage.model.message.LeaveGroupMessage;
import com.alivc.auimessage.model.message.MuteGroupMessage;
import com.alivc.auimessage.model.message.UnMuteGroupMessage;

/**
 * @author puke
 * @version 2022/8/31
 */
public class SimpleOnMessageListener implements AUIMessageListener {

    @Override
    public void onJoinGroup(AUIMessageModel<JoinGroupMessage> message) {

    }

    @Override
    public void onLeaveGroup(AUIMessageModel<LeaveGroupMessage> message) {

    }

    @Override
    public void onMuteGroup(AUIMessageModel<MuteGroupMessage> message) {

    }

    @Override
    public void onUnMuteGroup(AUIMessageModel<UnMuteGroupMessage> message) {

    }

    @Override
    public void onMessageReceived(AUIMessageModel<String> message) {

    }

    @Override
    public void onTokenExpire() {

    }

    @Override
    public void onCommentReceived(AUIMessageModel<CommentModel> message) {

    }

    @Override
    public void onPVReceived(AUIMessageModel<LiveRoomInfoUpdateModel> message) {

    }

    @Override
    public void onLikeReceived(AUIMessageModel<LikeModel> message) {

    }

    @Override
    public void onStartLive(AUIMessageModel<StartLiveModel> message) {

    }

    @Override
    public void onStopLive(AUIMessageModel<StopLiveModel> message) {

    }

    @Override
    public void onNoticeUpdate(AUIMessageModel<UpdateNoticeModel> message) {

    }

    @Override
    public void onApplyJoinLinkMic(AUIMessageModel<ApplyJoinLinkMicModel> message) {

    }

    @Override
    public void onHandleApplyJoinLinkMic(AUIMessageModel<HandleApplyJoinLinkMicModel> message) {

    }

    @Override
    public void onJoinLinkMic(AUIMessageModel<JoinLinkMicModel> message) {

    }

    @Override
    public void onLeaveLinkMic(AUIMessageModel<LeaveLinkMicModel> message) {

    }

    @Override
    public void onKickUserFromLinkMic(AUIMessageModel<KickUserFromLinkMicModel> message) {

    }

    @Override
    public void onMicStatusUpdate(AUIMessageModel<MicStatusUpdateModel> message) {

    }

    @Override
    public void onCameraStatusUpdate(AUIMessageModel<CameraStatusUpdateModel> message) {

    }

    @Override
    public void onCommandMicUpdate(AUIMessageModel<CommandUpdateMicModel> message) {

    }

    @Override
    public void onCommandCameraUpdate(AUIMessageModel<CommandUpdateCameraModel> message) {

    }

    @Override
    public void onCancelApplyJoinLinkMic(AUIMessageModel<CancelApplyJoinLinkMicModel> message) {

    }

    @Override
    public void onRawMessageReceived(AUIMessageModel<String> message) {

    }
}
