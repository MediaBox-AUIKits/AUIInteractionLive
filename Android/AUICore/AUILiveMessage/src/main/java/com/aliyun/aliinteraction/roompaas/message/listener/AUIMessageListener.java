package com.aliyun.aliinteraction.roompaas.message.listener;

import com.aliyun.aliinteraction.roompaas.message.annotation.IgnoreMapping;
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
import com.alivc.auimessage.listener.MessageListener;
import com.alivc.auimessage.model.base.AUIMessageModel;

/**
 * @author puke
 * @version 2022/8/31
 */
public interface AUIMessageListener extends MessageListener {

    /**
     * 收到弹幕消息
     */
    void onCommentReceived(AUIMessageModel<CommentModel> message);

    /**
     * 房间PV更新
     */
    void onPVReceived(AUIMessageModel<LiveRoomInfoUpdateModel> message);

    /**
     * 点赞状态更新
     */
    void onLikeReceived(AUIMessageModel<LikeModel> message);

    /**
     * 开始直播
     */
    void onStartLive(AUIMessageModel<StartLiveModel> message);

    /**
     * 结束直播
     */
    void onStopLive(AUIMessageModel<StopLiveModel> message);

    /**
     * 更新公告
     */
    void onNoticeUpdate(AUIMessageModel<UpdateNoticeModel> message);

    /**
     * 申请连麦
     */
    void onApplyJoinLinkMic(AUIMessageModel<ApplyJoinLinkMicModel> message);

    /**
     * 处理连麦申请
     */
    void onHandleApplyJoinLinkMic(AUIMessageModel<HandleApplyJoinLinkMicModel> message);

    /**
     * 上麦通知
     */
    void onJoinLinkMic(AUIMessageModel<JoinLinkMicModel> message);

    /**
     * 下麦通知
     */
    void onLeaveLinkMic(AUIMessageModel<LeaveLinkMicModel> message);

    /**
     * 踢下麦
     */
    void onKickUserFromLinkMic(AUIMessageModel<KickUserFromLinkMicModel> message);

    /**
     * 麦克风状态变化
     */
    void onMicStatusUpdate(AUIMessageModel<MicStatusUpdateModel> message);

    /**
     * 摄像头状态变化
     */
    void onCameraStatusUpdate(AUIMessageModel<CameraStatusUpdateModel> message);

    /**
     * 命令更改麦克风状态消息
     */
    void onCommandMicUpdate(AUIMessageModel<CommandUpdateMicModel> message);

    /**
     * 命令更改摄像头状态消息
     */
    void onCommandCameraUpdate(AUIMessageModel<CommandUpdateCameraModel> message);

    /**
     * 取消申请连麦
     */
    void onCancelApplyJoinLinkMic(AUIMessageModel<CancelApplyJoinLinkMicModel> message);

    /**
     * 原始消息透出 (不做type解析)
     */
    @IgnoreMapping
    void onRawMessageReceived(AUIMessageModel<String> message);
}
