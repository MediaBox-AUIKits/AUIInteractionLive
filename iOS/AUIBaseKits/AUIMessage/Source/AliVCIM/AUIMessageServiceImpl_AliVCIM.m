//
//  AUIMessageServiceImpl_AliVCIM.m
//

#import "AUIMessageServiceImpl_AliVCIM.h"
#import "AUIMessageHelper.h"

#import <AliVCInteractionMessage/AliVCInteractionMessage.h>

@interface AUIMessageServiceImpl_AliVCIM () <AliVCIMEngineListenerProtocol, AliVCIMGroupListenerProtocol, AliVCIMMessageListenerProtocol>

@property (nonatomic, strong) AUIMessageConfig *config;
@property (nonatomic, strong) id<AUIUserProtocol> userInfo;
@property (nonatomic, strong) AliVCIMAuthToken *nativeAuthToken;
@property (nonatomic, weak) id<AUIMessageServiceConnectionDelegate> connectionDelegate;
@property (nonatomic, weak) id<AUIMessageServiceUnImplDelegate> unImplDelegate;
@property (nonatomic, strong) AUIMessageListenerObserver *listenerObserver;

@property (nonatomic, strong) NSMutableDictionary<NSString *, AliVCIMGroupMuteStatus *> *muteStatus;

@end


@implementation AUIMessageServiceImpl_AliVCIM

static NSString *userExtension(id<AUIUserProtocol> userInfo) {
    NSDictionary *dict = @{
        @"userNick":userInfo.userNick ?: @"",
        @"userAvatar":userInfo.userAvatar ?: @"",
    };
    return [AUIMessageHelper jsonStringWithDict:dict];
}

static void parseUserExtension(NSString *userExtension, id<AUIUserProtocol> userInfo) {
    NSDictionary *dict = [AUIMessageHelper parseJson:userExtension];
    userInfo.userNick = [dict objectForKey:@"userNick"];
    userInfo.userAvatar = [dict objectForKey:@"userAvatar"];
}

- (NSMutableDictionary<NSString *,AliVCIMGroupMuteStatus *> *)muteStatus {
    if (!_muteStatus) {
        _muteStatus = [NSMutableDictionary dictionary];
    }
    return _muteStatus;
}

- (AUIMessageServiceImplType)implType {
    return AUIMessageServiceImplTypeAlivcIM;
}

- (AliVCIMEngineConfig *)createEngineConfig:(NSDictionary *)tokenData {
    if (tokenData.count == 0) {
        return nil;
    }
    
    NSString *appId = [tokenData objectForKey:@"app_id"];
    NSString *appSign = [tokenData objectForKey:@"app_sign"];
    NSString *source = [tokenData objectForKey:@"source"];
    
    AliVCIMEngineConfig *nativeConfig = [AliVCIMEngineConfig new];
    nativeConfig.deviceId = AUIMessageConfig.deviceId;
    nativeConfig.appId = appId;
    nativeConfig.appSign = appSign;
    nativeConfig.source = source ?: @"aui-message";
    nativeConfig.extra = @{@"scene":source ?: @"aui-message"};
    return nativeConfig;
}

- (AliVCIMAuthToken *)createAuthToken:(NSDictionary *)tokenData {
    if (tokenData.count == 0) {
        return nil;
    }
    
    NSString *appToken = [tokenData objectForKey:@"app_token"];
    NSDictionary *authData = [tokenData objectForKey:@"auth"];

    AliVCIMAuthToken *nativeAuthToken = [AliVCIMAuthToken new];
    nativeAuthToken.token = appToken;
    nativeAuthToken.role = [authData objectForKey:@"role"];
    nativeAuthToken.timestamp = [[authData objectForKey:@"timestamp"] longValue];
    nativeAuthToken.nonce = [authData objectForKey:@"nonce"];
    return nativeAuthToken;
}

- (void)setConfig:(AUIMessageConfig *)config {
    AliVCIMEngineConfig *oldNativeConfig = [self createEngineConfig:_config.tokenData];
    
    AliVCIMEngineConfig *newNativeConfig = [self createEngineConfig:config.tokenData];
#ifdef DEBUG
    newNativeConfig.logLevel = AliVCIMLogLevelDebug;
#endif
    
    if (![oldNativeConfig.appId isEqualToString:newNativeConfig.appId] ||
        ![oldNativeConfig.appSign isEqualToString:newNativeConfig.appSign]) {
        [[AliVCIMEngine sharedEngine] destroy];
    }
    
    
    [[AliVCIMEngine sharedEngine] setup:newNativeConfig];
    [[AliVCIMEngine sharedEngine] addListener:self];
    
    _config = config;
    NSLog(@"AUIMessageServiceImpl_AliVCIM##setConfig: %@", _config.tokenData);
    _nativeAuthToken = [self createAuthToken:_config.tokenData];;
}

- (AUIMessageConfig *)getConfig {
    return _config;
}

- (void)setConnectionDelegate:(id<AUIMessageServiceConnectionDelegate>)connectionDelegate {
    _connectionDelegate = connectionDelegate;
}

- (void)setUnImplDelegate:(id<AUIMessageServiceUnImplDelegate>)unImplDelegate {
    _unImplDelegate = unImplDelegate;
}

- (id<AUIUserProtocol>)currentUserInfo {
    if ([self isLogin]) {
        return self.userInfo;
    }
    return nil;
}

- (BOOL)isLogin {
    return [[AliVCIMEngine sharedEngine] isLogin];
}

- (void)login:(id<AUIUserProtocol>)userInfo callback:(AUIMessageDefaultCallback)callback {
    if ([self isLogin]) {
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
    NSLog(@"AUIMessageServiceImpl_AliVCIM##login");
    self.userInfo = userInfo;
    
    AliVCIMUser *nativeUser = [AliVCIMUser new];
    nativeUser.userId = self.userInfo.userId;
    nativeUser.userExtension = userExtension(self.userInfo);
    
    AliVCIMLoginReq *req = [AliVCIMLoginReq new];
    req.currentUser = nativeUser;
    req.authToken = self.nativeAuthToken;
    [[AliVCIMEngine sharedEngine] login:req completed:^(NSError * _Nullable error) {
        NSLog(@"AUIMessageServiceImpl_AliVCIM##login result:%@", error);
        if (!error) {
            [[[AliVCIMEngine sharedEngine] getGroupManager] addListener:self];
            [[[AliVCIMEngine sharedEngine] getMessageManager] addListener:self];
        }
        if (callback) {
            callback(error);
        }
    }];
}

- (void)logout:(AUIMessageDefaultCallback)callback {
    NSLog(@"AUIMessageServiceImpl_AliVCIM##logout");
    [self.muteStatus removeAllObjects];
    [[AliVCIMEngine sharedEngine] logout:^(NSError * _Nullable error) {
        NSLog(@"AUIMessageServiceImpl_AliVCIM##logout result:%@", error);
        if (!error) {
            [[[AliVCIMEngine sharedEngine] getGroupManager] removeListener:self];
            [[[AliVCIMEngine sharedEngine] getMessageManager] removeListener:self];
        }
        if (callback) {
            callback(error);
        }
    }];
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
    NSLog(@"AUIMessageServiceImpl_AliVCIM##getGroupInfo");
    AliVCIMQueryGroupReq *nativeReq = [AliVCIMQueryGroupReq new];
    nativeReq.groupId = req.groupId;
    [[[AliVCIMEngine sharedEngine] getGroupManager] queryGroup:nativeReq completed:^(AliVCIMQueryGroupRsp * _Nullable nativeRsp, NSError * _Nullable error) {
        NSLog(@"AUIMessageServiceImpl_AliVCIM##getGroupInfo result:%@", error);
        if (nativeRsp) {
            // update mute status
            [self.muteStatus setObject:nativeRsp.groupInfo.muteStatus forKey:nativeRsp.groupInfo.groupId];
            if (callback) {
                AUIMessageGetGroupInfoResponse *rsp = [AUIMessageGetGroupInfoResponse new];
                rsp.groupId = nativeRsp.groupInfo.groupId;
                rsp.onlineCount = nativeRsp.groupInfo.statistics.onlineCount;
                rsp.pv = nativeRsp.groupInfo.statistics.pv;
                callback(rsp, nil);
            }
        }
        else {
            if (callback) {
                callback(nil, error);
            }
        }
    }];
}

- (void)createGroup:(AUIMessageCreateGroupRequest *)req callback:(AUIMessageCreateGroupCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback(nil, [AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    NSLog(@"AUIMessageServiceImpl_AliVCIM##createGroup");
    AliVCIMCreateGroupReq *nativeReq = [AliVCIMCreateGroupReq new];
    nativeReq.groupId = req.groupId.length > 0 ? req.groupId : NSUUID.UUID.UUIDString.lowercaseString;
    nativeReq.groupName = req.groupName.length > 0 ? req.groupName : @"default";
    nativeReq.groupMeta = req.groupExtension;
    [[[AliVCIMEngine sharedEngine] getGroupManager] createGroup:nativeReq completed:^(AliVCIMCreateGroupRsp * _Nullable nativeRsp, NSError * _Nullable error) {
        NSLog(@"AUIMessageServiceImpl_AliVCIM##createGroup result:%@", error);
        if (nativeRsp) {
            if (callback) {
                AUIMessageCreateGroupResponse *rsp = [AUIMessageCreateGroupResponse new];
                rsp.groupId = nativeRsp.groupId;
                rsp.alreadyExist = nativeRsp.alreadyExist;
                callback(rsp, nil);
            }
        }
        else {
            if (callback) {
                callback(nil, error);
            }
        }
    }];
}

- (void)joinGroup:(AUIMessageJoinGroupRequest *)req callback:(AUIMessageDefaultCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback([AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    NSLog(@"AUIMessageServiceImpl_AliVCIM##joinGroup");
    AliVCIMJoinGroupReq *nativeReq = [AliVCIMJoinGroupReq new];
    nativeReq.groupId = req.groupId;
    [[[AliVCIMEngine sharedEngine] getGroupManager] joinGroup:nativeReq completed:^(AliVCIMJoinGroupRsp * _Nullable nativeRsp, NSError * _Nullable error) {
        NSLog(@"AUIMessageServiceImpl_AliVCIM##joinGroup result:%@", error);
        if (nativeRsp) {
            [self.muteStatus setObject:nativeRsp.groupInfo.muteStatus forKey:nativeRsp.groupInfo.groupId];
        }
        if (callback) {
            if (error.code == AliVCIMErrorHasJoinGroup) {
                callback(nil);
            }
            else {
                callback(error);
            }
        }
    }];
}

- (void)joinGroup:(AUIMessageJoinGroupRequest *)req groupInfoCallback:(AUIMessageGetGroupInfoCallback)groupInfoCallback {
    if (![self isLogin]) {
        if (groupInfoCallback) {
            groupInfoCallback(nil, [AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    NSLog(@"AUIMessageServiceImpl_AliVCIM##joinGroup groupInfoCallback");
    AliVCIMJoinGroupReq *nativeReq = [AliVCIMJoinGroupReq new];
    nativeReq.groupId = req.groupId;
    [[[AliVCIMEngine sharedEngine] getGroupManager] joinGroup:nativeReq completed:^(AliVCIMJoinGroupRsp * _Nullable nativeRsp, NSError * _Nullable error) {
        NSLog(@"AUIMessageServiceImpl_AliVCIM##joinGroup groupInfoCallback result:%@", error);
        if (nativeRsp) {
            [self.muteStatus setObject:nativeRsp.groupInfo.muteStatus forKey:nativeRsp.groupInfo.groupId];
        }
        if (groupInfoCallback) {
            if (error.code == AliVCIMErrorHasJoinGroup) {
                AUIMessageGetGroupInfoRequest *getGroupInfoReq = [AUIMessageGetGroupInfoRequest new];
                getGroupInfoReq.groupId = req.groupId;
                [self getGroupInfo:getGroupInfoReq callback:groupInfoCallback];
            }
            else if (error) {
                groupInfoCallback(nil, error);
            }
            else {
                AUIMessageGetGroupInfoResponse *getGroupInfoRes = [AUIMessageGetGroupInfoResponse new];
                getGroupInfoRes.groupId = nativeRsp.groupInfo.groupId;
                getGroupInfoRes.onlineCount = nativeRsp.groupInfo.statistics.onlineCount;
                getGroupInfoRes.pv = nativeRsp.groupInfo.statistics.pv;
                groupInfoCallback(getGroupInfoRes, nil);
            }
        }
    }];
}

- (void)leaveGroup:(AUIMessageLeaveGroupRequest *)req callback:(AUIMessageDefaultCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback([AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    NSLog(@"AUIMessageServiceImpl_AliVCIM##leaveGroup");
    AliVCIMLeaveGroupReq *nativeReq = [AliVCIMLeaveGroupReq new];
    nativeReq.groupId = req.groupId;
    [[[AliVCIMEngine sharedEngine] getGroupManager] leaveGroup:nativeReq completed:^(NSError * _Nullable error) {
        NSLog(@"AUIMessageServiceImpl_AliVCIM##leaveGroup result:%@", error);
        if (!error) {
            [self.muteStatus removeObjectForKey:req.groupId];
        }
        if (callback) {
            callback(error);
        }
    }];
}

- (void)muteAll:(AUIMessageMuteAllRequest *)req callback:(AUIMessageDefaultCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback([AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    NSLog(@"AUIMessageServiceImpl_AliVCIM##muteAll");
    AliVCIMMuteAllReq *nativeReq = [AliVCIMMuteAllReq new];
    nativeReq.groupId = req.groupId;
    [[[AliVCIMEngine sharedEngine] getGroupManager] muteAll:nativeReq completed:^(NSError * _Nullable error) {
        NSLog(@"AUIMessageServiceImpl_AliVCIM##muteAll result:%@", error);
        if (callback) {
            callback(error);
        }
    }];
}

- (void)cancelMuteAll:(AUIMessageCancelMuteAllRequest *)req callback:(AUIMessageDefaultCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback([AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    NSLog(@"AUIMessageServiceImpl_AliVCIM##cancelMuteAll");
    AliVCIMCancelMuteAllReq *nativeReq = [AliVCIMCancelMuteAllReq new];
    nativeReq.groupId = req.groupId;
    [[[AliVCIMEngine sharedEngine] getGroupManager] cancelMuteAll:nativeReq completed:^(NSError * _Nullable error) {
        NSLog(@"AUIMessageServiceImpl_AliVCIM##cancelMuteAll result:%@", error);
        if (callback) {
            callback(error);
        }
    }];
}

- (void)queryMuteAll:(AUIMessageQueryMuteAllRequest *)req callback:(AUIMessageQueryMuteAllCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback(nil, [AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    
    AliVCIMGroupMuteStatus *status = [self.muteStatus objectForKey:req.groupId];
    if (status) {
        if (callback) {
            AUIMessageQueryMuteAllResponse *rsp = [AUIMessageQueryMuteAllResponse new];
            rsp.groupId = status.groupId;
            rsp.isMuteAll = status.muteAll;
            callback(rsp, nil);
        }
        return;
    }
    NSLog(@"AUIMessageServiceImpl_AliVCIM##queryMuteAll");
    AliVCIMQueryGroupReq *nativeReq = [AliVCIMQueryGroupReq new];
    nativeReq.groupId = req.groupId;
    [[[AliVCIMEngine sharedEngine] getGroupManager] queryGroup:nativeReq completed:^(AliVCIMQueryGroupRsp * _Nullable nativeRsp, NSError * _Nullable error) {
        NSLog(@"AUIMessageServiceImpl_AliVCIM##queryMuteAll result:%@", error);
        if (nativeRsp) {
            // update mute status
            [self.muteStatus setObject:nativeRsp.groupInfo.muteStatus forKey:nativeRsp.groupInfo.groupId];
            if (callback) {
                AUIMessageQueryMuteAllResponse *rsp = [AUIMessageQueryMuteAllResponse new];
                rsp.groupId = nativeRsp.groupInfo.groupId;
                rsp.isMuteAll = status.muteAll;
                callback(rsp, nil);
            }
        }
        else {
            if (callback) {
                callback(nil, error);
            }
        }
    }];
}

- (void)sendLike:(AUIMessageSendLikeRequest *)req callback:(AUIMessageDefaultCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback([AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    NSLog(@"AUIMessageServiceImpl_AliVCIM##sendLike");
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
    NSLog(@"AUIMessageServiceImpl_AliVCIM##sendMessageToGroup");
    AliVCIMSendMessageToGroupReq *nativeReq = [AliVCIMSendMessageToGroupReq new];
    nativeReq.groupId = req.groupId;
    nativeReq.type = (int)req.msgType;
    nativeReq.skipMuteCheck = req.skipMuteCheck;
    nativeReq.skipAudit = req.skipAudit;
    nativeReq.level = (AliVCIMMessageLevel)req.msgLevel;
    nativeReq.noStorage = !req.storage;
    nativeReq.repeatCount = (int)req.repeatCount;
    nativeReq.data = [AUIMessageHelper jsonStringWithDict:[req.data toData]] ?: @"{}";
    [[[AliVCIMEngine sharedEngine] getMessageManager] sendGroupMessage:nativeReq completed:^(AliVCIMSendMessageToGroupRsp * _Nullable nativeRsp, NSError * _Nullable error) {
        NSLog(@"AUIMessageServiceImpl_AliVCIM##sendMessageToGroup result:%@", error);
        if (nativeRsp) {
            if (callback) {
                AUIMessageSendMessageToGroupResponse *rsp = [AUIMessageSendMessageToGroupResponse new];
                rsp.messageId = nativeRsp.messageId;
                callback(rsp, nil);
            }
        }
        else {
            if (callback) {
                callback(nil, error);
            }
        }
    }];
}

- (void)sendMessageToGroupUser:(AUIMessageSendMessageToGroupUserRequest *)req callback:(AUIMessageSendMessageToGroupUserCallback)callback {
    if (![self isLogin]) {
        if (callback) {
            callback(nil, [AUIMessageHelper error:AUIMessageErrorTypeInvalidState msg:@"need login"]);
        }
        return;
    }
    NSLog(@"AUIMessageServiceImpl_AliVCIM##sendMessageToGroupUser");
    AliVCIMSendMessageToUserReq *nativeReq = [AliVCIMSendMessageToUserReq new];
    nativeReq.reveiverId = req.receiverId;
    nativeReq.type = (int)req.msgType;
    nativeReq.skipAudit = req.skipAudit;
    nativeReq.level = (AliVCIMMessageLevel)req.msgLevel;
    NSMutableDictionary *sendData = [NSMutableDictionary dictionary];
    [sendData setObject:[AUIMessageHelper jsonStringWithDict:[req.data toData]] ?: @"{}" forKey:@"data"];
    [sendData setObject:req.groupId ?: @"" forKey:@"groupId"];
    nativeReq.data = [AUIMessageHelper jsonStringWithDict:sendData] ?: @"{}";
    [[[AliVCIMEngine sharedEngine] getMessageManager] sendC2CMessage:nativeReq completed:^(AliVCIMSendMessageToUserRsp * _Nullable nativeRsp, NSError * _Nullable error) {
        NSLog(@"AUIMessageServiceImpl_AliVCIM##sendMessageToGroupUser result:%@", error);
        if (nativeRsp) {
            if (callback) {
                AUIMessageSendMessageToGroupUserResponse *rsp = [AUIMessageSendMessageToGroupUserResponse new];
                rsp.messageId = nativeRsp.messageId;
                callback(rsp, nil);
            }
        }
        else {
            if (callback) {
                callback(nil, error);
            }
        }
    }];
}

- (id)getNativeEngine {
    return [AliVCIMEngine sharedEngine];
}

#pragma mark - AliVCIMEngineListenerProtocol

- (void)onIMEngineConnecting {
    NSLog(@"AUIMessageServiceImpl_AliVCIM##onIMEngineConnecting");
}

- (void)onIMEngineConnectSuccess {
    NSLog(@"AUIMessageServiceImpl_AliVCIM##onIMEngineConnectSuccess");
}

- (void)onIMEngineConnectFailed:(NSError *)error {
    NSLog(@"AUIMessageServiceImpl_AliVCIM##onIMEngineConnectFailed:%@", error);
}

- (void)onIMEngineDisconnect:(AliVCIMEngineDisconnectType)type {
    NSLog(@"AUIMessageServiceImpl_AliVCIM##onIMEngineDisconnect:%d", type);
    if (type != AliVCIMEngineDisconnectType_logout) {
        [self.muteStatus enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull groupId, AliVCIMGroupMuteStatus * _Nonnull obj, BOOL * _Nonnull stop) {
            [self.getListenerObserver onExitedGroup:groupId];
        }];
        [self.muteStatus removeAllObjects];
    }
}

- (void)onIMEngineReconnectSuccess:(NSArray<AliVCIMGroupInfo *> *)groupsStatus {
    NSLog(@"AUIMessageServiceImpl_AliVCIM##onIMEngineReconnectSuccess:%@", groupsStatus);
    [groupsStatus enumerateObjectsUsingBlock:^(AliVCIMGroupInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self imGroup:obj.groupId onMuteChanged:obj.muteStatus];
    }];
}

- (void)onIMEngineTokenExpired:(AliVCIMFetchAuthTokenBlock)fetchAuthTokenBlock {
    NSLog(@"AUIMessageServiceImpl_AliVCIM##onIMEngineTokenExpired");
    if ([self.connectionDelegate respondsToSelector:@selector(onTokenExpire:)]) {
        __weak typeof(self) weakSelf = self;
        [self.connectionDelegate onTokenExpire:^(NSError * _Nullable error) {
            
            if (error == nil) {
                weakSelf.nativeAuthToken = [weakSelf createAuthToken:weakSelf.config.tokenData];
                fetchAuthTokenBlock(weakSelf.nativeAuthToken, nil);
            }
            else {
                fetchAuthTokenBlock(weakSelf.nativeAuthToken, error);
            }
        }];
    }
    else {
        fetchAuthTokenBlock(nil, [NSError errorWithDomain:@"" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"umimplementation"}]);
    }
}

#pragma mark - AliVCIMGroupListenerProtocol

- (void)imGroup:(NSString *)groupId onMemberChanged:(int)memberCount joinUsers:(NSArray<AliVCIMUser *> *)joinUsers leaveUsers:(NSArray<AliVCIMUser *> *)leaveUsers {
    for (AliVCIMUser *user in joinUsers) {
        NSLog(@"AUIMessageServiceImpl_AliVCIM##imGroup:%@ onJoin: %@", groupId, user);
        AUIMessageUserInfo *sender = [[AUIMessageUserInfo alloc] init:user.userId];
        parseUserExtension(user.userExtension, sender);
        AUIMessageModel *model = [AUIMessageModel new];
        model.groupId = groupId;
        model.msgType = 1002;
        model.sender = sender;
        [self.listenerObserver onJoinGroup:model];
    }
    for (AliVCIMUser *user in leaveUsers) {
        NSLog(@"AUIMessageServiceImpl_AliVCIM##imGroup:%@ onLeave: %@", groupId, user);
        AUIMessageUserInfo *sender = [[AUIMessageUserInfo alloc] init:user.userId];
        parseUserExtension(user.userExtension, sender);
        AUIMessageModel *model = [AUIMessageModel new];
        model.groupId = groupId;
        model.msgType = 1003;
        model.sender = sender;
        [self.listenerObserver onLeaveGroup:model];
    }
    
    NSLog(@"AUIMessageServiceImpl_AliVCIM##imGroup:%@ onlineCountChanged: %d", groupId, memberCount);
    [self.listenerObserver onGroup:groupId onlineCountChanged:memberCount];
}

- (void)imGroup:(NSString *)groupId OnExited:(int)reason {
    NSLog(@"AUIMessageServiceImpl_AliVCIM##imGroup:%@ OnExited: %d", groupId, reason);
    [self.muteStatus removeObjectForKey:groupId];
    [self.getListenerObserver onExitedGroup:groupId];
}

- (void)imGroup:(NSString *)groupId onInfoChanged:(AliVCIMGroupInfoStatus *)status {
    NSLog(@"AUIMessageServiceImpl_AliVCIM##imGroup:%@ onInfoChanged: %@", groupId, status);
}

- (void)imGroup:(NSString *)groupId onMuteChanged:(AliVCIMGroupMuteStatus *)status {
    NSLog(@"AUIMessageServiceImpl_AliVCIM##imGroup:%@ onMuteChanged: %@", groupId, status);
    
    AliVCIMGroupMuteStatus *oldStatus = [self.muteStatus objectForKey:groupId];
    if (status.muteAll && (oldStatus == nil || !oldStatus.muteAll)) {
        AUIMessageModel *model = [AUIMessageModel new];
        model.groupId = groupId;
        model.msgType = 1004;
        [self.listenerObserver onMuteGroup:model];
    }
    else if (!status.muteAll && (oldStatus == nil || oldStatus.muteAll)) {
        AUIMessageModel *model = [AUIMessageModel new];
        model.groupId = groupId;
        model.msgType = 1005;
        [self.listenerObserver onUnmuteGroup:model];
    }
    [self.muteStatus setObject:status forKey:groupId];
}

#pragma mark - AliVCIMMessageListenerProtocol

- (void)onIMReceivedC2CMessage:(AliVCIMMessage *)message {
    NSLog(@"AUIMessageServiceImpl_AliVCIM##onIMReceivedC2CMessage: %@", message);
    AUIMessageModel *model = [AUIMessageModel new];
    model.groupId = message.groupId;
    model.msgType = message.type;
    model.messageId = message.messageId;
    model.msgLevel = (AUIMessageLevel)message.level;
    
    AUIMessageUserInfo *sender = [[AUIMessageUserInfo alloc] init:message.sender.userId];
    parseUserExtension(message.sender.userExtension, sender);
    model.sender = sender;
    
    NSString *dataString = message.data;
    if (dataString.length > 0) {
        NSDictionary *sendData = [AUIMessageHelper parseJson:dataString];
        model.groupId = [sendData objectForKey:@"groupId"];
        model.data = [AUIMessageHelper parseJson: [sendData objectForKey:@"data"]];;
    }
    
    [self.listenerObserver onMessageReceived:model];
}

- (void)onIMReceivedGroupMessage:(AliVCIMMessage *)message {
    NSLog(@"AUIMessageServiceImpl_AliVCIM##onIMReceivedGroupMessage: %@", message);
    AUIMessageModel *model = [AUIMessageModel new];
    model.groupId = message.groupId;
    model.msgType = message.type;
    model.messageId = message.messageId;
    model.msgLevel = (AUIMessageLevel)message.level;
    
    AUIMessageUserInfo *sender = [[AUIMessageUserInfo alloc] init:message.sender.userId];
    parseUserExtension(message.sender.userExtension, sender);
    model.sender = sender;
    
    NSString *dataString = message.data;
    if (dataString.length > 0) {
        model.data = [AUIMessageHelper parseJson:dataString];
    }
    
    [self.listenerObserver onMessageReceived:model];
}

@end
