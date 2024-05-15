//
//  AUIRoomMessageService.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/2/24.
//

#import "AUIRoomMessageService.h"
#import "AUIRoomSDKHeader.h"
#import "AUIRoomAccount.h"
#import "AUIRoomAppServer.h"
#import "AUIFoundation.h"

#define AUIRoomMessageTypeComment 10001


@interface AUIRoomMessageService : NSObject <AUIRoomMessageServiceProtocol, AUIMessageServiceUnImplDelegate, AUIMessageServiceConnectionDelegate, AUIMessageListenerProtocol>

@property (nonatomic, strong) id<AUIMessageServiceProtocol> messageService;
@property (nonatomic, strong) NSHashTable<id<AUIRoomMessageServiceObserver>> *observerList;

@end


@implementation AUIRoomMessageService

- (instancetype)init {
    self = [super init];
    if (self) {
        self.messageService = [AUIMessageServiceFactory getMessageService];
        [self.messageService setUnImplDelegate:self];
        [self.messageService setConnectionDelegate:self];
        [[self.messageService getListenerObserver] addListener:self];
    }
    return self;
}

#pragma mark - Observer

- (NSHashTable<id<AUIRoomMessageServiceObserver>> *)observerList {
    if (!_observerList) {
        _observerList = [NSHashTable weakObjectsHashTable];
    }
    return _observerList;
}

- (void)addObserver:(id<AUIRoomMessageServiceObserver>)observer {
    if ([self.observerList containsObject:observer]) {
        return;
    }
    [self.observerList addObject:observer];
}

- (void)removeObserver:(id<AUIRoomMessageServiceObserver>)observer {
    [self.observerList removeObject:observer];
}

- (void)fetchToken:(void(^)(NSDictionary *tokenData, NSError *error))completed {
    [AUIRoomAppServer fetchToken:^(NSDictionary * _Nullable data, NSError * _Nullable error) {
        if (completed) {
            if (error) {
                completed(nil, error);
                return;
            }
            NSDictionary *tokenData = [AUIRoomMessage fetchTokenData:data];
            if (tokenData == nil) {
                completed(nil, [NSError errorWithDomain:@"message.service" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"获取token数据出错"}]);
            }
            else {
                completed(tokenData, nil);
            }
        }
    }];
}

- (void)login:(void(^)(BOOL))completed {
    if (self.messageService.isLogin) {
        if (completed) {
            completed(YES);
        }
        return;
    }
    if (AUIRoomAccount.me.userId.length == 0) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self fetchToken:^(NSDictionary *tokenData, NSError *error) {
        if (error) {
            if (completed) {
                completed(NO);
            }
            return;
        }
        
        AUIMessageConfig *config = [AUIMessageConfig new];
        config.tokenData = tokenData;
        [weakSelf.messageService setConfig:config];
        
        AUIMessageUserInfo *user = [[AUIMessageUserInfo alloc] init:AUIRoomAccount.me.userId];
        user.userNick = AUIRoomAccount.me.nickName;
        user.userAvatar = AUIRoomAccount.me.avatar;
        [weakSelf.messageService login:user callback:^(NSError * _Nullable error) {
            if (completed) {
                completed(error == nil);
            }
        }];
    }];
}

- (void)logout {
    [self.messageService logout:^(NSError * _Nullable error) {
        
    }];
}

- (void)joinGroup:(NSString *)groupID completed:(AUIMessageDefaultCallback)completed {
    AUIMessageJoinGroupRequest *req = [AUIMessageJoinGroupRequest new];
    req.groupId = groupID;
    
    __weak typeof(self) weakSelf = self;
    [self.messageService joinGroup:req callback:^(NSError * _Nullable error) {
        if (completed) {
            completed(error);
        }
        
        if (!error) {
            // 需要查询当前房间是否全员禁言
            [weakSelf queryMuteAll:groupID completed:^(BOOL isMuteAll, NSError * _Nullable error) {
                if (!error) {
                    AUIMessageModel *model = [AUIMessageModel new];
                    model.groupId = groupID;
                    if (isMuteAll) {
                        [weakSelf onMuteGroup:model];
                    }
                    else {
                        [weakSelf onUnmuteGroup:model];
                    }
                }
            }];
        }
    }];
    
    
}

- (void)leaveGroup:(NSString *)groupID completed:(AUIMessageDefaultCallback)completed {
    AUIMessageLeaveGroupRequest *req = [AUIMessageLeaveGroupRequest new];
    req.groupId = groupID;
    [self.messageService leaveGroup:req callback:completed];
}

- (void)queryStatistics:(NSString *)groupID completed:(void (^)(NSInteger, NSInteger, NSError * _Nullable))completed {
    AUIMessageGetGroupInfoRequest *req = [AUIMessageGetGroupInfoRequest new];
    req.groupId = groupID;
    [self.messageService getGroupInfo:req callback:^(AUIMessageGetGroupInfoResponse * _Nullable rsp, NSError * _Nullable error) {
        if (completed) {
            if (error) {
                completed(-1, -1, error);
            }
            else {
                completed(rsp.pv, rsp.onlineCount, nil);
            }
        }
    }];
    
    // 如果AUIMessage的getGroupInfo不满足的情况下，则需要使用自建服务端实现
    // 可以打开以下注释代码，并需要服务端实现/api/v1/live/getStatistics接口
    /*
    [AUIRoomAppServer fetchStatistics:groupID completed:^(AUIRoomLiveMetricsModel * _Nullable model, NSError * _Nullable error) {
        
        if (model) {
            if (error) {
                completed(-1, -1, error);
            }
            else {
                completed(model.pv, model.online_count, nil);
            }
        }
    }];
     */
}

- (void)muteAll:(NSString *)groupID completed:(AUIMessageDefaultCallback)completed {
    AUIMessageMuteAllRequest *req = [AUIMessageMuteAllRequest new];
    req.groupId = groupID;
    [self.messageService muteAll:req callback:completed];
}

- (void)cancelMuteAll:(NSString *)groupID completed:(AUIMessageDefaultCallback)completed {
    AUIMessageCancelMuteAllRequest *req = [AUIMessageCancelMuteAllRequest new];
    req.groupId = groupID;
    [self.messageService cancelMuteAll:req callback:completed];
}

- (void)queryMuteAll:(NSString *)groupID completed:(void (^)(BOOL, NSError * _Nullable))completed {
    AUIMessageQueryMuteAllRequest *req = [AUIMessageQueryMuteAllRequest new];
    req.groupId = groupID;
    [self.messageService queryMuteAll:req callback:^(AUIMessageQueryMuteAllResponse * _Nullable rsp, NSError * _Nullable error) {
        if (completed) {
            completed(rsp.isMuteAll, error);
        }
    }];
}

- (void)sendLike:(NSString *)groupID count:(NSUInteger)count completed:(AUIMessageDefaultCallback)completed {
    AUIMessageSendLikeRequest *req = [AUIMessageSendLikeRequest new];
    req.groupId = groupID;
    req.count = count;
    [self.messageService sendLike:req callback:completed];
}

- (void)sendComment:(NSString *)groupID comment:(NSDictionary *)comment completed:(AUIMessageDefaultCallback)completed {
    AUIMessageSendMessageToGroupRequest *req = [AUIMessageSendMessageToGroupRequest new];
    req.groupId = groupID;
    req.data = [[AUIMessageDefaultData alloc] initWithData:comment];
    req.msgType = AUIRoomMessageTypeComment;
    req.skipAudit = NO;
    req.skipMuteCheck = NO;
    req.storage = YES;
    [self.messageService sendMessageToGroup:req callback:^(AUIMessageSendMessageToGroupResponse * _Nullable rsp, NSError * _Nullable error) {
        if (completed) {
            completed(error);
        }
    }];
}

- (void)sendCommand:(NSInteger)type data:(id<AUIMessageDataProtocol>)data groupID:(NSString *)groupID receiverId:(NSString *)receiverId completed:(AUIMessageDefaultCallback)completed {
    if (receiverId.length > 0) {
        AUIMessageSendMessageToGroupUserRequest *req = [AUIMessageSendMessageToGroupUserRequest new];
        req.groupId = groupID;
        req.data = data;
        req.msgType = type;
        req.receiverId = receiverId;
        req.skipAudit = YES;
        
        [self.messageService sendMessageToGroupUser:req callback:^(AUIMessageSendMessageToGroupUserResponse * _Nullable rsp, NSError * _Nullable error) {
            if (completed) {
                completed(error);
            }
        }];
    }
    else if (groupID.length > 0) {
        AUIMessageSendMessageToGroupRequest *req = [AUIMessageSendMessageToGroupRequest new];
        req.groupId = groupID;
        req.data = data;
        req.msgType = type;
        req.skipAudit = YES;
        req.skipMuteCheck = YES;
        req.storage = NO;
        [self.messageService sendMessageToGroup:req callback:^(AUIMessageSendMessageToGroupResponse * _Nullable rsp, NSError * _Nullable error) {
            if (completed) {
                completed(error);
            }
        }];
    }
    else {
        if (completed) {
            completed([NSError errorWithDomain:@"message.service" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"参数出错"}]);
        }
    }
}

#pragma mark - AUIMessageServiceUnImplDelegate

- (void)muteAll:(AUIMessageMuteAllRequest *)req callback:(AUIMessageDefaultCallback)callback {
    // 当AUIMessageService的实现不支持时，会通过该接口回调，这时需要使用服务端接口来实现
    [AUIRoomAppServer muteAll:req.groupId completed:callback];
}

- (void)cancelMuteAll:(AUIMessageCancelMuteAllRequest *)req callback:(AUIMessageDefaultCallback)callback {
    // 当AUIMessageService的实现不支持时，会通过该接口回调，这时需要使用服务端接口来实现
    [AUIRoomAppServer cancelMuteAll:req.groupId completed:callback];
}

- (void)queryMuteAll:(AUIMessageQueryMuteAllRequest *)req callback:(AUIMessageQueryMuteAllCallback)callback {
    // 当AUIMessageService的实现不支持时，会通过该接口回调，这时需要使用服务端接口来实现
    [AUIRoomAppServer queryMuteAll:req.groupId completed:^(BOOL isMuteAll, NSError * _Nullable error) {
        if (error) {
            if (callback) {
                callback(nil, error);
            }
        }
        else {
            if (callback) {
                AUIMessageQueryMuteAllResponse *rsp = [AUIMessageQueryMuteAllResponse new];
                rsp.groupId = req.groupId;
                rsp.isMuteAll = isMuteAll;
                callback(rsp, nil);
            }
        }
    }];
}

- (void)sendLike:(AUIMessageSendLikeRequest *)req callback:(AUIMessageDefaultCallback)callback {
    // 当AUIMessageService的实现不支持时，会通过该接口回调，这时需要使用服务端接口来实现
    [AUIRoomAppServer sendLike:req.groupId count:req.count completed:callback];
}

- (void)sendSysMessageToGroup:(AUIMessageSendMessageToGroupRequest *)req callback:(AUIMessageSendMessageToGroupCallback)callback {
    // 当AUIMessageService的实现不支持时，会通过该接口回调，这时需要使用服务端接口来实现
    // TODO: 如果使用融云ChatRoom模式，需要实现
}

#pragma mark - AUIMessageServiceConnectionDelegate

- (void)onTokenExpire:(AUIMessageDefaultCallback)updateTokenCompleted {
    NSLog(@"Message Token过期了");
    
    __weak typeof(self) weakSelf = self;
    [self fetchToken:^(NSDictionary *tokenData, NSError *error) {
        if (updateTokenCompleted) {
            if (tokenData) {
                [[weakSelf messageService] getConfig].tokenData = tokenData;
            }
            updateTokenCompleted(error);
        }
    }];
}

#pragma mark - AUIMessageListenerProtocol

- (void)onJoinGroup:(AUIMessageModel *)model {
    NSEnumerator<id<AUIRoomMessageServiceObserver>>* enumerator = [self.observerList objectEnumerator];
    id<AUIRoomMessageServiceObserver> observer = nil;
    while ((observer = [enumerator nextObject])) {
        if ([observer.groupId isEqualToString:model.groupId]) {
            if ([observer respondsToSelector:@selector(onJoinGroup:)]) {
                [observer onJoinGroup:model];
            }
        }
    }
}

- (void)onLeaveGroup:(AUIMessageModel *)model {
    NSEnumerator<id<AUIRoomMessageServiceObserver>>* enumerator = [self.observerList objectEnumerator];
    id<AUIRoomMessageServiceObserver> observer = nil;
    while ((observer = [enumerator nextObject])) {
        if ([observer.groupId isEqualToString:model.groupId]) {
            if ([observer respondsToSelector:@selector(onLeaveGroup:)]) {
                [observer onLeaveGroup:model];
            }
        }
    }
}

- (void)onMuteGroup:(AUIMessageModel *)model {
    NSEnumerator<id<AUIRoomMessageServiceObserver>>* enumerator = [self.observerList objectEnumerator];
    id<AUIRoomMessageServiceObserver> observer = nil;
    while ((observer = [enumerator nextObject])) {
        if ([observer.groupId isEqualToString:model.groupId]) {
            if ([observer respondsToSelector:@selector(onMuteGroup:)]) {
                [observer onMuteGroup:model];
            }
        }
    }
}

- (void)onUnmuteGroup:(AUIMessageModel *)model {
    NSEnumerator<id<AUIRoomMessageServiceObserver>>* enumerator = [self.observerList objectEnumerator];
    id<AUIRoomMessageServiceObserver> observer = nil;
    while ((observer = [enumerator nextObject])) {
        if ([observer.groupId isEqualToString:model.groupId]) {
            if ([observer respondsToSelector:@selector(onCancelMuteGroup:)]) {
                [observer onCancelMuteGroup:model];
            }
        }
    }
}

- (void)onMessageReceived:(AUIMessageModel *)model {
    
    if (model.msgType == AUIRoomMessageTypeComment) {
        NSEnumerator<id<AUIRoomMessageServiceObserver>>* enumerator = [self.observerList objectEnumerator];
        id<AUIRoomMessageServiceObserver> observer = nil;
        while ((observer = [enumerator nextObject])) {
            if ([observer.groupId isEqualToString:model.groupId]) {
                if ([observer respondsToSelector:@selector(onCommentReceived:)]) {
                    [observer onCommentReceived:model];
                }
            }
        }
    }
    else if (model.msgType == 1001) {
        // 这里点赞消息类型定义为1001，原因是阿里互动消息SDK定义的"点赞"类型为1001
        // 如果使用其他IM方案，通过接口发送点赞数据，则服务端接收到点赞数进行处理后（客户自行实现），在群内广播点赞总数，消息类型为1001
        NSEnumerator<id<AUIRoomMessageServiceObserver>>* enumerator = [self.observerList objectEnumerator];
        id<AUIRoomMessageServiceObserver> observer = nil;
        while ((observer = [enumerator nextObject])) {
            if ([observer.groupId isEqualToString:model.groupId]) {
                if ([observer respondsToSelector:@selector(onLikeReceived:)]) {
                    [observer onLikeReceived:model];
                }
            }
        }
    }
    else {
        NSEnumerator<id<AUIRoomMessageServiceObserver>>* enumerator = [self.observerList objectEnumerator];
        id<AUIRoomMessageServiceObserver> observer = nil;
        while ((observer = [enumerator nextObject])) {
            if ([observer.groupId isEqualToString:model.groupId]) {
                if ([observer respondsToSelector:@selector(onCommandReceived:)]) {
                    [observer onCommandReceived:model];
                }
            }
        }
    }
}

- (void)onExitedGroup:(NSString *)groupId {
    NSEnumerator<id<AUIRoomMessageServiceObserver>>* enumerator = [self.observerList objectEnumerator];
    id<AUIRoomMessageServiceObserver> observer = nil;
    while ((observer = [enumerator nextObject])) {
        if ([observer.groupId isEqualToString:groupId]) {
            if ([observer respondsToSelector:@selector(onExitedGroup:)]) {
                [observer onExitedGroup:groupId];
            }
        }
    }
}

@end


#define IM_SERVER_ALIYUN_OLD @"aliyun_old"
#define IM_SERVER_ALIYUN_NEW @"aliyun_new"
#define IM_SERVER_RONGYUN @"rongyun"

#define IM_RSP_DATA_ALIYUN_OLD @"aliyun_old_im"
#define IM_RSP_DATA_ALIYUN_NEW @"aliyun_new_im"
#define IM_RSP_DATA_RONGYUN @"rongyun_im"

@implementation AUIRoomMessage

+ (AUIRoomMessageService *)messageService {
    static AUIRoomMessageService *_instance = nil;
    if (!_instance) {
        _instance = [AUIRoomMessageService new];
    }
    return _instance;
}

+ (id<AUIRoomMessageServiceProtocol>)currentService {
    return [self messageService];
}

static BOOL _useAlivcIMWhenCompatMode = NO;
+ (void)useAlivcIMWhenCompatMode:(BOOL)isAlivcIM {
    _useAlivcIMWhenCompatMode = isAlivcIM;
}

+ (NSArray<NSString *> *)currentIMServers {
    NSMutableArray *servers = [NSMutableArray array];
    AUIMessageServiceImplType implType = [self messageService].messageService.implType;
    if (implType == AUIMessageServiceImplTypeAlivc) {
        [servers addObject:IM_SERVER_ALIYUN_OLD];
    }
    else if (implType == AUIMessageServiceImplTypeAlivcIM) {
        [servers addObject:IM_SERVER_ALIYUN_NEW];
    }
    else if (implType == AUIMessageServiceImplTypeAlivcCompat) {
        if (_useAlivcIMWhenCompatMode) {
            [servers addObject:IM_SERVER_ALIYUN_NEW];
        }
        else {
            [servers addObject:IM_SERVER_ALIYUN_OLD];
        }
    }
    else if (implType == AUIMessageServiceImplTypeRCChatRoom) {
        [servers addObject:IM_SERVER_RONGYUN];
    }
    return servers;
}

+ (NSDictionary *)fetchTokenData:(NSDictionary *)rspData {
    AUIMessageServiceImplType implType = [self messageService].messageService.implType;
    NSString *key = nil;
    if (implType == AUIMessageServiceImplTypeAlivc) {
        key = IM_RSP_DATA_ALIYUN_OLD;
    }
    else if (implType == AUIMessageServiceImplTypeAlivcIM) {
        key = IM_RSP_DATA_ALIYUN_NEW;
    }
    else if (implType == AUIMessageServiceImplTypeAlivcCompat) {
        key = _useAlivcIMWhenCompatMode ? IM_RSP_DATA_ALIYUN_NEW : IM_RSP_DATA_ALIYUN_OLD;
    }
    else if (implType == AUIMessageServiceImplTypeRCChatRoom) {
        key = IM_RSP_DATA_RONGYUN;
    }
    if (key == nil) {
        return nil;
    }
    
    NSDictionary *tokenData = [rspData objectForKey:key];
    if (tokenData && [tokenData isKindOfClass:NSDictionary.class]) {
        NSMutableDictionary *final = [NSMutableDictionary dictionaryWithDictionary:tokenData];
        [final setObject: AlivcBase.IntegrationWay ?: @"aui-live" forKey:@"source"];
        if (implType == AUIMessageServiceImplTypeAlivcCompat) {
            [final setObject:_useAlivcIMWhenCompatMode ? IM_SERVER_ALIYUN_NEW : IM_SERVER_ALIYUN_OLD forKey:@"mode"];
        }
        return final;
    }
    return nil;
}


@end
