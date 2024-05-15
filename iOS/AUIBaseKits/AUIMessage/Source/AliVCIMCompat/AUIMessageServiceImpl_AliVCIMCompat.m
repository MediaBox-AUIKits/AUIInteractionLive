//
//  AUIMessageServiceImpl_AliVCIMCompat.m
//

#import "AUIMessageServiceImpl_AliVCIMCompat.h"
#import "AUIMessageServiceImpl_AliVCIM.h"
#import "AUIMessageServiceImpl_Alivc.h"

@interface AUIMessageServiceImpl_AliVCIMCompat () <AUIMessageListenerProtocol>

@property (nonatomic, strong) id<AUIMessageServiceProtocol> currIM;

@property (nonatomic, weak) id<AUIMessageServiceConnectionDelegate> connectionDelegate;
@property (nonatomic, weak) id<AUIMessageServiceUnImplDelegate> unImplDelegate;
@property (nonatomic, strong) AUIMessageListenerObserver *listenerObserver;

@end


@implementation AUIMessageServiceImpl_AliVCIMCompat

- (AUIMessageServiceImplType)implType {
    return AUIMessageServiceImplTypeAlivcCompat;
}

- (void)setConfig:(AUIMessageConfig *)config {
    
    // release
    if (self.currIM) {
        [self.currIM.getListenerObserver removeListener:self];
        [self.currIM setConnectionDelegate:nil];
        [self.currIM setUnImplDelegate:nil];
        [self.currIM logout:nil];
    }
    
    // create
    if ([[config.tokenData objectForKey:@"mode"] isEqualToString:@"aliyun_new"]) {
        self.currIM = [AUIMessageServiceImpl_AliVCIM new];
    }
    else {
        self.currIM = [AUIMessageServiceImpl_Alivc new];
    }
    [self.currIM.getListenerObserver addListener:self];
    [self.currIM setConnectionDelegate:self.connectionDelegate];
    [self.currIM setUnImplDelegate:self.unImplDelegate];
    
    // setting
    [self.currIM setConfig:config];
}

- (AUIMessageConfig *)getConfig {
    return [self.currIM getConfig];
}

- (void)setConnectionDelegate:(id<AUIMessageServiceConnectionDelegate>)connectionDelegate {
    _connectionDelegate = connectionDelegate;
    [self.currIM setConnectionDelegate:_connectionDelegate];
}

- (void)setUnImplDelegate:(id<AUIMessageServiceUnImplDelegate>)unImplDelegate {
    _unImplDelegate = unImplDelegate;
    [self.currIM setUnImplDelegate:_unImplDelegate];
}

- (id<AUIUserProtocol>)currentUserInfo {
    return [self.currIM currentUserInfo];
}

- (BOOL)isLogin {
    return [self.currIM isLogin];
}

- (void)login:(id<AUIUserProtocol>)userInfo callback:(AUIMessageDefaultCallback)callback {
    [self.currIM login:userInfo callback:callback];
}

- (void)logout:(AUIMessageDefaultCallback)callback {
    [self.currIM logout:callback];
}

- (AUIMessageListenerObserver *)getListenerObserver {
    if (!_listenerObserver) {
        _listenerObserver = [AUIMessageListenerObserver new];
    }
    return _listenerObserver;
}

- (void)getGroupInfo:(AUIMessageGetGroupInfoRequest *)req callback:(AUIMessageGetGroupInfoCallback)callback {
    [self.currIM getGroupInfo:req callback:callback];
}

- (void)createGroup:(AUIMessageCreateGroupRequest *)req callback:(AUIMessageCreateGroupCallback)callback {
    [self.currIM createGroup:req callback:callback];
}

- (void)joinGroup:(AUIMessageJoinGroupRequest *)req callback:(AUIMessageDefaultCallback)callback {
    [self.currIM joinGroup:req callback:callback];
}

- (void)joinGroup:(AUIMessageJoinGroupRequest *)req groupInfoCallback:(AUIMessageGetGroupInfoCallback)groupInfoCallback {
    [self.currIM joinGroup:req groupInfoCallback:groupInfoCallback];
}

- (void)leaveGroup:(AUIMessageLeaveGroupRequest *)req callback:(AUIMessageDefaultCallback)callback {
    [self.currIM leaveGroup:req callback:callback];
}

- (void)muteAll:(AUIMessageMuteAllRequest *)req callback:(AUIMessageDefaultCallback)callback {
    [self.currIM muteAll:req callback:callback];
}

- (void)cancelMuteAll:(AUIMessageCancelMuteAllRequest *)req callback:(AUIMessageDefaultCallback)callback {
    [self.currIM cancelMuteAll:req callback:callback];
}

- (void)queryMuteAll:(AUIMessageQueryMuteAllRequest *)req callback:(AUIMessageQueryMuteAllCallback)callback {
    [self.currIM queryMuteAll:req callback:callback];
}

- (void)sendLike:(AUIMessageSendLikeRequest *)req callback:(AUIMessageDefaultCallback)callback {
    [self.currIM sendLike:req callback:callback];
}


- (void)sendMessageToGroup:(AUIMessageSendMessageToGroupRequest *)req callback:(AUIMessageSendMessageToGroupCallback)callback {
    [self.currIM sendMessageToGroup:req callback:callback];
}

- (void)sendMessageToGroupUser:(AUIMessageSendMessageToGroupUserRequest *)req callback:(AUIMessageSendMessageToGroupUserCallback)callback {
    [self.currIM sendMessageToGroupUser:req callback:callback];
}

- (id)getNativeEngine {
    return [self.currIM getNativeEngine];
}

#pragma mark - AUIMessageListenerProtocol

/**
 * 有人加入群组事件
 */
- (void)onJoinGroup:(AUIMessageModel *)model {
    [self.getListenerObserver onJoinGroup:model];
}

/**
 * 有人离开群组事件
 */
- (void)onLeaveGroup:(AUIMessageModel *)model {
    [self.getListenerObserver onLeaveGroup:model];
}

/**
 * 群组禁言事件
 */
- (void)onMuteGroup:(AUIMessageModel *)model {
    [self.getListenerObserver onMuteGroup:model];
}

/**
 * 群组取消禁言事件
 */
- (void)onUnmuteGroup:(AUIMessageModel *)model {
    [self.getListenerObserver onUnmuteGroup:model];
}

/**
 * 收到消息
 */
- (void)onMessageReceived:(AUIMessageModel *)model {
    [self.getListenerObserver onMessageReceived:model];
}

/**
 * 被动离开群组
 */
- (void)onExitedGroup:(NSString *)groupId {
    [self.getListenerObserver onExitedGroup:groupId];
}

@end
