package com.aliyun.aliinteraction.roompaas.message;

import com.alibaba.fastjson.JSON;
import com.alivc.auicommon.common.base.base.Consumer;
import com.alivc.auicommon.common.base.base.Function;
import com.alivc.auicommon.common.base.log.Logger;
import com.alivc.auicommon.common.base.observable.Observable;
import com.alivc.auicommon.common.roombase.Const;
import com.aliyun.aliinteraction.roompaas.message.listener.AUIMessageListener;
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
import com.aliyun.auiappserver.ApiService;
import com.aliyun.auiappserver.AppServerApi;
import com.aliyun.auiappserver.model.CancelMuteAllRequest;
import com.aliyun.auiappserver.model.FetchStatisticsRequest;
import com.aliyun.auiappserver.model.FetchStatisticsResponse;
import com.aliyun.auiappserver.model.LiveSendLikeRequest;
import com.aliyun.auiappserver.model.LiveSendLikeResponse;
import com.aliyun.auiappserver.model.MuteAllRequest;
import com.aliyun.auiappserver.model.MuteGroupStatus;
import com.aliyun.auiappserver.model.QueryMuteAllRequest;
import com.alivc.auimessage.MessageService;
import com.alivc.auimessage.MessageServiceFactory;
import com.alivc.auimessage.listener.InteractionCallback;
import com.alivc.auimessage.listener.MessageListener;
import com.alivc.auimessage.model.base.AUIMessageModel;
import com.alivc.auimessage.model.base.InteractionError;
import com.alivc.auimessage.model.base.InteractionErrors;
import com.alivc.auimessage.model.lwp.CancelMuteGroupRequest;
import com.alivc.auimessage.model.lwp.GroupMuteStatusRequest;
import com.alivc.auimessage.model.lwp.GroupMuteStatusResponse;
import com.alivc.auimessage.model.lwp.MuteGroupRequest;
import com.alivc.auimessage.model.lwp.SendLikeRequest;
import com.alivc.auimessage.model.lwp.SendLikeResponse;
import com.alivc.auimessage.model.lwp.SendMessageToGroupRequest;
import com.alivc.auimessage.model.lwp.SendMessageToGroupResponse;
import com.alivc.auimessage.model.lwp.SendMessageToGroupUserRequest;
import com.alivc.auimessage.model.lwp.SendMessageToGroupUserResponse;
import com.alivc.auimessage.model.message.JoinGroupMessage;
import com.alivc.auimessage.model.message.LeaveGroupMessage;
import com.alivc.auimessage.model.message.MuteGroupMessage;
import com.alivc.auimessage.model.message.UnMuteGroupMessage;

import java.io.Serializable;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * @author puke
 * @version 2022/8/31
 */
class AUIMessageServiceImpl extends Observable<AUIMessageListener> implements AUIMessageService {

    private static final String TAG = "AUIMessageServiceImpl";

    private final String groupId;
    private final MessageService service;

    private boolean pvNeedUpdate = false;

    AUIMessageServiceImpl(String groupId) {
        this.groupId = groupId;
        this.service = MessageServiceFactory.getMessageService();
        service.register(new MessageListenerDispatcher());
    }

    @Override
    public void sendComment(String content, InteractionCallback<String> callback) {
        CommentModel message = new CommentModel();
        message.content = content;
        doSendMessage(message, false, null, callback);
    }

    @Override
    public void queryMuteAll(final InteractionCallback<Boolean> interactionCallback) {
        if (MessageServiceFactory.useRongCloud()) {
            // 融云方案走App Server
            QueryMuteAllRequest request = new QueryMuteAllRequest();
            request.chatroom_id = this.groupId;

            ApiService apiService = AppServerApi.instance();
            apiService.queryMuteAll(request).invoke(new InteractionCallback<MuteGroupStatus>() {
                @Override
                public void onSuccess(MuteGroupStatus data) {
                    if (data == null || data.code != 200) {
                        interactionCallback.onError(new InteractionError("操作失败"));
                        return;
                    }
                    interactionCallback.onSuccess(data.mute);
                }

                @Override
                public void onError(InteractionError interactionError) {
                    interactionCallback.onError(interactionError);
                }
            });
        } else if (MessageServiceFactory.useInternal()) {
            // 内部消息组件走IM方案
            GroupMuteStatusRequest request = new GroupMuteStatusRequest();
            request.groupId = this.groupId;
            service.queryMuteGroup(request, new InteractionCallback<GroupMuteStatusResponse>() {
                @Override
                public void onSuccess(GroupMuteStatusResponse data) {
                    if (data == null) {
                        interactionCallback.onError(new InteractionError("操作失败"));
                        return;
                    }
                    interactionCallback.onSuccess(data.mute);
                }

                @Override
                public void onError(InteractionError interactionError) {
                    interactionCallback.onError(interactionError);
                }
            });
        } else {
            interactionCallback.onError(new InteractionError("query mute all failed with error type."));
        }
    }

    @Override
    public void muteAll(final InteractionCallback<Boolean> interactionCallback) {
        if (MessageServiceFactory.useRongCloud()) {
            // 融云方案走App Server
            MuteAllRequest request = new MuteAllRequest();
            request.chatroom_id = this.groupId;

            ApiService apiService = AppServerApi.instance();
            apiService.muteAll(request).invoke(new InteractionCallback<MuteGroupStatus>() {
                @Override
                public void onSuccess(MuteGroupStatus data) {
                    if (data == null || data.code != 200) {
                        interactionCallback.onError(new InteractionError("操作失败"));
                        return;
                    }
                    interactionCallback.onSuccess(null);
                }

                @Override
                public void onError(InteractionError interactionError) {
                    interactionCallback.onError(interactionError);
                }
            });
        } else if (MessageServiceFactory.useInternal()) {
            // 内部消息组件走IM方案
            MuteGroupRequest request = new MuteGroupRequest();
            request.groupId = this.groupId;
            service.muteGroup(request, new InteractionCallback<GroupMuteStatusResponse>() {
                @Override
                public void onSuccess(GroupMuteStatusResponse data) {
                    if (data == null) {
                        interactionCallback.onError(new InteractionError("操作失败"));
                        return;
                    }
                    interactionCallback.onSuccess(data.mute);
                }

                @Override
                public void onError(InteractionError interactionError) {
                    interactionCallback.onError(interactionError);
                }
            });
        } else {
            interactionCallback.onError(new InteractionError("mute all failed with error type."));
        }
    }

    @Override
    public void cancelMuteAll(final InteractionCallback<Boolean> interactionCallback) {
        if (MessageServiceFactory.useRongCloud()) {
            // 融云方案走App Server
            CancelMuteAllRequest request = new CancelMuteAllRequest();
            request.chatroom_id = this.groupId;

            ApiService apiService = AppServerApi.instance();
            apiService.cancelMuteAll(request).invoke(new InteractionCallback<MuteGroupStatus>() {
                @Override
                public void onSuccess(MuteGroupStatus data) {
                    if (data == null || data.code != 200) {
                        interactionCallback.onError(new InteractionError("操作失败"));
                        return;
                    }
                    interactionCallback.onSuccess(null);
                }

                @Override
                public void onError(InteractionError interactionError) {
                    interactionCallback.onError(interactionError);
                }
            });
        } else if (MessageServiceFactory.useInternal()) {
            // 内部消息组件走IM方案
            CancelMuteGroupRequest request = new CancelMuteGroupRequest();
            request.groupId = this.groupId;
            service.cancelMuteGroup(request, new InteractionCallback<GroupMuteStatusResponse>() {
                @Override
                public void onSuccess(GroupMuteStatusResponse data) {
                    if (data == null) {
                        interactionCallback.onError(new InteractionError("操作失败"));
                        return;
                    }
                    interactionCallback.onSuccess(data.mute);
                }

                @Override
                public void onError(InteractionError interactionError) {
                    interactionCallback.onError(interactionError);
                }
            });
        } else {
            interactionCallback.onError(new InteractionError("cancel mute all failed with error type."));
        }
    }

    @Override
    public void startLive(InteractionCallback<String> callback) {
        doSendMessage(new StartLiveModel(), null, callback);
    }

    @Override
    public void stopLive(InteractionCallback<String> callback) {
        doSendMessage(new StopLiveModel(), null, callback);
    }

    @Override
    public void updateNotice(String notice, InteractionCallback<String> callback) {
        UpdateNoticeModel model = new UpdateNoticeModel();
        model.notice = notice;
        doSendMessage(model, null, callback);
    }

    @Override
    public void sendLike(int likeCount, final InteractionCallback<String> interactionCallback) {
        if (MessageServiceFactory.useRongCloud()) {
            // 融云方案走App Server
            LiveSendLikeRequest request = new LiveSendLikeRequest();
            request.chatroom_id = this.groupId;
            request.user_id = Const.getUserId();
            request.like_count = likeCount;
            ApiService apiService = AppServerApi.instance();
            apiService.sendLike(request).invoke(new InteractionCallback<LiveSendLikeResponse>() {
                @Override
                public void onSuccess(LiveSendLikeResponse data) {
                    if (data == null || data.code != 200) {
                        interactionCallback.onError(new InteractionError("操作失败"));
                        return;
                    }
                    interactionCallback.onSuccess("");
                }

                @Override
                public void onError(InteractionError interactionError) {
                    interactionCallback.onError(interactionError);
                }
            });
        } else if (MessageServiceFactory.useInternal()) {
            // 内部消息组件走IM方案
            SendLikeRequest request = new SendLikeRequest();
            request.groupId = this.groupId;
            request.likeCount = likeCount;
            service.sendLike(request, new InteractionCallback<SendLikeResponse>() {
                @Override
                public void onSuccess(SendLikeResponse data) {
                    if (data == null) {
                        interactionCallback.onError(new InteractionError("操作失败"));
                        return;
                    }
                    interactionCallback.onSuccess("");
                }

                @Override
                public void onError(InteractionError interactionError) {
                    interactionCallback.onError(interactionError);
                }
            });
        } else {
            interactionCallback.onError(new InteractionError("query mute all failed with error type."));
        }
    }

    @Override
    public void applyJoinLinkMic(String receiveId, InteractionCallback<String> callback) {
        ApplyJoinLinkMicModel model = new ApplyJoinLinkMicModel();
        doSendMessage(model, receiveId, callback);
    }

    @Override
    public void handleApplyJoinLinkMic(boolean agree, String applyUserId, String rtcPullUrl, InteractionCallback<String> callback) {
        HandleApplyJoinLinkMicModel model = new HandleApplyJoinLinkMicModel();
        model.agree = agree;
        if (agree) {
            model.rtcPullUrl = rtcPullUrl;
        }
        doSendMessage(model, applyUserId, callback);
    }

    @Override
    public void joinLinkMic(String rtcPullUrl, InteractionCallback<String> callback) {
        JoinLinkMicModel model = new JoinLinkMicModel();
        model.rtcPullUrl = rtcPullUrl;
        doSendMessage(model, null, callback);
    }

    @Override
    public void leaveLinkMic(String reason, InteractionCallback<String> callback) {
        LeaveLinkMicModel model = new LeaveLinkMicModel();
        doSendMessage(model, null, callback);
    }

    @Override
    public void kickUserFromLinkMic(String userId, InteractionCallback<String> callback) {
        KickUserFromLinkMicModel model = new KickUserFromLinkMicModel();
        doSendMessage(model, userId, callback);
    }

    @Override
    public void updateMicStatus(boolean opened, InteractionCallback<String> callback) {
        MicStatusUpdateModel model = new MicStatusUpdateModel();
        model.micOpened = opened;
        doSendMessage(model, null, callback);
    }

    @Override
    public void updateCameraStatus(boolean opened, InteractionCallback<String> callback) {
        CameraStatusUpdateModel model = new CameraStatusUpdateModel();
        model.cameraOpened = opened;
        doSendMessage(model, null, callback);
    }

    @Override
    public void cancelApplyJoinLinkMic(String receiveId, InteractionCallback<String> callback) {
        CancelApplyJoinLinkMicModel model = new CancelApplyJoinLinkMicModel();
        doSendMessage(model, receiveId, callback);
    }

    @Override
    public void commandUpdateMic(String receiveId, boolean open, InteractionCallback<String> callback) {
        CommandUpdateMicModel model = new CommandUpdateMicModel();
        model.needOpenMic = open;
        doSendMessage(model, receiveId, callback);
    }

    @Override
    public void commandUpdateCamera(String receiveId, boolean open, InteractionCallback<String> callback) {
        CommandUpdateCameraModel model = new CommandUpdateCameraModel();
        model.needOpenCamera = open;
        doSendMessage(model, receiveId, callback);
    }

    @Override
    public void addMessageListener(AUIMessageListener messageListener) {
        register(messageListener);
    }

    @Override
    public void removeMessageListener(AUIMessageListener messageListener) {
        unregister(messageListener);
    }

    @Override
    public void removeAllMessageListeners() {
        unregisterAll();
    }

    @Override
    public MessageService getMessageService() {
        return service;
    }


    private void doSendMessage(Serializable messageModel, String directUserId, InteractionCallback<String> callback) {
        doSendMessage(messageModel, true, directUserId, callback);
    }

    private void doSendMessage(Serializable messageModel, boolean skipAudit, String directUserId, InteractionCallback<String> callback) {
        Class<?> messageType = messageModel.getClass();
        Integer type = AUIMessageTypeMapping.getTypeFromModelClass(messageType);
        if (type == null) {
            Logger.e(TAG, String.format("doSendMessage, class '%s' not declare in %s's method",
                    messageType.getName(), AUIMessageListener.class.getName()));
            if (callback != null) {
                callback.onError(InteractionErrors.INVALID_PARAM);
            }
            return;
        }

        String data = JSON.toJSONString(messageModel);
        if (directUserId == null) {
            doSendMessageToGroup(data, skipAudit, callback, type);
        } else {
            doSendMessageToGroupUser(data, directUserId, callback, type);
        }
    }

    private void doSendMessageToGroup(String data, boolean skipAudit, final InteractionCallback<String> callback, Integer type) {
        SendMessageToGroupRequest request = new SendMessageToGroupRequest();
        request.groupId = groupId;
        request.type = type;
        request.data = data;
        request.skipAudit = skipAudit;
        service.sendMessageToGroup(request,
                new InteractionCallbackAdapter<>(callback, new Function<SendMessageToGroupResponse, String>() {
                    @Override
                    public String apply(SendMessageToGroupResponse response) {
                        return response.messageId;
                    }
                })
        );
    }

    private void doSendMessageToGroupUser(String data, String receiverId, final InteractionCallback<String> callback, Integer type) {
        SendMessageToGroupUserRequest request = new SendMessageToGroupUserRequest();
        request.groupId = groupId;
        request.type = type;
        request.data = data;
        request.receiverId = receiverId;
        service.sendMessageToGroupUser(request,
                new InteractionCallbackAdapter<>(callback, new Function<SendMessageToGroupUserResponse, String>() {
                    @Override
                    public String apply(SendMessageToGroupUserResponse response) {
                        return response.messageId;
                    }
                })
        );
    }

    private static class InteractionCallbackAdapter<T, R> implements InteractionCallback<T> {

        final InteractionCallback<R> callback;
        final Function<T, R> converter;

        InteractionCallbackAdapter(InteractionCallback<R> callback, Function<T, R> converter) {
            this.callback = callback;
            this.converter = converter;
        }

        @Override
        public void onSuccess(T data) {
            if (callback != null) {
                R converted = converter.apply(data);
                callback.onSuccess(converted);
            }
        }

        @Override
        public void onError(InteractionError error) {
            if (callback != null) {
                callback.onError(error);
            }
        }
    }

    private class MessageListenerDispatcher implements MessageListener {
        @Override
        public void onJoinGroup(final AUIMessageModel<JoinGroupMessage> message) {
            Logger.i(TAG, "onJoinGroup");
            dispatch(new Consumer<AUIMessageListener>() {
                @Override
                public void accept(final AUIMessageListener listener) {
                    listener.onJoinGroup(message);
                }
            });

            fetchPV(message);
        }

        @Override
        public void onLeaveGroup(final AUIMessageModel<LeaveGroupMessage> message) {
            Logger.i(TAG, "onLeaveGroup");
            dispatch(new Consumer<AUIMessageListener>() {
                @Override
                public void accept(AUIMessageListener listener) {
                    listener.onLeaveGroup(message);
                }
            });
        }

        @Override
        public void onMuteGroup(final AUIMessageModel<MuteGroupMessage> message) {
            Logger.i(TAG, "onMuteGroup");
            dispatch(new Consumer<AUIMessageListener>() {
                @Override
                public void accept(AUIMessageListener listener) {
                    listener.onMuteGroup(message);
                }
            });
        }

        @Override
        public void onUnMuteGroup(final AUIMessageModel<UnMuteGroupMessage> message) {
            Logger.i(TAG, "onUnMuteGroup");
            dispatch(new Consumer<AUIMessageListener>() {
                @Override
                public void accept(AUIMessageListener listener) {
                    listener.onUnMuteGroup(message);
                }
            });
        }

        @Override
        public void onMessageReceived(final AUIMessageModel<String> message) {
            Logger.i(TAG, "onCustomMessageReceived, message.type=" + message.type);
            dispatch(new Consumer<AUIMessageListener>() {
                @Override
                public void accept(AUIMessageListener auiMessageListener) {
                    AUIMessageModel<String> convertedMessage = MessageListenerDispatcher.this.copyMessageWithoutData(message);
                    convertedMessage.data = message.data;
                    auiMessageListener.onRawMessageReceived(convertedMessage);
                }
            });

            int type = message.type;
            AUIMessageTypeMapping.CallbackInfo callbackInfo = AUIMessageTypeMapping.getCallbackInfoFromType(type);
            if (callbackInfo == null) {
                Logger.w(TAG, "onMessageReceived, unknown type: " + type);
                return;
            }

            Class<?> modelClass = callbackInfo.modelClass;
            final Object data;
            try {
                data = JSON.parseObject(message.data, modelClass);
            } catch (Exception e) {
                e.printStackTrace();
                Logger.e(TAG, "onMessageReceived, parse json error for " + modelClass);
                // TODO: 2022/9/20 此处return需多端保持对齐, 防止其他端data传null或空字符串
                return;
            }

            @SuppressWarnings({"rawtypes", "unchecked"}) final AUIMessageModel convertedMessage = copyMessageWithoutData(message);
            convertedMessage.data = data;

            final Method auiMessageListenerMethod = callbackInfo.callbackMethod;
            if (auiMessageListenerMethod == null) {
                Logger.e(TAG, "onMessageReceived, can't find method of callback for " + modelClass);
                return;
            }

            Logger.i(TAG, "onCustomMessageReceived, invoke: " + auiMessageListenerMethod.getName());
            dispatch(new Consumer<AUIMessageListener>() {
                @Override
                public void accept(AUIMessageListener auiMessageListener) {
                    try {
                        auiMessageListenerMethod.invoke(auiMessageListener, convertedMessage);
                    } catch (IllegalAccessException | InvocationTargetException e) {
                        e.printStackTrace();
                        Logger.e(TAG, "onMessageReceived, invoke error: " + e.getMessage(), e);
                    }
                }
            });
        }

        @Override
        public void onTokenExpire() {

        }

        private <T> AUIMessageModel<T> copyMessageWithoutData(AUIMessageModel<?> message) {
            AUIMessageModel<T> messageModel = new AUIMessageModel<>();
            messageModel.id = message.id;
            messageModel.senderInfo = message.senderInfo;
            messageModel.type = message.type;
            return messageModel;
        }

        private void fetchPV(final AUIMessageModel<JoinGroupMessage> message) {
            if (pvNeedUpdate) {
                return;
            }

            final AUIMessageModel<LikeModel> likeMessageModel = new AUIMessageModel<>();
            likeMessageModel.id = message.id;
            likeMessageModel.groupId = groupId;

            final AUIMessageModel<LiveRoomInfoUpdateModel> pvMessageModel = new AUIMessageModel<>();
            pvMessageModel.id = message.id;
            pvMessageModel.groupId = groupId;

            if (MessageServiceFactory.useInternal()) {
                JoinGroupMessage joinGroupMessage = message.data;
                if (joinGroupMessage != null) {
                    LikeModel likeModel = new LikeModel();
                    likeModel.likeCount = joinGroupMessage.likeCount;
                    likeMessageModel.data = likeModel;

                    LiveRoomInfoUpdateModel liveRoomInfoUpdateModel = new LiveRoomInfoUpdateModel();
                    liveRoomInfoUpdateModel.pv = joinGroupMessage.pv;
                    liveRoomInfoUpdateModel.uv = joinGroupMessage.uv;
                    liveRoomInfoUpdateModel.onlineCount = joinGroupMessage.onlineCount;
                    pvMessageModel.data = liveRoomInfoUpdateModel;

                    dispatch(new Consumer<AUIMessageListener>() {
                        @Override
                        public void accept(AUIMessageListener listener1) {
                            listener1.onLikeReceived(likeMessageModel);
                            listener1.onPVReceived(pvMessageModel);
                            pvNeedUpdate = false;
                        }
                    });
                }
            } else if (MessageServiceFactory.useRongCloud()) {
                ApiService apiService = AppServerApi.instance();
                FetchStatisticsRequest request = new FetchStatisticsRequest();
                request.chatroom_id = groupId;
                apiService.fetchStatistics(request).invoke(new InteractionCallback<FetchStatisticsResponse>() {
                    @Override
                    public void onSuccess(FetchStatisticsResponse data) {
                        if (data != null) {
                            LikeModel likeModel = new LikeModel();
                            likeModel.likeCount = data.likeCount;
                            likeMessageModel.data = likeModel;

                            LiveRoomInfoUpdateModel liveRoomInfoUpdateModel = new LiveRoomInfoUpdateModel();
                            liveRoomInfoUpdateModel.pv = data.pv;
                            liveRoomInfoUpdateModel.uv = data.uv;
                            liveRoomInfoUpdateModel.onlineCount = data.onlineCount;
                            pvMessageModel.data = liveRoomInfoUpdateModel;

                            dispatch(new Consumer<AUIMessageListener>() {
                                @Override
                                public void accept(AUIMessageListener listener2) {
                                    listener2.onLikeReceived(likeMessageModel);
                                    listener2.onPVReceived(pvMessageModel);
                                    pvNeedUpdate = false;
                                }
                            });
                        }
                    }

                    @Override
                    public void onError(InteractionError interactionError) {
                    }
                });
            }
        }
    }
}
