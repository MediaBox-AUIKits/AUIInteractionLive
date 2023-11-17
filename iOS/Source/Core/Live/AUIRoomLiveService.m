//
//  AUIRoomLiveService.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/2/25.
//

#import "AUIRoomLiveService.h"
#import "AUIRoomAppServer.h"
#import "AUIRoomAccount.h"
#import "AUIRoomMessageService.h"

typedef NS_ENUM(NSUInteger, AUIRoomMessageType) {
    AUIRoomMessageTypeStartLive = 10003,
    AUIRoomMessageTypeStopLive,
    AUIRoomMessageTypeLiveInfo,
    AUIRoomMessageTypeNotice,
    
    AUIRoomMessageTypeApplyLinkMic = 20001,
    AUIRoomMessageTypeResponseLinkMic,
    AUIRoomMessageTypeJoinLinkMic,
    AUIRoomMessageTypeLeaveLinkMic,
    AUIRoomMessageTypeKickoutLinkMic,
    AUIRoomMessageTypeCancelApplyLinkMic,
    AUIRoomMessageTypeMicOpened,
    AUIRoomMessageTypeCameraOpened,
    AUIRoomMessageTypeNeedOpenMic,
    AUIRoomMessageTypeNeedOpenCamera,
    
    AUIRoomMessageTypeGift = 30001,
};

@implementation AUIRoomGiftModel

- (instancetype)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _giftId = [data objectForKey:@"id"];
        _name = [data objectForKey:@"name"];
        _desc = [data objectForKey:@"description"];
        _imageUrl = [data objectForKey:@"imageUrl"];
    }
    return self;
}

- (NSDictionary *)toData {
    return @{
        @"id":_giftId ?: @"",
        @"name":_name ?: @"",
        @"description":_desc ?: @"",
        @"imageUrl":_imageUrl ?: @"",
    };
}

@end


@interface AUIRoomLiveService () <AUIRoomMessageServiceObserver>

@property (strong, nonatomic) AUIRoomLiveInfoModel *liveInfoModel;
@property (strong, nonatomic) id<AUIRoomMessageServiceProtocol> messageService;

@property (assign, nonatomic) NSInteger pv;
@property (assign, nonatomic) BOOL isJoined;

@property (assign, nonatomic) BOOL isMuteAll;

@property (nonatomic, strong) NSTimer *sendLikeTimer;
@property (assign, nonatomic) NSInteger allLikeCount;
@property (assign, nonatomic) NSInteger likeCountWillSend;
@property (assign, nonatomic) NSInteger likeCountToSend;

@property (assign, nonatomic) BOOL needQueryStatistics;
@property (assign, nonatomic) BOOL statisticsIsUpdating;


@property (copy, nonatomic) NSString *notice;

@end

@implementation AUIRoomLiveService


- (BOOL)isAnchor {
    return [self.liveInfoModel.anchor_id isEqualToString:AUIRoomAccount.me.userId];
}

#pragma mark - Room

- (void)enterRoom:(void(^)(BOOL))completed {
    __weak typeof(self) weakSelf = self;
    [self.messageService joinGroup:self.liveInfoModel.chat_id completed:^(NSError * _Nullable error) {
        if (!error) {
            weakSelf.isJoined = YES;
            [weakSelf queryStatistics];
        }
        if (completed) {
            completed(error == nil);
        }
    }];
}

- (void)leaveRoom:(void(^)(BOOL))completed {
    __weak typeof(self) weakSelf = self;
    [self.messageService leaveGroup:self.liveInfoModel.chat_id completed:^(NSError * _Nullable error) {
        if (!error) {
            weakSelf.isJoined = NO;
        }
        if (completed) {
            completed(error == nil);
        }
    }];
}

#pragma mark - Live

- (void)startLive:(void(^)(BOOL))completed {
    if (!self.isJoined || !self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    [AUIRoomAppServer startLive:self.liveInfoModel.live_id ?: @"" completed:^(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error) {
        if (error) {
            if (completed) {
                completed(NO);
            }
            return;
        }
        [self.liveInfoModel updateStatus:model.status];
        [self sendData:nil type:AUIRoomMessageTypeStartLive receiverId:nil completed:completed];
    }];
}

- (void)finishLive:(void(^)(BOOL))completed {
    if (!self.isJoined || !self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    if (self.liveInfoModel.status == AUIRoomLiveStatusFinished) {
        if (completed) {
            completed(YES);
        }
        return;
    }
    
    [AUIRoomAppServer stopLive:self.liveInfoModel.live_id ?: @"" completed:^(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error) {
        if (error) {
            if (completed) {
                completed(NO);
            }
            return;
        }
        [self.liveInfoModel updateStatus:model.status];
        [self sendData:nil type:AUIRoomMessageTypeStopLive receiverId:nil completed:completed];
    }];
}

#pragma mark - Mute

- (void)queryMuteAll:(void (^)(BOOL))completed {
    if (!self.isJoined) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.messageService queryMuteAll:self.liveInfoModel.chat_id completed:^(BOOL isMuteAll, NSError * _Nullable error) {
        if (error) {
            if (completed) {
                completed(NO);
            }
            return;
        }
        weakSelf.isMuteAll = isMuteAll;
        if (completed) {
            completed(YES);
        }
    }];
}

- (void)muteAll:(void (^)(BOOL))completed {
    if (!self.isJoined || !self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.messageService muteAll:self.liveInfoModel.chat_id completed:^(NSError * _Nullable error) {
        if (error) {
            if (completed) {
                completed(NO);
            }
            return;
        }
        weakSelf.isMuteAll = YES;
        if (completed) {
            completed(YES);
        }
    }];
}

- (void)cancelMuteAll:(void (^)(BOOL))completed {
    if (!self.isJoined || !self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.messageService cancelMuteAll:self.liveInfoModel.chat_id completed:^(NSError * _Nullable error) {
        if (error) {
            if (completed) {
                completed(NO);
            }
            return;
        }
        weakSelf.isMuteAll = NO;
        if (completed) {
            completed(YES);
        }
    }];
}

#pragma mark - Notice

- (void)updateNotice:(NSString *)notice completed:(void (^)(BOOL))completed {
    if (!self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    [AUIRoomAppServer updateLive:self.liveInfoModel.live_id title:nil notice:notice extend:nil completed:^(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error) {
        if (!error) {
            self.notice = notice;
            NSDictionary *msg = @{@"notice":notice?:@""};
            [self sendData:[[AUIMessageDefaultData alloc] initWithData:msg] type:AUIRoomMessageTypeNotice receiverId:nil completed:completed];
        }
        if (completed) {
            completed(!error);
        }
    }];
}


#pragma mark - Like

- (void)sendLike {
    self.likeCountWillSend++;
    NSLog(@"like_button:will send:%zd", self.likeCountWillSend);
    if (!self.sendLikeTimer) {
        [self startSendLikeTimer];
    }
}

- (void)sendLike:(NSInteger)count completed:(void(^)(BOOL))completed {
    if (!self.isJoined) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    [self.messageService sendLike:self.liveInfoModel.chat_id count:count completed:^(NSError * _Nullable error) {
        if (completed) {
            completed(error == nil);
        }
    }];
}

- (void)startSendLikeTimer {
    if (self.isJoined) {
        self.sendLikeTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timeToSendLike) userInfo:nil repeats:NO];
    }
}

- (void)stopSendLikeTimer {
    [self.sendLikeTimer invalidate];
    self.sendLikeTimer = nil;
}

- (void)timeToSendLike {
    [self stopSendLikeTimer];
    
    if (self.likeCountWillSend > 0) {
        self.likeCountToSend = self.likeCountWillSend;
        self.likeCountWillSend = 0;
        NSLog(@"like_button:sending:%zd", self.likeCountToSend);
        __weak typeof(self) weakSelf = self;
        [self sendLike:self.likeCountToSend completed:^(BOOL success) {
            if (!success) {
                weakSelf.likeCountWillSend += weakSelf.likeCountToSend;
                NSLog(@"like_button:send failed:%zd", weakSelf.likeCountToSend);
            }
            else {
                NSLog(@"like_button:send completed:%zd", weakSelf.likeCountToSend);
            }
            if (weakSelf.likeCountWillSend > 0) {
                [weakSelf startSendLikeTimer];
                NSLog(@"like_button:next 2 second to send:%zd", weakSelf.likeCountWillSend);
            }
        }];
    }
}

#pragma mark - statistics

- (void)queryStatistics {
    self.needQueryStatistics = YES;
    if (self.statisticsIsUpdating) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.messageService queryStatistics:self.liveInfoModel.live_id completed:^(NSInteger pv, NSInteger onlineCount, NSError * _Nullable error) {
        if (pv > weakSelf.pv) {
            weakSelf.pv = pv;
            if (weakSelf.onReceivedPV) {
                weakSelf.onReceivedPV(weakSelf.pv);
            }
        }
        weakSelf.statisticsIsUpdating = NO;
        if (weakSelf.needQueryStatistics) {
            [weakSelf queryStatistics];
        }
    }];
    self.statisticsIsUpdating = YES;
    self.needQueryStatistics = NO;
}

#pragma mark - Gift

- (void)sendGift:(AUIRoomGiftModel *)gift completed:(void(^)(BOOL))completed {
    if (!self.isJoined || self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    [self sendData:gift type:AUIRoomMessageTypeGift receiverId:self.liveInfoModel.anchor_id completed:completed];
}

#pragma mark - Pusher state

- (void)sendCameraOpened:(BOOL)opened completed:(void (^)(BOOL))completed {
    if (!self.isJoined) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{@"cameraOpened":@(opened)};
    [self sendData:[[AUIMessageDefaultData alloc] initWithData:msg] type:AUIRoomMessageTypeCameraOpened receiverId:nil completed:completed];
}

- (void)sendMicOpened:(BOOL)opened completed:(void (^)(BOOL))completed {
    if (!self.isJoined) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{@"micOpened":@(opened)};
    [self sendData:[[AUIMessageDefaultData alloc] initWithData:msg] type:AUIRoomMessageTypeMicOpened receiverId:nil completed:completed];
}

- (void)sendOpenCamera:(NSString *)userId needOpen:(BOOL)needOpen completed:(void (^)(BOOL))completed {
    if (!self.isJoined || !self.isAnchor || userId.length == 0 || [userId isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    NSDictionary *msg = @{@"needOpenCamera":@(needOpen)};
    [self sendData:[[AUIMessageDefaultData alloc] initWithData:msg] type:AUIRoomMessageTypeNeedOpenCamera receiverId:userId completed:completed];
}

- (void)sendOpenMic:(NSString *)userId needOpen:(BOOL)needOpen completed:(void (^)(BOOL))completed {
    if (!self.isJoined || !self.isAnchor || userId.length == 0 || [userId isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    NSDictionary *msg = @{@"needOpenMic":@(needOpen)};
    [self sendData:[[AUIMessageDefaultData alloc] initWithData:msg] type:AUIRoomMessageTypeNeedOpenMic receiverId:userId completed:completed];
}

#pragma mark - Comment

- (void)sendComment:(NSString *)comment completed:(void(^)(BOOL))completed {
    if (!self.isJoined) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    if (comment.length == 0) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{
        @"content":comment,
    };
    [self.messageService sendComment:self.liveInfoModel.chat_id comment:msg completed:^(NSError * _Nullable error) {
        if (completed) {
            completed(error == nil);
        }
    }];
}

#pragma mark - Message

- (void)sendData:(id<AUIMessageDataProtocol>)data type:(NSInteger)type receiverId:(NSString *)receiverId completed:(void (^)(BOOL))completed {
    [self.messageService sendCommand:type data:data groupID:self.liveInfoModel.chat_id receiverId:receiverId completed:^(NSError * _Nullable error) {
        if (completed) {
            completed(error == nil);
        }
    }];
}

#pragma mark - link mic

- (void)sendApplyLinkMic:(NSString *)uid completed:(void (^)(BOOL))completed {
    if (!self.isJoined || uid.length == 0 || [uid isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    // 观众只能申请跟主播连麦
    if (self.isAnchor || ![uid isEqualToString:self.liveInfoModel.anchor_id]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    [self sendData:nil type:AUIRoomMessageTypeApplyLinkMic receiverId:uid completed:completed];
}

- (void)sendCancelApplyLinkMic:(NSString *)uid completed:(void (^)(BOOL))completed {
    if (!self.isJoined || uid.length == 0 || [uid isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    // 观众只能跟主播取消申请连麦
    if (self.isAnchor || ![uid isEqualToString:self.liveInfoModel.anchor_id]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    [self sendData:nil type:AUIRoomMessageTypeCancelApplyLinkMic receiverId:uid completed:completed];
}

- (void)sendResponseLinkMic:(NSString *)uid agree:(BOOL)agree pullUrl:(NSString *)pullUrl completed:(void (^)(BOOL))completed {
    if (!self.isJoined || !self.isAnchor || uid.length == 0 || [uid isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    [msg setObject:@(agree) forKey:@"agree"];
    if (agree) {
        [msg setObject:pullUrl?:@"" forKey:@"rtcPullUrl"];
    }
    [self sendData:[[AUIMessageDefaultData alloc] initWithData:msg] type:AUIRoomMessageTypeResponseLinkMic receiverId:uid completed:completed];
}

- (void)sendJoinLinkMic:(NSString *)pullUrl completed:(void (^)(BOOL))completed {
    if (!self.isJoined || pullUrl.length == 0 || self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{
        @"rtcPullUrl":pullUrl?:@"",
    };
    [self sendData:[[AUIMessageDefaultData alloc] initWithData:msg] type:AUIRoomMessageTypeJoinLinkMic receiverId:nil completed:completed];
}

- (void)sendLeaveLinkMic:(BOOL)byKickout completed:(void (^)(BOOL))completed {
    if (!self.isJoined || self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{
        @"reason":byKickout ? @"byKickout" : @"bySelf"
    };
    [self sendData:[[AUIMessageDefaultData alloc] initWithData:msg]  type:AUIRoomMessageTypeLeaveLinkMic receiverId:nil completed:completed];
}

- (void)sendKickoutLinkMic:(NSString *)uid completed:(void (^)(BOOL))completed {
    if (!self.isAnchor || !self.isJoined || uid.length == 0 || [uid isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    [self sendData:nil type:AUIRoomMessageTypeKickoutLinkMic receiverId:uid completed:completed];
}

static NSUInteger g_maxLinkMicCount = 6;
+ (NSUInteger)maxLinkMicCount {
    return g_maxLinkMicCount;
}

+ (void)setMaxLinkMicCount:(NSUInteger)maxLinkMicCount {
    g_maxLinkMicCount = maxLinkMicCount;
}

- (void)queryLinkMicJoinList:(void (^)(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *))completed {
    
    if (self.liveInfoModel.mode == AUIRoomLiveModeBase) {
        if (completed) {
            completed(nil);
        }
        return;
    }
    
    [AUIRoomAppServer queryLinkMicJoinList:self.liveInfoModel.live_id completed:^(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> * _Nullable models, NSError * _Nullable error) {
        if (completed) {
            completed(models);
        }
    }];
}

- (void)updateLinkMicJoinList:(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)joinList completed:(nullable void (^)(BOOL))completed {
    if (!self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    [AUIRoomAppServer updateLinkMicJoinList:self.liveInfoModel.live_id joinList:joinList completed:^(NSError * _Nullable error) {
        if (completed) {
            completed(error == nil);
        }
    }];
}

#pragma mark - Life Cycle

- (void)dealloc {
    [_messageService removeObserver:self];
}

- (instancetype)initWithModel:(AUIRoomLiveInfoModel *)model
                 withJoinList:(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)joinList {
    self = [super init];
    if (self) {
        _liveInfoModel = model;
        _joinList = joinList;
        
        _messageService = AUIRoomMessage.currentService;
        [_messageService addObserver:self];
        
        _allLikeCount = _liveInfoModel.metrics.like_count;
        _pv = _liveInfoModel.metrics.pv;
        _notice = _liveInfoModel.notice;
    }
    return self;
}

- (AUIRoomUser *)userFromMessageUserInfo:(AUIMessageUserInfo *)msgUserInfo {
    AUIRoomUser *user = [AUIRoomUser new];
    user.userId = msgUserInfo.userId;
    user.nickName = msgUserInfo.userNick;
    user.avatar = msgUserInfo.userAvatar;
    return user;
}

#pragma mark - AUIRoomMessageServiceObserver

- (NSString *)groupId {
    return self.liveInfoModel.chat_id;
}

- (void)onCommandReceived:(AUIMessageModel *)message {
    
    AUIRoomUser *sender = [self userFromMessageUserInfo:message.sender];
    NSDictionary *data = message.data;

    if (message.msgType == AUIRoomMessageTypeStartLive) {
        if (self.onReceivedStartLive) {
            self.onReceivedStartLive(sender);
        }
        return;
    }
    if (message.msgType == AUIRoomMessageTypeStopLive) {
        if (self.onReceivedStopLive) {
            self.onReceivedStopLive(sender);
        }
        return;
    }
    if (message.msgType == AUIRoomMessageTypeNotice) {
        NSString *notice = [data objectForKey:@"notice"];
        self.notice = notice;
        if (self.onReceivedNoticeUpdate) {
            self.onReceivedNoticeUpdate(notice);
        }
        return;
    }
    
    if (message.msgType == AUIRoomMessageTypeJoinLinkMic) {
        AUIRoomLiveLinkMicJoinInfoModel *joinInfo = [[AUIRoomLiveLinkMicJoinInfoModel alloc] init:sender.userId userNick:sender.nickName userAvatar:sender.avatar rtcPullUrl:[data objectForKey:@"rtcPullUrl"]];
        if (self.onReceivedJoinLinkMic) {
            self.onReceivedJoinLinkMic(sender, joinInfo);
        }
        return;
    }
    if (message.msgType == AUIRoomMessageTypeLeaveLinkMic) {
        if (self.onReceivedLeaveLinkMic) {
            self.onReceivedLeaveLinkMic(sender, sender.userId);
        }
        return;
    }
    if (message.msgType == AUIRoomMessageTypeApplyLinkMic) {
        if (self.onReceivedApplyLinkMic) {
            self.onReceivedApplyLinkMic(sender);
        }
        return;
    }
    if (message.msgType == AUIRoomMessageTypeCancelApplyLinkMic) {
        if (self.onReceivedCancelApplyLinkMic) {
            self.onReceivedCancelApplyLinkMic(sender);
        }
        return;
    }
    if (message.msgType == AUIRoomMessageTypeResponseLinkMic) {
        if (self.onReceivedResponseApplyLinkMic) {
            self.onReceivedResponseApplyLinkMic(sender, [[data objectForKey:@"agree"] boolValue], [data objectForKey:@"rtcPullUrl"]);
        }
        return;
    }
    if (message.msgType == AUIRoomMessageTypeKickoutLinkMic) {
        if (self.onReceivedLeaveLinkMic) {
            self.onReceivedLeaveLinkMic(sender, AUIRoomAccount.me.userId);
        }
        return;
    }
    
    if (message.msgType == AUIRoomMessageTypeMicOpened) {
        if (self.onReceivedMicOpened) {
            self.onReceivedMicOpened(sender, [[data objectForKey:@"micOpened"] boolValue]);
        }
        return;
    }
    
    if (message.msgType == AUIRoomMessageTypeCameraOpened) {
        if (self.onReceivedCameraOpened) {
            self.onReceivedCameraOpened(sender, [[data objectForKey:@"cameraOpened"] boolValue]);
        }
        return;
    }
    
    if (message.msgType == AUIRoomMessageTypeNeedOpenMic) {
        if (self.onReceivedOpenMic) {
            self.onReceivedOpenMic(sender, [[data objectForKey:@"needOpenMic"] boolValue]);
        }
        return;
    }
    
    if (message.msgType == AUIRoomMessageTypeNeedOpenCamera) {
        if (self.onReceivedOpenCamera) {
            self.onReceivedOpenCamera(sender, [[data objectForKey:@"needOpenCamera"] boolValue]);
        }
        return;
    }
    
    if (message.msgType == AUIRoomMessageTypeGift) {
        if (self.onReceivedGift) {
            self.onReceivedGift(sender, [[AUIRoomGiftModel alloc] initWithData:data]);
        }
        return;
    }
    
    if (self.onReceivedCustomMessage) {
        self.onReceivedCustomMessage(message);
    }
}

- (void)onLikeReceived:(AUIMessageModel *)message {
    AUIRoomUser *sender = [self userFromMessageUserInfo:message.sender];
    NSInteger likeCount = [[message.data objectForKey:@"likeCount"] integerValue];
    if (likeCount > self.allLikeCount) {
        self.allLikeCount = likeCount;
        if (self.onReceivedLike) {
            self.onReceivedLike(sender, self.allLikeCount);
        }
    }
}

- (void)onCommentReceived:(AUIMessageModel *)message {
    AUIRoomUser *sender = [self userFromMessageUserInfo:message.sender];
    NSDictionary *data = message.data;

    if (self.onReceivedComment) {
        NSString *comment = [data objectForKey:@"content"];
        self.onReceivedComment(sender, comment);
    }
}

- (void)onJoinGroup:(AUIMessageModel *)message {
    if (![message.sender.userId isEqualToString:AUIRoomAccount.me.userId]) {
        // 不是自己进群，则PV加1，因为自己在joinGroup后已经获取最新的PV了
        self.pv++;
        if (self.onReceivedPV) {
            self.onReceivedPV(self.pv);
        }
    }
}

- (void)onLeaveGroup:(AUIMessageModel *)message {
}

- (void)onMuteGroup:(AUIMessageModel *)message {
    self.isMuteAll = YES;
    if (self.onReceivedMuteAll) {
        self.onReceivedMuteAll(self.isMuteAll);
    }
}

- (void)onCancelMuteGroup:(AUIMessageModel *)message {
    self.isMuteAll = NO;
    if (self.onReceivedMuteAll) {
        self.onReceivedMuteAll(self.isMuteAll);
    }
}

- (void)onExitedGroup:(NSString *)groupId {
    if (self.onReceivedLeaveRoom) {
        self.onReceivedLeaveRoom();
    }
}

@end
