//
//  AUIRoomInteractionLiveManagerAudience.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/27.
//

#import "AUIRoomInteractionLiveManagerAudience.h"
#import "AUIRoomBaseLiveManagerAudience+Private.h"
#import "AUIRoomLivePusher.h"
#import "AUIRoomAccount.h"


@interface AUIRoomInteractionLiveManagerAudience ()

@property (assign, nonatomic) BOOL scaleAspectFit;
@property (strong, nonatomic) AUIRoomLivePusher *livePusher;
@property (strong, nonatomic) NSMutableArray<AUIRoomLiveRtcPlayer *> *joinList; // 当前上麦列表
@property (assign, nonatomic) NSUInteger displayIndex;
@property (assign, nonatomic) BOOL micOpened;
@property (assign, nonatomic) BOOL cameraOpened;

@property (assign, nonatomic) BOOL isApplyingLinkMic;
@property (assign, nonatomic) BOOL needToNotifyApplyNotResponse;

@end


@implementation AUIRoomInteractionLiveManagerAudience

- (instancetype)initWithModel:(AUIRoomLiveInfoModel *)liveInfoModel withJoinList:(nullable NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)joinList {
    self = [super init];
    if (self) {
        AUIRoomLiveService *liveService = [[AUIRoomLiveService alloc] initWithModel:liveInfoModel withJoinList:joinList];
        self.liveService = liveService;
        
        [self setupLiveService];
    }
    return self;
}

- (void)setupLiveService {
    [super setupLiveService];
    
    __weak typeof(self) weakSelf = self;
    self.liveService.onReceivedJoinLinkMic = ^(AUIRoomUser * _Nonnull sender, AUIRoomLiveLinkMicJoinInfoModel * _Nonnull joinInfo) {
        [weakSelf receivedJoinLinkMic:joinInfo completed:^(BOOL success) {
            if (success) {
                if (weakSelf.onReceivedJoinLinkMic) {
                    weakSelf.onReceivedJoinLinkMic(sender);
                }
            }
        }];
    };
    self.liveService.onReceivedLeaveLinkMic = ^(AUIRoomUser * _Nonnull sender, NSString * _Nonnull userId) {
        [weakSelf receivedLeaveLinkMic:userId completed:^(BOOL success) {
            if (success) {
                if (weakSelf.onReceivedLeaveLinkMic) {
                    weakSelf.onReceivedLeaveLinkMic(userId);
                }
            }
        }];
    };
    self.liveService.onReceivedMicOpened = ^(AUIRoomUser * _Nonnull sender, BOOL opened) {
        [weakSelf receivedMicOpened:sender opened:opened completed:nil];
    };
    self.liveService.onReceivedCameraOpened = ^(AUIRoomUser * _Nonnull sender, BOOL opened) {
        [weakSelf receivedCameraOpened:sender opened:opened completed:nil];
    };
}

- (NSArray<AUIRoomLiveRtcPlayer *> *)currentJoinList {
    return [self.joinList copy];
}

- (void)setupPullPlayer:(BOOL)scaleAspectFit {
    self.scaleAspectFit = scaleAspectFit;
    [self setupPullPlayerWithRemoteJoinList:self.liveService.joinList];
}

- (BOOL)pause:(BOOL)pause {
    return NO;
}

- (void)setupPullPlayerWithRemoteJoinList:(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)remoteJoinList {
    self.joinList = [NSMutableArray array];
    self.displayIndex = 0;
    self.micOpened = YES;
    self.cameraOpened = YES;
    __block BOOL find = NO;
    [remoteJoinList enumerateObjectsUsingBlock:^(AUIRoomLiveLinkMicJoinInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:AUIRoomAccount.me.userId]) {
            find = YES;
            self.displayIndex = idx;
            self.micOpened = obj.micOpened;
            self.cameraOpened = obj.cameraOpened;
            return;
        }
        AUIRoomLiveRtcPlayer *pull = [[AUIRoomLiveRtcPlayer alloc] init];
        pull.joinInfo = obj;
        [self.joinList addObject:pull];
    }];
    
    if (find) {
        [self setupLivePusher];
        self.isLiving = NO;
    }
    else {
        [super setupPullPlayer:self.scaleAspectFit];  // cdn player
        [self.joinList removeAllObjects];
    }
}

- (void)setupLivePusher {
    self.livePusher = [[AUIRoomLivePusher alloc] init];
    self.livePusher.liveInfoModel = self.liveService.liveInfoModel;
    self.livePusher.beautyController = self.roomVC ? [AUIRoomBeautyManager createController:self.roomVC.view pixelBufferMode:YES] : nil;
    self.livePusher.isMute = !self.micOpened;
    self.livePusher.isPause = !self.cameraOpened;
}

- (void)leaveRoom:(void (^)(BOOL))completed {
    if (self.isApplyingLinkMic) {
        [self cancelApplyLinkMic:nil];
    }
    [super leaveRoom:completed];
}

- (BOOL)isJoinedLinkMic {
    return self.livePusher != nil;
}

- (void)preparePullPlayer {
    if ([self isJoinedLinkMic]) {
        
        [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull pull, NSUInteger idx, BOOL * _Nonnull stop) {
            [pull prepare];
            pull.displayView.isAnchor = [pull.joinInfo.userId isEqualToString:self.liveService.liveInfoModel.anchor_id];
            pull.displayView.nickName = [pull.joinInfo.userId isEqualToString:AUIRoomAccount.me.userId] ? @"我" : pull.joinInfo.userNick;
            pull.displayView.isAudioOff = !pull.joinInfo.micOpened;
            [self.displayLayoutView addDisplayView:pull.displayView];
        }];
        
        self.livePusher.displayView.showLoadingIndicator = NO;
        self.livePusher.displayView.isAudioOff = self.livePusher.isMute;
        [self.displayLayoutView insertDisplayView:self.livePusher.displayView atIndex:self.displayIndex];
        [self.livePusher prepare];
        
        [self.displayLayoutView layoutAll];
    }
    else {
        [super preparePullPlayer];
    }
}

- (void)startPullPlayer {
    if ([self isJoinedLinkMic]) {
        [self.livePusher start];
        [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj start];
        }];
        self.isLiving = YES;
    }
    else {
        [super startPullPlayer];
    }
}

- (void)destoryPullPlayer {
    [self destoryPullPlayerByKick:NO];
}


- (void)destoryPullPlayerByKick:(BOOL)byKickout{
    if ([self isJoinedLinkMic]) {
        [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.displayLayoutView removeDisplayView:obj.displayView];
            [obj destory];
        }];
        [self.displayLayoutView removeDisplayView:self.livePusher.displayView];
        [self.livePusher destory];
        self.livePusher = nil;
        [self.displayLayoutView layoutAll];
        self.isLiving = NO;
        [self.liveService sendLeaveLinkMic:byKickout completed:nil];
    }
    else {
        [super destoryPullPlayer];
    }
}

- (void (^)(AUIRoomUser * _Nonnull, BOOL))onReceivedOpenMic {
    return self.liveService.onReceivedOpenMic;
}

- (void)setOnReceivedOpenMic:(void (^)(AUIRoomUser * _Nonnull, BOOL))onReceivedOpenMic {
    self.liveService.onReceivedOpenMic = onReceivedOpenMic;
}

- (void (^)(AUIRoomUser * _Nonnull, BOOL))onReceivedOpenCamera {
    return self.liveService.onReceivedOpenCamera;
}

- (void)setOnReceivedOpenCamera:(void (^)(AUIRoomUser * _Nonnull, BOOL))onReceivedOpenCamera {
    self.liveService.onReceivedOpenCamera = onReceivedOpenCamera;
}

- (BOOL)isMicOpened {
    return !self.livePusher.isMute;
}

- (BOOL)isCameraOpened {
    return !self.livePusher.isPause;
}

- (BOOL)isBackCamera {
    return self.livePusher.isBackCamera;
}

- (void)openLivePusherMic:(BOOL)open {
    [self.livePusher mute:!open];
    self.livePusher.displayView.isAudioOff = !self.isMicOpened;
    [self.liveService sendMicOpened:self.isMicOpened completed:nil];
}

- (void)openLivePusherCamera:(BOOL)open {
    [self.livePusher pause:!open];
    [self.liveService sendCameraOpened:self.isCameraOpened completed:nil];
}

- (void)switchLivePusherCamera {
    [self.livePusher switchCamera];
}


- (void)applyLinkMic:(void (^)(BOOL))completed {
    if ([self isJoinedLinkMic] || !self.isLiving || self.isApplyingLinkMic) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.liveService sendApplyLinkMic:self.liveService.liveInfoModel.anchor_id completed:^(BOOL success) {
        if (success) {
            weakSelf.isApplyingLinkMic = YES;
            [weakSelf startNotifyApplyNotResponse];
        }
        if (completed) {
            completed(success);
        }
    }];
}

- (void)cancelApplyLinkMic:(void (^)(BOOL))completed {
    if ([self isJoinedLinkMic] || !self.isLiving || !self.isApplyingLinkMic) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    self.isApplyingLinkMic = NO;
    [self cancelNotifyApplyNotResponse];
    
    [self.liveService sendCancelApplyLinkMic:self.liveService.liveInfoModel.anchor_id completed:nil];
    if (completed) {
        completed(YES);
    }
}

- (void (^)(AUIRoomUser * _Nonnull, BOOL, NSString * _Nonnull))onReceivedResponseApplyLinkMic {
    return self.liveService.onReceivedResponseApplyLinkMic;
}

- (void)setOnReceivedResponseApplyLinkMic:(void (^)(AUIRoomUser * _Nonnull, BOOL, NSString * _Nonnull))onReceivedResponseApplyLinkMic {
    self.liveService.onReceivedResponseApplyLinkMic = onReceivedResponseApplyLinkMic;
}

// 收到同意上麦
- (void)receivedAgreeToLinkMic:(NSString *)userId willGiveUp:(BOOL)giveUp completed:(nullable void (^)(BOOL success, BOOL giveUp, NSString *message))completed {
    if (!self.isLiving || ![userId isEqualToString:self.liveService.liveInfoModel.anchor_id]) {
        if (completed) {
            completed(NO, NO, @"当前状态不对");
        }
        return;
    }
    
    self.isApplyingLinkMic = NO;
    [self cancelNotifyApplyNotResponse];
    
    if (giveUp) {
        [self.liveService sendCancelApplyLinkMic:self.liveService.liveInfoModel.anchor_id completed:nil];
        if (completed) {
            completed(YES, YES, nil);
        }
        return;
    }
    
    [self joinLinkMic:^(BOOL success, NSString *message) {
        if (completed) {
            completed(success, NO, message);
        }
    }];
}

// 收到不同意上麦
- (void)receivedDisagreeToLinkMic:(NSString *)userId completed:(nullable void (^)(BOOL))completed {
    if (!self.isLiving || ![userId isEqualToString:self.liveService.liveInfoModel.anchor_id]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    self.isApplyingLinkMic = NO;
    [self cancelNotifyApplyNotResponse];
    
    if (completed) {
        completed(YES);
    }
}

// 收到其他观众上麦
- (void)receivedJoinLinkMic:(AUIRoomLiveLinkMicJoinInfoModel *)joinInfo completed:(nullable void (^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    if ([self isJoinedLinkMic]) {
        if ([joinInfo.userId isEqual:AUIRoomAccount.me.userId]) {
            if (completed) {
                completed(YES);
            }
            return;
        }
        __block AUIRoomLiveRtcPlayer *pull = nil;
        [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.joinInfo.userId isEqualToString:joinInfo.userId]) {
                pull = obj;
                *stop = YES;
            }
        }];
        if (!pull) {
            pull = [[AUIRoomLiveRtcPlayer alloc] init];
            pull.joinInfo = joinInfo;
            [self.joinList addObject:pull];
            
            [pull prepare];
            pull.displayView.isAnchor = [pull.joinInfo.userId isEqualToString:self.liveService.liveInfoModel.anchor_id];
            pull.displayView.nickName = [pull.joinInfo.userId isEqualToString:AUIRoomAccount.me.userId] ? @"我" : pull.joinInfo.userNick;
            pull.displayView.isAudioOff = !pull.joinInfo.micOpened;
            [self.displayLayoutView addDisplayView:pull.displayView];
            [self.displayLayoutView layoutAll];
            [pull start];
        }
        
        if (completed) {
            completed(YES);
        }
    }
    else {
        if (completed) {
            completed(NO);
        }
    }
}

// 收到其他观众下麦/自己被踢下麦
- (void)receivedLeaveLinkMic:(NSString *)userId completed:(nullable void (^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    if ([self isJoinedLinkMic]) {
        if ([userId isEqualToString:AUIRoomAccount.me.userId]) {
            [self leaveLinkMic:YES completed:completed];
            return;
        }
        
        __block AUIRoomLiveRtcPlayer *pull = nil;
        [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.joinInfo.userId isEqualToString:userId]) {
                pull = obj;
                *stop = YES;
            }
        }];
        if (pull) {
            [self.displayLayoutView removeDisplayView:pull.displayView];
            [self.displayLayoutView layoutAll];
                    
            [pull destory];
            [self.joinList removeObject:pull];
        }
        if (completed) {
            completed(YES);
        }
    }
    else {
        if (completed) {
            completed(NO);
        }
    }
}

// 上麦
- (void)joinLinkMic:(void(^)(BOOL, NSString *))completed; {
    if (!self.isLiving || [self isJoinedLinkMic]) {
        if (completed) {
            completed(NO, @"当前状态不对");
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.liveService queryLinkMicJoinList:^(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> * _Nullable remoteJoinList) {
        if (!remoteJoinList) {
            if (completed) {
                completed(NO, @"无法获取当前上麦列表，上麦失败");
            }
            return;
        }
        
        if (remoteJoinList.count >= AUIRoomLiveService.maxLinkMicCount) {
            if (completed) {
                completed(NO, @"当前连麦人数已经超过最大限制，连麦失败");
            }
            return;
        }
        
        AUIRoomLiveLinkMicJoinInfoModel *my = [[AUIRoomLiveLinkMicJoinInfoModel alloc] init:AUIRoomAccount.me.userId userNick:AUIRoomAccount.me.nickName userAvatar:AUIRoomAccount.me.avatar rtcPullUrl:weakSelf.liveService.liveInfoModel.link_info.rtc_pull_url];
        NSMutableArray<AUIRoomLiveLinkMicJoinInfoModel *> *list = [NSMutableArray arrayWithArray:remoteJoinList];
        [list addObject:my];
        [weakSelf destoryPullPlayer];
        [weakSelf setupPullPlayerWithRemoteJoinList:list];
        [weakSelf preparePullPlayer];
        [weakSelf startPullPlayer];
        
        [weakSelf.liveService sendJoinLinkMic:my.rtcPullUrl completed:nil];
        if (completed) {
            completed(YES, nil);
        }
    }];
}

// 下麦
- (void)leaveLinkMic:(void(^)(BOOL))completed; {
    [self leaveLinkMic:NO completed:completed];
}

- (void)leaveLinkMic:(BOOL)byKickout completed:(void(^)(BOOL))completed; {
    if (!self.isLiving || ![self isJoinedLinkMic]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    [self destoryPullPlayerByKick:byKickout];
    [self setupPullPlayerWithRemoteJoinList:nil];
    [self preparePullPlayer];
    [self startPullPlayer];
    if (completed) {
        completed(YES);
    }
}

// 收到开启/关闭麦克风
- (void)receivedMicOpened:(AUIRoomUser *)sender opened:(BOOL)opened completed:(void (^)(BOOL))completed {
    if (!self.isLiving || !self.isJoinedLinkMic || [sender.userId isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    __block AUIRoomLiveRtcPlayer *pull = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.joinInfo.userId isEqualToString:sender.userId]) {
            pull = obj;
            *stop = YES;
        }
    }];
    if (pull) {
        pull.joinInfo.micOpened = opened;
        pull.displayView.isAudioOff = !pull.joinInfo.micOpened;
    }
    if (completed) {
        completed(pull != nil);
    }
}

// 收到开启/关闭摄像头
- (void)receivedCameraOpened:(AUIRoomUser *)sender opened:(BOOL)opened completed:(void (^)(BOOL))completed {
    if (!self.isLiving || !self.isJoinedLinkMic || [sender.userId isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block AUIRoomLiveRtcPlayer *pull = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.joinInfo.userId isEqualToString:sender.userId]) {
            pull = obj;
            *stop = YES;
        }
    }];
    if (pull) {
        pull.joinInfo.cameraOpened = opened;
    }
    if (completed) {
        completed(pull != nil);
    }
}

// 定时任务

- (void)startNotifyApplyNotResponse {
    [self cancelNotifyApplyNotResponse];
    [self performSelector:@selector(timeToNotifyApplyNotResponse) withObject:nil afterDelay:30];
    self.needToNotifyApplyNotResponse = YES;
}

- (void)cancelNotifyApplyNotResponse {
    self.needToNotifyApplyNotResponse = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeToNotifyApplyNotResponse) object:nil];
}

- (void)timeToNotifyApplyNotResponse {
    if (self.needToNotifyApplyNotResponse) {
        if (self.onNotifyApplyNotResponse) {
            self.onNotifyApplyNotResponse(self);
        }
    }
}

@end
