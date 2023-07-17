package com.aliyun.aliinteraction.roompaas.message;

import com.aliyun.aliinteraction.roompaas.message.listener.AUIMessageListener;
import com.alivc.auimessage.MessageService;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.observable.IObservable;

/**
 * 基于新版互动SDK封装的消息服务, 提供给Demo层直接使用, 参: {@link AUIMessageServiceFactory#getMessageService}
 *
 * @author puke
 * @version 2022/8/31
 */
public interface AUIMessageService extends IObservable<AUIMessageListener> {

    /**
     * 发送弹幕
     *
     * @param content             消息体内容
     * @param InteractionCallback 回调函数
     */
    void sendComment(String content, InteractionCallback<String> InteractionCallback);

    /**
     * 获取全局禁言状态
     *
     * @param interactionCallback 回调函数
     */
    void queryMuteAll(InteractionCallback<Boolean> interactionCallback);

    /**
     * 全局禁言
     *
     * @param interactionCallback 回调函数
     */
    void muteAll(InteractionCallback<Boolean> interactionCallback);

    /**
     * 取消全局禁言
     *
     * @param interactionCallback 回调函数
     */
    void cancelMuteAll(InteractionCallback<Boolean> interactionCallback);

    /**
     * 开始直播
     *
     * @param InteractionCallback 回调函数
     */
    void startLive(InteractionCallback<String> InteractionCallback);

    /**
     * 结束直播
     *
     * @param InteractionCallback 回调函数
     */
    void stopLive(InteractionCallback<String> InteractionCallback);

    /**
     * 更新公告
     *
     * @param notice              公告内容
     * @param InteractionCallback 回调函数
     */
    void updateNotice(String notice, InteractionCallback<String> InteractionCallback);

    /**
     * 点赞
     *
     * @param likeCount           点赞次数
     * @param interactionCallback 回调函数
     */
    void sendLike(int likeCount, InteractionCallback<String> interactionCallback);

    /**
     * 申请连麦 (观众端调用)
     *
     * @param receiveId           指定接收消息的人 (该场景为主播id)
     * @param InteractionCallback 回调函数
     */
    void applyJoinLinkMic(String receiveId, InteractionCallback<String> InteractionCallback);

    /**
     * 处理连麦申请 (主播端调用)
     *
     * @param agree               true: 同意, false: 拒绝
     * @param applyUserId         申请人的Id
     * @param rtcPullUrl          主播端的rtc拉流地址
     * @param InteractionCallback 回调函数
     */
    void handleApplyJoinLinkMic(boolean agree, String applyUserId, String rtcPullUrl, InteractionCallback<String> InteractionCallback);

    /**
     * 上麦通知
     *
     * @param rtcPullUrl 上麦观众的rtc拉流地址
     */
    void joinLinkMic(String rtcPullUrl, InteractionCallback<String> InteractionCallback);

    /**
     * 下麦通知
     *
     * @param reason 下麦原因
     */
    void leaveLinkMic(String reason, InteractionCallback<String> InteractionCallback);

    /**
     * 踢下麦 (主播端调用)
     *
     * @param userId              踢下麦的用户Id
     * @param InteractionCallback 回调函数
     */
    void kickUserFromLinkMic(String userId, InteractionCallback<String> InteractionCallback);

    /**
     * 更新麦克风状态
     *
     * @param opened true:打开; false:关闭;
     */
    void updateMicStatus(boolean opened, InteractionCallback<String> InteractionCallback);

    /**
     * 更新摄像头状态
     *
     * @param opened true:打开; false:关闭;
     */
    void updateCameraStatus(boolean opened, InteractionCallback<String> InteractionCallback);

    /**
     * 取消申请连麦 (观众端调用)
     *
     * @param receiveId 指定接收消息的人 (该场景为主播id)
     */
    void cancelApplyJoinLinkMic(String receiveId, InteractionCallback<String> InteractionCallback);

    /**
     * 命令某人更改麦克风状态
     *
     * @param receiveId           被命令人的Id
     * @param open                true:打开; false:关闭;
     * @param InteractionCallback 回调函数
     */
    void commandUpdateMic(String receiveId, boolean open, InteractionCallback<String> InteractionCallback);

    /**
     * 命令某人更改摄像头状态
     *
     * @param receiveId           被命令人的Id
     * @param open                true:打开; false:关闭;
     * @param InteractionCallback 回调函数
     */
    void commandUpdateCamera(String receiveId, boolean open, InteractionCallback<String> InteractionCallback);

    /**
     * 添加消息监听器
     *
     * @param messageListener 消息监听器
     */
    void addMessageListener(AUIMessageListener messageListener);

    /**
     * 移除消息监听器
     *
     * @param messageListener 消息监听器
     */
    void removeMessageListener(AUIMessageListener messageListener);

    /**
     * 移除所有消息监听器
     */
    void removeAllMessageListeners();

    MessageService getMessageService();
}
