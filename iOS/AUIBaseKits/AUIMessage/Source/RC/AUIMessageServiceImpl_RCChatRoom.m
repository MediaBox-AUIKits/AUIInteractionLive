//
//  AUIMessageServiceImpl_RCChatRoom.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import "AUIMessageServiceImpl_RCChatRoom.h"
#import "AUIMessageHelper.h"

#import <RongIMLib/RongIMLib.h>

static NSString * const kRCAppKey = @"你的AppKey";

@interface AUIMessageServiceImpl_RCChatRoom () <RCConnectionStatusChangeDelegate, RCChatRoomMemberDelegate, RCIMClientReceiveMessageDelegate, RCChatRoomNotifyEventDelegate>

@property (nonatomic, strong) AUIMessageConfig *config;
@property (nonatomic, strong) id<AUIUserProtocol> userInfo;
@property (nonatomic, weak) id<AUIMessageServiceConnectionDelegate> connectionDelegate;
@property (nonatomic, weak) id<AUIMessageServiceUnImplDelegate> unImplDelegate;
@property (nonatomic, strong) AUIMessageListenerObserver *listenerObserver;


@end

@implementation AUIMessageServiceImpl_RCChatRoom

- (instancetype)init {
    self = [super init];
    if (self) {
        [[RCCoreClient sharedCoreClient] initWithAppKey:kRCAppKey option:nil];
        [[RCCoreClient sharedCoreClient] addConnectionStatusChangeDelegate:self];
        [[RCCoreClient sharedCoreClient] addReceiveMessageDelegate:self];
        [[RCChatRoomClient sharedChatRoomClient] setMemberDelegate:self];
        [[RCChatRoomClient sharedChatRoomClient] addChatRoomNotifyEventDelegate:self];
    }
    return self;
}

- (AUIMessageServiceImplType)implType {
    return AUIMessageServiceImplTypeRCChatRoom;
}

- (void)setConfig:(AUIMessageConfig *)config {
    _config = config;
}

- (void)setConnectionDelegate:(id<AUIMessageServiceConnectionDelegate>)connectionDelegate {
    _connectionDelegate = connectionDelegate;
}

- (void)setUnImplDelegate:(id<AUIMessageServiceUnImplDelegate>)delegate {
    _unImplDelegate = delegate;
}

- (id<AUIUserProtocol>)currentUserInfo {
    if ([self isLogin]) {
        return self.userInfo;
    }
    return nil;
}

- (BOOL)isLogin {
    return [[RCIMClient sharedRCIMClient] getConnectionStatus] == ConnectionStatus_Connected;
}

- (void)login:(id<AUIUserProtocol>)userInfo callback:(AUIMessageDefaultCallback)callback {
    if (self.isLogin) {
        if (callback) {
            callback(nil);
        }
        return;
    }
    if (userInfo.userId.length == 0) {
        if (callback) {
            callback([AUIMessageHelper error:AUIMessageErrorTypeParamError msg:@"userId is empty."]);
        }
        return;
    }
    
    NSString *token = [self.config.tokenData objectForKey:@"token"];
    if (token.length == 0) {
        if (callback) {
            callback([AUIMessageHelper error:AUIMessageErrorTypeParamError msg:@"config or token is empty."]);
        }
        return;
    }

    self.userInfo = userInfo;
    [[RCIMClient sharedRCIMClient] connectWithToken:token timeLimit:15 dbOpened:^(RCDBErrorCode code) {
        
    } success:^(NSString * _Nonnull userId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil);
            }
        });
    } error:^(RCConnectErrorCode errorCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback([AUIMessageHelper error:errorCode msg:@"connected error"]);
            }
        });
    }];
}

- (void)logout:(AUIMessageDefaultCallback)callback {
    [[RCIMClient sharedRCIMClient] disconnect:NO];
    if (callback) {
        callback(nil);
    }
}

- (AUIMessageListenerObserver *)getListenerObserver {
    if (!_listenerObserver) {
        _listenerObserver = [AUIMessageListenerObserver new];
    }
    return _listenerObserver;
}

- (void)getGroupInfo:(AUIMessageGetGroupInfoRequest *)req callback:(AUIMessageGetGroupInfoCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback(nil, [AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    [[RCChatRoomClient sharedChatRoomClient] getChatRoomInfo:req.groupId count:0 order:RC_ChatRoom_Member_Desc success:^(RCChatRoomInfo * _Nonnull chatRoomInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                AUIMessageGetGroupInfoResponse *rsp = [AUIMessageGetGroupInfoResponse new];
                rsp.groupId = chatRoomInfo.targetId;
                rsp.onlineCount = chatRoomInfo.totalMemberCount;
                rsp.pv = -1;
                callback(rsp, nil);
            }
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil, [AUIMessageHelper error:status msg:@"get group info error"]);
            }
        });
    }];
}

- (void)createGroup:(AUIMessageCreateGroupRequest *)req callback:(AUIMessageCreateGroupCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback(nil, [AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }

    // 注意：1、聊天室id不存在情况下会进行创建并自动加入  2、聊天室存在自动销毁机制，需要服务端加入保活列表，建议创建聊天室由服务端来做
    NSString *groupId = req.groupId.length > 0 ? req.groupId : NSUUID.UUID.UUIDString.lowercaseString;
    [[RCChatRoomClient sharedChatRoomClient] joinChatRoom:groupId messageCount:-1 success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                AUIMessageCreateGroupResponse *rsp = [AUIMessageCreateGroupResponse new];
                rsp.groupId = groupId;
                callback(rsp, nil);
            }
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil, [AUIMessageHelper error:status msg:@"create group error"]);
            }
        });
    }];
}

- (void)joinGroup:(AUIMessageJoinGroupRequest *)req callback:(AUIMessageDefaultCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback([AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    [[RCChatRoomClient sharedChatRoomClient] joinExistChatRoom:req.groupId messageCount:-1 success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil);
            }
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback([AUIMessageHelper error:status msg:@"join group error"]);
            }
        });
    }];
}

- (void)leaveGroup:(AUIMessageLeaveGroupRequest *)req callback:(AUIMessageDefaultCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback([AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    [[RCChatRoomClient sharedChatRoomClient] quitChatRoom:req.groupId success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil);
            }
        });
    } error:^(RCErrorCode status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback([AUIMessageHelper error:status msg:@"leave group error"]);
            }
        });
    }];
}

- (void)muteAll:(AUIMessageMuteAllRequest *)req callback:(AUIMessageDefaultCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback([AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    
    // 该接口需要业务层实现
    if ([self.unImplDelegate respondsToSelector:@selector(muteAll:callback:)]) {
        [self.unImplDelegate muteAll:req callback:callback];
    }
    else {
        if (callback) {
            callback([AUIMessageHelper error:AUIMessageErrorTypeUnImpl msg:@"unimpl"]);
        }
    }
}

- (void)cancelMuteAll:(AUIMessageCancelMuteAllRequest *)req callback:(AUIMessageDefaultCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback([AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    
    // 该接口需要业务层实现
    if ([self.unImplDelegate respondsToSelector:@selector(cancelMuteAll:callback:)]) {
        [self.unImplDelegate cancelMuteAll:req callback:callback];
    }
    else {
        if (callback) {
            callback([AUIMessageHelper error:AUIMessageErrorTypeUnImpl msg:@"unimpl"]);
        }
    }
}

- (void)queryMuteAll:(AUIMessageQueryMuteAllRequest *)req callback:(AUIMessageQueryMuteAllCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback(nil, [AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    
    // 该接口需要业务层实现
    if ([self.unImplDelegate respondsToSelector:@selector(queryMuteAll:callback:)]) {
        [self.unImplDelegate queryMuteAll:req callback:callback];
    }
    else {
        if (callback) {
            callback(nil, [AUIMessageHelper error:AUIMessageErrorTypeUnImpl msg:@"unimpl"]);
        }
    }
}

- (void)sendLike:(AUIMessageSendLikeRequest *)req callback:(AUIMessageDefaultCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback([AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    
    // 该接口需要业务层实现
    if ([self.unImplDelegate respondsToSelector:@selector(sendLike:callback:)]) {
        [self.unImplDelegate sendLike:req callback:callback];
    }
    else {
        if (callback) {
            callback([AUIMessageHelper error:AUIMessageErrorTypeUnImpl msg:@"unimpl"]);
        }
    }
}

- (void)sendMessageToGroup:(AUIMessageSendMessageToGroupRequest *)req callback:(AUIMessageSendMessageToGroupCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback(nil, [AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    
#define USE_SEND_SYS_MESSAGE_IMPL   // 如果你的业务无需在禁言时发送消息，可以关闭该宏，反之打开该宏。关闭后，所有消息都通过sdk的接口发送
#ifdef USE_SEND_SYS_MESSAGE_IMPL
    // 融云聊天室sdk无法在禁言下仍然发送消息，需要通过业务接口来实现
    if (req.skipMuteCheck) {
        if ([self.unImplDelegate respondsToSelector:@selector(sendSysMessageToGroup:callback:)]) {
            [self.unImplDelegate sendSysMessageToGroup:req callback:callback];
        }
        else {
            if (callback) {
                callback(nil, [AUIMessageHelper error:AUIMessageErrorTypeUnImpl msg:@"接口没实现，无法发送消息"]);
            }
        }
        return;
    }
#endif
    
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body addEntriesFromDictionary:@{
        @"groupId":req.groupId ?: @"",
        @"type" : @(req.msgType),
        @"skipAudit" : @(req.skipAudit),
        @"nick" : self.userInfo.userNick ?: @"",
        @"avatar" : self.userInfo.userAvatar ?: @"",
    }];
    if (req.data) {
        [body setObject:[AUIMessageHelper jsonStringWithDict:[req.data toData]] ?: @"{}" forKey:@"data"];
    }
    NSString *bodyText = [AUIMessageHelper jsonStringWithDict:body];
    RCTextMessage *messageContent = [RCTextMessage messageWithContent:bodyText];
    RCMessage *message = [[RCMessage alloc] initWithType:ConversationType_CHATROOM targetId:req.groupId direction:MessageDirection_SEND content:messageContent];
    message.senderUserId = self.userInfo.userId;

    __weak typeof(self) weakSelf = self;
    [[RCIMClient sharedRCIMClient] sendMessage:message pushContent:nil pushData:nil successBlock:^(RCMessage *successMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                AUIMessageSendMessageToGroupResponse *rsp = [AUIMessageSendMessageToGroupResponse new];
                rsp.messageId = [NSString stringWithFormat:@"%ld", successMessage.messageId ];
                callback(rsp, nil);
                [weakSelf onReceived:message left:0 object:nil offline:NO hasPackage:NO];
            }
        });
    } errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
        //失败
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil, [AUIMessageHelper error:nErrorCode msg:@"send message to group error"]);
            }
        });
    }];
}

- (void)sendMessageToGroupUser:(AUIMessageSendMessageToGroupUserRequest *)req callback:(AUIMessageSendMessageToGroupUserCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback(nil, [AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    
    if (req.receiverId.length == 0) {
        if (callback) {
            callback(nil, [AUIMessageHelper error:AUIMessageErrorTypeParamError msg:@"param error: receiverId is empty"]);
        }
        return;
    }
    
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body addEntriesFromDictionary:@{
        @"groupId":req.groupId ?: @"",
        @"type" : @(req.msgType),
        @"skipAudit" : @(req.skipAudit),
        @"nick" : self.userInfo.userNick ?: @"",
        @"avatar" : self.userInfo.userAvatar ?: @"",
    }];
    if (req.data) {
        [body setObject:[AUIMessageHelper jsonStringWithDict:[req.data toData]] ?: @"{}" forKey:@"data"];
    }
    NSString *bodyText = [AUIMessageHelper jsonStringWithDict:body];
    RCTextMessage *messageContent = [RCTextMessage messageWithContent:bodyText];
    RCMessage *message = [[RCMessage alloc] initWithType:ConversationType_PRIVATE targetId:req.receiverId direction:MessageDirection_SEND content:messageContent];

    [[RCIMClient sharedRCIMClient] sendMessage:message pushContent:nil pushData:nil successBlock:^(RCMessage *successMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                AUIMessageSendMessageToGroupUserResponse *rsp = [AUIMessageSendMessageToGroupUserResponse new];
                rsp.messageId = [NSString stringWithFormat:@"%ld", successMessage.messageId ];
                callback(rsp, nil);
            }
        });
    } errorBlock:^(RCErrorCode nErrorCode, RCMessage *errorMessage) {
        //失败
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil, [AUIMessageHelper error:nErrorCode msg:@"send message to user error"]);
            }
        });
    }];
}

- (id)getNativeEngine {
    return nil;
}

#pragma mark - RCConnectionStatusChangeDelegate

- (void)onConnectionStatusChanged:(RCConnectionStatus)status {
    NSLog(@"AUIMessageServiceImpl_RCChatRoom##onConnectionStatusChanged:%zd", status);
    if (status == ConnectionStatus_TOKEN_INCORRECT) {
        // 过期时触发重连？
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.connectionDelegate respondsToSelector:@selector(onTokenExpire)]) {
                [self.connectionDelegate onTokenExpire];
            }
        });
    }

}

#pragma mark - RCChatRoomMemberDelegate

- (void)memberDidChange:(NSArray<RCChatRoomMemberAction *> *)members inRoom:(NSString *)roomId {
    // 注意需要提交工单申请开通
    for (RCChatRoomMemberAction *action in members) {
        AUIMessageUserInfo *sender = [[AUIMessageUserInfo alloc] init:action.memberId];
        AUIMessageModel *model = [AUIMessageModel new];
        model.groupId = roomId;
        model.sender = sender;
        if (action.action == RC_ChatRoom_Member_Join) {
            [self.listenerObserver onJoinGroup:model];
        }
        else if (action.action == RC_ChatRoom_Member_Quit) {
            [self.listenerObserver onLeaveGroup:model];
        }
    }
}

#pragma  mark - RCIMClientReceiveMessageDelegate

- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object offline:(BOOL)offline hasPackage:(BOOL)hasPackage {

    RCTextMessage *messageContent = (RCTextMessage *)message.content;
    if ([messageContent isKindOfClass:RCTextMessage.class]) {
        NSString *bodyText = messageContent.content;
        if (bodyText.length > 0) {
            NSDictionary* dict = [AUIMessageHelper parseJson:bodyText];
            
            AUIMessageModel *model = [AUIMessageModel new];
            model.groupId = [dict objectForKey:@"groupId"];
            model.msgType = [[dict objectForKey:@"type"] integerValue];
            model.messageId = [NSString stringWithFormat:@"%ld", message.messageId ];
            
            AUIMessageUserInfo *sender = [[AUIMessageUserInfo alloc] init:message.senderUserId];
            sender.userNick = [dict objectForKey:@"nick"];
            sender.userAvatar = [dict objectForKey:@"avatar"];
            model.sender = sender;
            
            NSString *dataString = [dict objectForKey:@"data"];
            if (dataString.length > 0) {
                model.data = [AUIMessageHelper parseJson:dataString];
            }
            
            [self.listenerObserver onMessageReceived:model];
        }
    }
}

#pragma  mark - RCChatRoomNotifyEventDelegate

- (void)chatRoomNotifyBan:(RCChatRoomMemberBanEvent *)event {
    // 禁言事件处理
    if (event.banType == RCChatRoomMemberBanTypeMuteAll) {
        AUIMessageModel *model = [AUIMessageModel new];
        model.groupId = event.chatroomId;
        model.msgType = 1004;
        [self.listenerObserver onMuteGroup:model];
    }
    else if (event.banType == RCChatRoomMemberBanTypeUnmuteAll) {
        AUIMessageModel *model = [AUIMessageModel new];
        model.groupId = event.chatroomId;
        model.msgType = 1005;
        [self.listenerObserver onUnmuteGroup:model];
    }
    else if (event.banType == RCChatRoomMemberBanTypeMuteUsers) {
        
    }
    else if (event.banType == RCChatRoomMemberBanTypeUnmuteUsers) {
        
    }
}

- (void)chatRoomNotifyBlock:(RCChatRoomMemberBlockEvent *)event {
    
}

- (void)chatRoomNotifyMultiLoginSync:(RCChatRoomSyncEvent *)event {
    
}


@end
