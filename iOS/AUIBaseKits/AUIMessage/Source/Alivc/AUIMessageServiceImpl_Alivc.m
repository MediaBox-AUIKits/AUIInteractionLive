//
//  AUIMessageServiceImpl_Alivc.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import "AUIMessageServiceImpl_Alivc.h"
#import "AUIMessageHelper.h"

#import <AlivcInteraction/AlivcInteraction.h>

#define ALIVC_IM_VERSION_1_1  // 1.1 版本SDK

@interface AUIMessageServiceImpl_Alivc () <AVCIInteractionEngineDelegate, AVCIInteractionServiceDelegate>

@property (nonatomic, strong) AUIMessageConfig *config;
@property (nonatomic, copy) NSString *loginToken;
@property (nonatomic, weak) id<AUIMessageServiceConnectionDelegate> connectionDelegate;

@property (nonatomic, strong) AUIMessageListenerObserver *listenerObserver;
@property (nonatomic, strong) id<AUIUserProtocol> userInfo;
@property (nonatomic, copy) AUIMessageDefaultCallback loginCallback;



@end


@implementation AUIMessageServiceImpl_Alivc

static NSError *s_error_interaction(AVCIInteractionError *error) {
    return s_error(error.code, error.message?:@"");
}

static NSError *s_error(NSInteger code, NSString *message) {
    return [NSError errorWithDomain:@"auimessage.alivc" code:code userInfo:@{NSLocalizedDescriptionKey:message}];
}

static NSString *_globalGroupId = nil;
+ (NSString *)globalGroupId {
    return _globalGroupId;
}

+ (void)setGlobalGroupId:(NSString *)globalGroupId {
    _globalGroupId = globalGroupId;
}

- (void)setConfig:(AUIMessageConfig *)config {
    _config = config;
    _loginToken = config.token;
}

- (id<AUIUserProtocol>)currentUserInfo {
    if ([self isLogin]) {
        return self.userInfo;
    }
    return nil;
}

- (BOOL)isLogin {
    return self.interactionEngine.isLogin;
}

- (void)login:(id<AUIUserProtocol>)userInfo callback:(AUIMessageDefaultCallback)callback {
    if (self.interactionEngine.isLogin) {
        if (callback) {
            callback(nil);
        }
        return;
    }
    if (userInfo.userId.length == 0) {
        if (callback) {
            callback(s_error(-1, @"userId is empty."));
        }
        return;
    }
    
    if (self.loginCallback) {
        // 上次调用login，此时返回失败
        self.loginCallback(s_error(-1, @"login again."));
    }
    self.loginCallback = callback;
    self.userInfo = userInfo;
    [self.interactionEngine loginWithUserID:userInfo.userId];
}

- (void)logout:(AUIMessageDefaultCallback)callback {
    [self.interactionEngine logoutOnSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil);
            }
        });
        
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        NSAssert(NO, @"Logout failure");
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(s_error_interaction(error));
            }
        });
    }];
}

- (AUIMessageListenerObserver *)getListenerObserver {
    if (!_listenerObserver) {
        _listenerObserver = [AUIMessageListenerObserver new];
    }
    return _listenerObserver;
}

- (void)getGroupInfo:(AUIMessageGetGroupInfoRequest *)req callback:(AUIMessageGetGroupInfoCallback)callback {
    [self.interactionEngine.interactionService getGroupStatisticsWithGroup:req.groupId onSuccess:^(AVCIInteractionGroupStatistics * _Nonnull groupDetail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                AUIMessageGetGroupInfoResponse *rsp = [AUIMessageGetGroupInfoResponse new];
                rsp.groupId = groupDetail.groupId;
#ifndef ALIVC_IM_VERSION_1_1
                rsp.onlineCount = groupDetail.onlineCount;
#endif
                callback(rsp, nil);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil, s_error_interaction(error));
            }
        });
    }];
}

- (void)createGroup:(AUIMessageCreateGroupRequest *)req callback:(AUIMessageCreateGroupCallback)callback {
    [self.interactionEngine.interactionService createGroupWithExtension:req.extension ?: @{} onSuccess:^(NSString * _Nonnull groupID) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                AUIMessageCreateGroupResponse *rsp = [AUIMessageCreateGroupResponse new];
                rsp.groupId = groupID;
                callback(rsp, nil);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil, s_error_interaction(error));
            }
        });
    }];
}

- (void)joinGroup:(AUIMessageJoinGroupRequest *)req callback:(AUIMessageDefaultCallback)callback {
    [self.interactionEngine.interactionService joinGroup:req.groupId userNick:self.userInfo.userNick userAvatar:self.userInfo.userAvatar userExtension:@"{}" broadCastType:2 broadCastStatistics:YES onSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        NSLog(@"AUIMessageServiceImpl_Alivc##joinGroup(%d,%@)", error.code, error.message);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(s_error_interaction(error));
            }
        });
    }];
}

- (void)leaveGroup:(AUIMessageLeaveGroupRequest *)req callback:(AUIMessageDefaultCallback)callback {
    [self.interactionEngine.interactionService leaveGroup:req.groupId broadCastType:0 onSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        NSLog(@"AUIMessageServiceImpl_Alivc##leaveGroup(%d,%@)", error.code, error.message);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(s_error_interaction(error));
            }
        });
    }];
}

- (void)sendMessageToGroup:(AUIMessageSendMessageToGroupRequest *)req callback:(AUIMessageSendMessageToGroupCallback)callback {
    
#ifndef ALIVC_IM_VERSION_1_1
    AVCInteractionSendMessageToGroupReq *avReq = [AVCInteractionSendMessageToGroupReq new];
    avReq.groupId = req.groupId;
    avReq.type = (int32_t)req.msgType;
    avReq.skipAudit = req.skipAudit;
    avReq.skipMuteCheck = YES;
    avReq.message = [AUIMessageHelper jsonStringWithDict:[req.data toData]];
    [self.interactionEngine.interactionService sendTextMessage:avReq onSuccess:^(AVCInteractionSendMessageToGroupRsp * _Nonnull avRsp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                AUIMessageSendMessageToGroupResponse *rsp = [AUIMessageSendMessageToGroupResponse new];
                rsp.messageId = avRsp.messageId;
                callback(rsp, nil);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil, s_error_interaction(error));
            }
        });
    }];*/
#else
    [self.interactionEngine.interactionService sendTextMessage:[AUIMessageHelper jsonStringWithDict:[req.data toData]] groupID:req.groupId type:(int32_t)req.msgType skipMuteCheck:YES skipAudit:req.skipAudit onSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                AUIMessageSendMessageToGroupResponse *rsp = [AUIMessageSendMessageToGroupResponse new];
//                rsp.messageId = nil;
                callback(rsp, nil);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil, s_error_interaction(error));
            }
        });
    }];
#endif
}

- (void)sendMessageToGroupUser:(AUIMessageSendMessageToGroupUserRequest *)req callback:(AUIMessageSendMessageToGroupUserCallback)callback {
    
    if (req.receiverId.length == 0) {
        if (callback) {
            callback(nil, s_error(-1, @"param error: receiverId is empty"));
        }
        return;
    }
    
    if (req.groupId.length == 0 && self.class.globalGroupId.length == 0) {
        if (callback) {
            callback(nil, s_error(-1, @"param error: groupId is empty"));
        }
        return;
    }
    NSString *groupId = req.groupId.length == 0 ? self.class.globalGroupId : req.groupId;
    
#ifndef ALIVC_IM_VERSION_1_1
    AVCInteractionSendMessageToGroupUsersReq *avReq = [AVCInteractionSendMessageToGroupUsersReq new];
    avReq.groupId = groupId;
    avReq.type = (int32_t)req.msgType;
    avReq.level = 2;
    avReq.message = [AUIMessageHelper jsonStringWithDict:[req.data toData]];
    avReq.userIDs = @[req.receiverId];
    avReq.skipAudit = req.skipAudit;
    avReq.skipMuteCheck = YES;
    [self.interactionEngine.interactionService sendTextMessageToGroupUsers:avReq onSuccess:^(AVCInteractionSendMessageToGroupUsersRsp * _Nonnull avRsp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                AUIMessageSendMessageToGroupUserResponse *rsp = [AUIMessageSendMessageToGroupUserResponse new];
                rsp.messageId = avRsp.messageId;
                callback(rsp, nil);
            }
        });
        
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil, s_error_interaction(error));
            }
        });
    }];*/
#else
    [self.interactionEngine.interactionService sendTextMessageToGroupUsers:[AUIMessageHelper jsonStringWithDict:[req.data toData]] groupID:groupId type:(int32_t)req.msgType userIDs:@[req.receiverId] skipMuteCheck:YES skipAudit:req.skipAudit onSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                AUIMessageSendMessageToGroupUserResponse *rsp = [AUIMessageSendMessageToGroupUserResponse new];
//                rsp.messageId = avRsp.messageId;
                callback(rsp, nil);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil, s_error_interaction(error));
            }
        });
    }];
#endif
}

#pragma mark - IM

#ifndef ALIVC_IM_VERSION_1_1
- (void)setupEngineIfNeed {
    if (![AVCIInteractionEngine sharedInstanced].config && self.config) {
        __weak typeof(self) weakSelf = self;
        AVCIInteractionEngineConfig *interactionEngineConfig =  [[AVCIInteractionEngineConfig alloc] init];
        interactionEngineConfig.deviceID = AUIMessageConfig.deviceId;
        interactionEngineConfig.requestToken = ^(void (^ _Nonnull onRequestedToken)(NSString * _Nonnull, NSString * _Nonnull)) {
            
            void (^processToken)(NSString *finalToken) = ^(NSString *finalToken){
                NSString *accessToken = @"";
                NSString *refreshToken = @"";
                NSArray *array = [finalToken componentsSeparatedByString:@"_"];
                if (array.count == 2) {
                    accessToken = array.firstObject;
                    refreshToken = array.lastObject;
                }
                NSLog(@"AUIMessageServiceImpl_Alivc##requestToken {\n accessToken:%@\nrefreshToken:%@\n}", accessToken, refreshToken);
                if (onRequestedToken) {
                    onRequestedToken(refreshToken, accessToken);
                }
            };
            
            if (weakSelf.loginToken.length > 0) {
                processToken(weakSelf.loginToken);
            }
            else if ([weakSelf.connectionDelegate respondsToSelector:@selector(onTokenExpire)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.connectionDelegate onTokenExpire];
                });
                return;
            }
            else {
                processToken(nil);
            }
            
        };
        [AVCIInteractionEngine sharedInstanced].config = interactionEngineConfig;
        [AVCIInteractionEngine sharedInstanced].delegate = self;
    }
}

- (AVCIInteractionEngine *)interactionEngine {
    [self setupEngineIfNeed];
    return [AVCIInteractionEngine sharedInstanced];
}

- (id)getNativeEngine {
    return [AVCIInteractionEngine sharedInstanced];
}

#else

static AVCIInteractionEngine *_engine = nil;
- (AVCIInteractionEngine *)interactionEngine {
    if (!_engine && self.config) {
        __weak typeof(self) weakSelf = self;
        AVCIInteractionEngineConfig *interactionEngineConfig =  [[AVCIInteractionEngineConfig alloc] init];
        interactionEngineConfig.deviceID = AUIMessageConfig.deviceId;
        interactionEngineConfig.requestToken = ^(void (^ _Nonnull onRequestedToken)(NSString * _Nonnull, NSString * _Nonnull)) {
            
            void (^processToken)(NSString *finalToken) = ^(NSString *finalToken){
                NSString *accessToken = @"";
                NSString *refreshToken = @"";
                NSArray *array = [finalToken componentsSeparatedByString:@"_"];
                if (array.count == 2) {
                    accessToken = array.firstObject;
                    refreshToken = array.lastObject;
                }
                else {
                    accessToken = finalToken;
                    refreshToken = finalToken;
                }
                NSLog(@"AUIMessageServiceImpl_Alivc##requestToken {\n accessToken:%@\nrefreshToken:%@\n}", accessToken, refreshToken);
                if (onRequestedToken) {
                    onRequestedToken(refreshToken, accessToken);
                }
            };
            
            if (weakSelf.loginToken.length > 0) {
                processToken(weakSelf.loginToken);
            }
            else if ([weakSelf.connectionDelegate respondsToSelector:@selector(onTokenExpire)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.connectionDelegate onTokenExpire];
                });
                return;
            }
            else {
                processToken(nil);
            }
        };
        _engine = [[AVCIInteractionEngine alloc] initWithConfig:interactionEngineConfig];
        _engine.delegate = self;
    }
    return _engine;
}

- (id)getNativeEngine {
    return _engine;
}


#endif


#pragma mark - AVCIInteractionEngineDelegate

- (void)onKickout:(NSString *)info {
    ;
}

- (void)onError:(AVCIInteractionError *)error {
    NSLog(@"AUIMessageServiceImpl_Alivc##onError:%d, message:%@", error.code, error.message);
}

- (void)onConnectionStatusChanged:(int32_t)status {
    NSLog(@"AUIMessageServiceImpl_Alivc##onConnectionStatusChanged:%d", status);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == 4) {
            self.interactionEngine.interactionService.delegate = self;
            if (self.loginCallback) {
                self.loginCallback(nil);
            }
            self.loginCallback = nil;
            if (self.class.globalGroupId.length > 0) {
                // 加入一个globalGroup中，用于保障点对点通讯
                [self.interactionEngine.interactionService joinGroup:self.class.globalGroupId userNick:@"" userAvatar:@"" userExtension:@"{}" broadCastType:0 broadCastStatistics:YES onSuccess:^{
                    
                } onFailure:^(AVCIInteractionError * _Nonnull error) {
                    
                }];
            }
        }
    });
}

- (void)onLog:(NSString *)log level:(AliInteractionLogLevel)level {
//    NSLog(@"AUIMessageServiceImpl_Alivcon##onLog:%@", log);
}

#pragma mark - AVCIInteractionServiceDelegate

- (void)onCustomMessageReceived:(AVCIInteractionGroupMessage *)message {
    NSLog(@"AUIMessageServiceImpl_Alivc##onCustomMessageReceived:%@, data:%@, type:%d, gid:%@, uid:%@, nick_name:%@", message.messageId, message.data, message.type, message.groupId, message.senderInfo.userID, message.senderInfo.userNick);
    if ([message.groupId isEqualToString:self.class.globalGroupId]) {
        message.groupId = @"";
    }
    [self.listenerObserver onMessageReceived:[self messageModelFromMessage:message]];
}

- (void)onLikeReceived:(AVCIInteractionGroupMessage *)message {
    NSLog(@"AUIMessageServiceImpl_Alivc##onLikeReceived:%@, type:%d, gid:%@, uid:%@, nick_name:%@", message.data, message.type, message.groupId, message.senderInfo.userID, message.senderInfo.userNick);
    if ([message.groupId isEqualToString:self.class.globalGroupId]) {
        return;
    }
    [self.listenerObserver onMessageReceived:[self messageModelFromMessage:message]];
}

- (void)onJoinGroup:(AVCIInteractionGroupMessage *)message {
    NSLog(@"AUIMessageServiceImpl_Alivc##onJoinGroup:%@, type:%d, gid:%@, uid:%@, nick_name:%@", message.data, message.type, message.groupId, message.senderInfo.userID, message.senderInfo.userNick);
    if ([message.groupId isEqualToString:self.class.globalGroupId]) {
        return;
    }
    [self.listenerObserver onJoinGroup:[self messageModelFromMessage:message]];
}

- (void)onLeaveGroup:(AVCIInteractionGroupMessage *)message {
    NSLog(@"AUIMessageServiceImpl_Alivc##onLeaveGroup:%@, type:%d, gid:%@, uid:%@, nick_name:%@", message.data, message.type, message.groupId, message.senderInfo.userID, message.senderInfo.userNick);
    if ([message.groupId isEqualToString:self.class.globalGroupId]) {
        return;
    }
    [self.listenerObserver onLeaveGroup:[self messageModelFromMessage:message]];
}

- (void)onMuteGroup:(AVCIInteractionGroupMessage *)message {
    NSLog(@"AUIMessageServiceImpl_Alivc##onMuteGroup:%@, type:%d, gid:%@, uid:%@, nick_name:%@", message.data, message.type, message.groupId, message.senderInfo.userID, message.senderInfo.userNick);
    if ([message.groupId isEqualToString:self.class.globalGroupId]) {
        return;
    }
    [self.listenerObserver onMuteGroup:[self messageModelFromMessage:message]];
}

- (void)onCancelMuteGroup:(AVCIInteractionGroupMessage *)message {
    NSLog(@"AUIMessageServiceImpl_Alivc##onCancelMuteGroup:%@, type:%d, gid:%@, uid:%@, nick_name:%@", message.data, message.type, message.groupId, message.senderInfo.userID, message.senderInfo.userNick);
    if ([message.groupId isEqualToString:self.class.globalGroupId]) {
        return;
    }
    [self.listenerObserver onUnmuteGroup:[self messageModelFromMessage:message]];
}

- (void)onMuteUser:(AVCIInteractionGroupMessage *)message {
    NSLog(@"AUIMessageServiceImpl_Alivc##onMuteUser:%@, type:%d, gid:%@, uid:%@, nick_name:%@", message.data, message.type, message.groupId, message.senderInfo.userID, message.senderInfo.userNick);
}

- (void)onCancelMuteUser:(AVCIInteractionGroupMessage *)message {
    NSLog(@"AUIMessageServiceImpl_Alivc##onCancelMuteUser:%@, type:%d, gid:%@, uid:%@, nick_name:%@", message.data, message.type, message.groupId, message.senderInfo.userID, message.senderInfo.userNick);
}

- (AUIMessageModel *)messageModelFromMessage:(AVCIInteractionGroupMessage *)message {
    AUIMessageModel *model = [AUIMessageModel new];
    model.messageId = message.messageId;
    model.groupId = message.groupId;
    model.msgType = message.type;
    model.data = [self dictFromMessage:message];
    model.sender = [self senderFromMessage:message];
    return model;
}

- (id<AUIUserProtocol>)senderFromMessage:(AVCIInteractionGroupMessage *)message {
    id<AUIUserProtocol> sender = [[AUIMessageUserInfo alloc] init:message.senderInfo.userID ?: message.senderId];
    sender.userNick = message.senderInfo.userNick;
    sender.userAvatar = message.senderInfo.userAvatar;
    return sender;
}

- (NSDictionary *)dictFromMessage:(AVCIInteractionGroupMessage *)message {
    NSDictionary *dict = nil;
    if ([message.data isKindOfClass:NSDictionary.class]) {
        dict = message.data;
    }
    else if ([message.data isKindOfClass:NSString.class]) {
        dict = [NSJSONSerialization JSONObjectWithData:[message.data dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    }
    return dict;
}

@end
