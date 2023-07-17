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

#if __has_include(<AlivcInteraction/AlivcInteraction.h>)
#import <AlivcInteraction/AlivcInteraction.h>
#define ENABLE_ALIVCINTERACTION
#endif

#define AUIRoomMessageTypeComment 10001
#define AUIRoomMessageTypeLike    10002


#ifdef ENABLE_ALIVCINTERACTION
static NSError *s_error(AVCIInteractionError *error) {
    return [NSError errorWithDomain:@"" code:error.code userInfo:@{NSLocalizedDescriptionKey:error.message?:@""}];
}
#endif

@interface AUIRoomMessageService : NSObject <AUIRoomMessageServiceProtocol, AUIMessageServiceConnectionDelegate, AUIMessageListenerProtocol>

@property (nonatomic, strong) id<AUIMessageServiceProtocol> messageService;
@property (nonatomic, strong) NSHashTable<id<AUIRoomMessageServiceObserver>> *observerList;

@end


@implementation AUIRoomMessageService

- (instancetype)init {
    self = [super init];
    if (self) {
        self.messageService = [AUIMessageServiceFactory getMessageService];
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

+ (void)fetchToken:(void(^)(NSString *finalToken, NSError *error))completed {
    [AUIRoomAppServer fetchToken:^(NSString * _Nullable accessToken, NSString * _Nullable refreshToken, NSError * _Nullable error) {
        if (completed) {
#ifdef ENABLE_ALIVCINTERACTION
            completed([NSString stringWithFormat:@"%@_%@", accessToken, refreshToken], error);
#else
            completed(accessToken, error);
#endif
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
    
    [AUIRoomMessageService fetchToken:^(NSString *finalToken, NSError *error) {
        if (error) {
            if (completed) {
                completed(NO);
            }
            return;
        }
        
        AUIMessageConfig *config = [AUIMessageConfig new];
        config.token = finalToken;
        [self.messageService setConfig:config];
        
        AUIMessageUserInfo *user = [AUIMessageUserInfo new];
        user.userId = AUIRoomAccount.me.userId;
        user.userNick = AUIRoomAccount.me.nickName;
        user.userAvatar = AUIRoomAccount.me.avatar;
        [self.messageService login:user callback:^(NSError * _Nullable error) {
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
    [self.messageService joinGroup:req callback:completed];
}

- (void)leaveGroup:(NSString *)groupID completed:(AUIMessageDefaultCallback)completed {
    AUIMessageLeaveGroupRequest *req = [AUIMessageLeaveGroupRequest new];
    req.groupId = groupID;
    [self.messageService leaveGroup:req callback:completed];
}

- (void)muteAll:(NSString *)groupID completed:(AUIMessageDefaultCallback)completed {
#ifdef ENABLE_ALIVCINTERACTION
    AVCIInteractionEngine *interactionEngine = [self.messageService getNativeEngine];
    
    [interactionEngine.interactionService muteAll:groupID broadCastType:2 onSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(nil);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(s_error(error));
            }
        });
    }];
#else
    [AUIRoomAppServer muteAll:groupID completed:completed];
#endif
}

- (void)cancelMuteAll:(NSString *)groupID completed:(AUIMessageDefaultCallback)completed {
#ifdef ENABLE_ALIVCINTERACTION
    AVCIInteractionEngine *interactionEngine = [self.messageService getNativeEngine];
    [interactionEngine.interactionService cancelMuteAll:groupID broadCastType:2 onSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(nil);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(s_error(error));
            }
        });
    }];
#else
    [AUIRoomAppServer cancelMuteAll:groupID completed:completed];
#endif
}

- (void)queryMuteAll:(NSString *)groupID completed:(void (^)(BOOL, NSError * _Nullable))completed {
#ifdef ENABLE_ALIVCINTERACTION
    AVCIInteractionEngine *interactionEngine = [self.messageService getNativeEngine];
    [interactionEngine.interactionService getGroup:groupID onSuccess:^(AVCIInteractionGroupDetail * _Nonnull groupDetail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(groupDetail.isMuteAll, nil);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(NO ,s_error(error));
            }
        });
    }];
#else
    [AUIRoomAppServer queryMuteAll:groupID completed:completed];
#endif
}

- (void)sendLike:(NSString *)groupID count:(NSUInteger)count completed:(AUIMessageDefaultCallback)completed {
#ifdef ENABLE_ALIVCINTERACTION
    AVCIInteractionEngine *interactionEngine = [self.messageService getNativeEngine];
    [interactionEngine.interactionService sendLikeWithGroupID:groupID count:(int32_t)count broadCastType:2 onSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(nil);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(s_error(error));
            }
        });
    }];
#else
    [AUIRoomAppServer sendLike:groupID count:count completed:completed];
#endif
}

- (void)sendComment:(NSString *)groupID comment:(NSDictionary *)comment completed:(AUIMessageDefaultCallback)completed {
    AUIMessageSendMessageToGroupRequest *req = [AUIMessageSendMessageToGroupRequest new];
    req.groupId = groupID;
    req.data = [[AUIMessageDefaultData alloc] initWithData:comment];
    req.msgType = AUIRoomMessageTypeComment;
    req.skipAudit = NO;
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

#pragma mark - AUIMessageServiceConnectionDelegate

- (void)onTokenExpire:(void (^)(NSString * _Nonnull, NSError * _Nonnull))onRequestedNewToken {
    [AUIRoomMessageService fetchToken:onRequestedNewToken];
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
    
#ifdef ENABLE_ALIVCINTERACTION
    NSDictionary *stat = [model.data objectForKey:@"statistics"];
    if (stat) {
        AUIMessageModel *statMessageModel = [AUIMessageModel new];
        statMessageModel.groupId = model.groupId;
        statMessageModel.sender = model.sender;
        statMessageModel.data = stat;
        statMessageModel.messageId = model.messageId;
        
        enumerator = [self.observerList objectEnumerator];
        while ((observer = [enumerator nextObject])) {
            if ([observer.groupId isEqualToString:statMessageModel.groupId]) {
                if ([observer respondsToSelector:@selector(onPVReceived:)]) {
                    [observer onPVReceived:statMessageModel];
                }
                if ([observer respondsToSelector:@selector(onLikeReceived:)]) {
                    [observer onLikeReceived:statMessageModel];
                }
            }
        }
    }
#endif
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
#ifdef ENABLE_ALIVCINTERACTION
    else if (model.msgType == 1001) {  // 阿里互动消息SDK定义的"点赞"类型为1001
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
#else
    else if (model.msgType == AUIRoomMessageTypeLike) {
        // 通过接口发送点赞数据，服务端接收到点赞数进行处理后（客户自行实现），在群内广播点赞总数
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
#endif
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

@end


@implementation AUIRoomMessage

+ (id<AUIRoomMessageServiceProtocol>)currentService {
    static AUIRoomMessageService *_instance = nil;
    if (!_instance) {
        _instance = [AUIRoomMessageService new];
    }
    return _instance;
}

@end
