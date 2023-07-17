//
//  AUIRoomInteractionLiveManagerAnchor.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/4.
//

#import "AUIRoomInteractionLiveManagerAnchor.h"
#import "AUIRoomBaseLiveManagerAnchor+Private.h"
#import "AUIRoomAccount.h"

@interface AUIRoomInteractionLiveManagerAnchor ()

@property (strong, nonatomic) NSMutableArray<AUIRoomLiveRtcPlayer *> *joinList; // 当前上麦列表
@property (strong, nonatomic) NSMutableArray<AUIRoomUser *> *joiningList; // 正在上麦列表
@property (strong, nonatomic) NSMutableArray<AUIRoomUser *> *applyList;

@end



@implementation AUIRoomInteractionLiveManagerAnchor

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
    self.liveService.onReceivedApplyLinkMic = ^(AUIRoomUser * _Nonnull sender) {
        if (![weakSelf checkCanLinkMic]) {
            // 超过最大连麦数，直接拒绝
            [weakSelf responseApplyLinkMic:sender agree:NO force:YES completed:^(BOOL success) {
            }];
            return;
        }
        
        [weakSelf receiveApplyLinkMic:sender completed:^(BOOL success) {
            if (success) {
                if (weakSelf.onReceivedApplyLinkMic) {
                    weakSelf.onReceivedApplyLinkMic(sender);
                }
            }
        }];
    };
    self.liveService.onReceivedCancelApplyLinkMic = ^(AUIRoomUser * _Nonnull sender) {
        [weakSelf receiveCancelApplyLinkMic:sender completed:^(BOOL success) {
            if (success) {
                if (weakSelf.onReceivedCancelApplyLinkMic) {
                    weakSelf.onReceivedCancelApplyLinkMic(sender);
                }
            }
        }];
    };
    
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
        [weakSelf receivedMicOpened:sender opened:opened];
    };
    self.liveService.onReceivedCameraOpened = ^(AUIRoomUser * _Nonnull sender, BOOL opened) {
        [weakSelf receivedCameraOpened:sender opened:opened];
    };
}

- (NSArray<AUIRoomUser *> *)currentApplyList {
    return [self.applyList copy];
}

- (NSArray<AUIRoomLiveRtcPlayer *> *)currentJoinList {
    return [self.joinList copy];
}

- (NSArray<AUIRoomUser *> *)currentJoiningList {
    return [self.joiningList copy];
}

- (void)setupLivePusher {
    [super setupLivePusher];
    
    self.applyList = [NSMutableArray array];
    self.joinList = [NSMutableArray array];
    self.joiningList = [NSMutableArray array];
    [self.liveService.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveLinkMicJoinInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:self.liveService.liveInfoModel.anchor_id]) {
            self.livePusher.isMute = !obj.micOpened;
            self.livePusher.isPause = !obj.cameraOpened;
            return;
        }
        AUIRoomLiveRtcPlayer *pull = [[AUIRoomLiveRtcPlayer alloc] init];
        pull.joinInfo = obj;
        [self.joinList addObject:pull];
    }];
    
    [self reportLinkMicJoinList:nil];
}

- (void)prepareLivePusher {
    [super prepareLivePusher];
    
    self.livePusher.displayView.isAudioOff = self.livePusher.isMute;
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull pull, NSUInteger idx, BOOL * _Nonnull stop) {
        [pull prepare];
        pull.displayView.isAnchor = [pull.joinInfo.userId isEqualToString:self.liveService.liveInfoModel.anchor_id];
        pull.displayView.nickName = [pull.joinInfo.userId isEqualToString:AUIRoomAccount.me.userId] ? @"我" : pull.joinInfo.userNick;
        pull.displayView.isAudioOff = !pull.joinInfo.micOpened;
        [self.displayLayoutView addDisplayView:pull.displayView];
    }];
    [self.displayLayoutView layoutAll];
}

- (void)startLivePusher {
    [super startLivePusher];
    
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj start];
    }];
    [self mixStream];
}

- (void)destoryLivePusher {
    [super destoryLivePusher];
    
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj destory];
        [self.displayLayoutView removeDisplayView:obj.displayView];
    }];
    [self.displayLayoutView layoutAll];
}

// 更新连麦列表
- (void)reportLinkMicJoinList:(nullable void (^)(BOOL))completed {
    NSMutableArray *array = [NSMutableArray array];
    AUIRoomLiveLinkMicJoinInfoModel *anchorJoinInfo = [[AUIRoomLiveLinkMicJoinInfoModel alloc] init:AUIRoomAccount.me.userId userNick:AUIRoomAccount.me.nickName userAvatar:AUIRoomAccount.me.avatar rtcPullUrl:self.liveService.liveInfoModel.link_info.rtc_pull_url];
    anchorJoinInfo.cameraOpened = !self.livePusher.isPause;
    anchorJoinInfo.micOpened = !self.livePusher.isMute;
    [array addObject:anchorJoinInfo];
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:obj.joinInfo];
    }];
    
    [self.liveService updateLinkMicJoinList:array completed:completed];
}

// 是否可以连麦
- (BOOL)checkCanLinkMic {
    NSUInteger max = AUIRoomLiveService.maxLinkMicCount;
    return self.joinList.count < max - 1;
}

// 收到观众连麦申请
- (void)receiveApplyLinkMic:(AUIRoomUser *)sender completed:(nullable void(^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block BOOL find = NO;
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.joinInfo.userId isEqualToString:sender.userId]) {
            find = YES;
            *stop = YES;
        }
    }];
    if (!find) {
        [self.applyList enumerateObjectsUsingBlock:^(AUIRoomUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.userId isEqualToString:sender.userId]) {
                find = YES;
            }
        }];
        if (!find) {
            [self.applyList addObject:sender];
            if (self.applyListChangedBlock) {
                self.applyListChangedBlock(self);
            }
            __block AUIRoomUser *joiningUser = nil;
            [self.joiningList enumerateObjectsUsingBlock:^(AUIRoomUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.userId isEqualToString:sender.userId]) {
                    joiningUser = obj;
                    *stop = YES;
                }
            }];
            if (joiningUser) {
                [self.joiningList removeObject:joiningUser];
            }
            if (completed) {
                completed(YES);
            }
            return;
        }
    }
    if (completed) {
        completed(NO);
    }
}

// 收到观众取消连麦申请
- (void)receiveCancelApplyLinkMic:(AUIRoomUser *)sender completed:(nullable void(^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    // 从申请列表中移除
    __block AUIRoomUser *find = nil;
    [self.applyList enumerateObjectsUsingBlock:^(AUIRoomUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:sender.userId]) {
            find = obj;
            *stop = YES;
        }
    }];

    if (find) {
        [self.applyList removeObject:find];
        if (self.applyListChangedBlock) {
            self.applyListChangedBlock(self);
        }
        if (completed) {
            completed(YES);
        }
        return;
    }
    
    // 从等待上麦列表中移除
    [self.joiningList enumerateObjectsUsingBlock:^(AUIRoomUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:sender.userId]) {
            find = obj;
            *stop = YES;
        }
    }];
    if (find) {
        [self.joiningList removeObject:find];
        if (completed) {
            completed(YES);
        }
    }
    
    if (completed) {
        completed(NO);
    }
}

// 响应一个观众的连麦申请
- (void)responseApplyLinkMic:(AUIRoomUser *)user agree:(BOOL)agree force:(BOOL)force completed:(void (^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block AUIRoomUser *find = nil;
    [self.applyList enumerateObjectsUsingBlock:^(AUIRoomUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:user.userId]) {
            find = obj;
            *stop = YES;
        }
    }];
    if (!find && force) {
        find = user;
    }
    if (find || force) {
        __weak typeof(self) weakSelf = self;
        [self.liveService sendResponseLinkMic:find.userId agree:agree pullUrl:self.liveService.liveInfoModel.link_info.rtc_pull_url completed:^(BOOL success) {
            if (success) {
                [weakSelf.applyList removeObject:find];
                if (weakSelf.applyListChangedBlock) {
                    weakSelf.applyListChangedBlock(weakSelf);
                }
                if (agree) {
                    __block AUIRoomUser *joiningUser = nil;
                    [weakSelf.joiningList enumerateObjectsUsingBlock:^(AUIRoomUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.userId isEqualToString:find.userId]) {
                            joiningUser = obj;
                            *stop = YES;
                        }
                    }];
                    if (!joiningUser) {
                        [weakSelf.joiningList addObject:find];
                    }
                }
            }
            if (completed) {
                completed(success);
            }
        }];
    }
    else {
        if (completed) {
            completed(NO);
        }
    }
}

// 踢人下麦
- (void)kickoutLinkMic:(NSString *)uid completed:(void (^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block AUIRoomLiveRtcPlayer *find = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.joinInfo.userId isEqualToString:uid]) {
            find = obj;
            *stop = YES;
        }
    }];
    if (find) {
        __weak typeof(self) weakSelf = self;
        [self.liveService sendKickoutLinkMic:uid completed:^(BOOL success) {
            if (success) {
                [weakSelf onLeaveLinkMic:find];
            }
            if (completed) {
                completed(success);
            }
        }];
    }
    else {
        if (completed) {
            completed(NO);
        }
    }
}

// 收到观众上麦
- (void)receivedJoinLinkMic:(AUIRoomLiveLinkMicJoinInfoModel *)joinInfo completed:(nullable void(^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
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
        [self onJoinLinkMic:pull];
        if (completed) {
            completed(YES);
        }
        return;
    }
    if (completed) {
        completed(NO);
    }
}

// 收到观众下麦
- (void)receivedLeaveLinkMic:(NSString *)userId completed:(nullable void(^)(BOOL))completed {
    __block AUIRoomLiveRtcPlayer *pull = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.joinInfo.userId isEqualToString:userId]) {
            pull = obj;
            *stop = YES;
        }
    }];
    if (pull) {
        [self onLeaveLinkMic:pull];
        if (completed) {
            completed(YES);
        }
        return;
    }
    if (completed) {
        completed(NO);
    }
}

- (void)onJoinLinkMic:(AUIRoomLiveRtcPlayer *)pull {
    [pull prepare];
    pull.displayView.isAnchor = [pull.joinInfo.userId isEqualToString:self.liveService.liveInfoModel.anchor_id];
    pull.displayView.nickName = [pull.joinInfo.userId isEqualToString:AUIRoomAccount.me.userId] ? @"我" : pull.joinInfo.userNick;
    pull.displayView.isAudioOff = !pull.joinInfo.micOpened;
    [self.displayLayoutView addDisplayView:pull.displayView];
    [self.displayLayoutView layoutAll];
    [pull start];
    
    __block AUIRoomUser *joiningUser = nil;
    [self.joiningList enumerateObjectsUsingBlock:^(AUIRoomUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:pull.joinInfo.userId]) {
            joiningUser = obj;
            *stop = YES;
        }
    }];
    if (joiningUser) {
        [self.joiningList removeObject:joiningUser];
    }
    [self.joinList addObject:pull];
    [self mixStream];
    
    [self reportLinkMicJoinList:nil];
}

- (void)onLeaveLinkMic:(AUIRoomLiveRtcPlayer *)pull {
    [self.displayLayoutView removeDisplayView:pull.displayView];
    [self.displayLayoutView layoutAll];
    [pull destory];
    [self.joinList removeObject:pull];
    [self mixStream];
    
    [self reportLinkMicJoinList:nil];
}

- (void)mixStream {
    AlivcLiveTranscodingConfig *liveTranscodingConfig = nil;
    if (self.joinList.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        CGRect rect = [self.displayLayoutView renderRect:self.livePusher.displayView];
        AlivcLiveMixStream *anchorStream = [[AlivcLiveMixStream alloc] init];
        anchorStream.userId = self.livePusher.liveInfoModel.anchor_id;
        anchorStream.x = rect.origin.x;
        anchorStream.y = rect.origin.y;
        anchorStream.width = rect.size.width;
        anchorStream.height = rect.size.height;
        anchorStream.zOrder = (int)[self.displayLayoutView.displayViewList indexOfObject:self.livePusher.displayView] + 1;
        [array addObject:anchorStream];
        
        [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect rect = [self.displayLayoutView renderRect:obj.displayView];
            AlivcLiveMixStream *audienceStream = [[AlivcLiveMixStream alloc] init];
            audienceStream.userId = obj.joinInfo.userId;
            audienceStream.x = rect.origin.x;
            audienceStream.y = rect.origin.y;
            audienceStream.width = rect.size.width;
            audienceStream.height = rect.size.height;
            audienceStream.zOrder = (int)[self.displayLayoutView.displayViewList indexOfObject:obj.displayView] + 1;
            [array addObject:audienceStream];
        }];
        liveTranscodingConfig = [[AlivcLiveTranscodingConfig alloc] init];
        liveTranscodingConfig.mixStreams = array;
    }
    
    [self.livePusher setLiveMixTranscodingConfig:liveTranscodingConfig];
}

- (void)receivedMicOpened:(AUIRoomUser *)sender opened:(BOOL)opened {
    if (!self.isLiving || [sender.userId isEqualToString:AUIRoomAccount.me.userId]) {
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
        if (self.onReceivedMicOpened) {
            self.onReceivedMicOpened(sender, opened);
        }
        [self reportLinkMicJoinList:nil];
    }
}

- (void)receivedCameraOpened:(AUIRoomUser *)sender opened:(BOOL)opened {
    if (!self.isLiving || [sender.userId isEqualToString:AUIRoomAccount.me.userId]) {
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
        if (self.onReceivedCameraOpened) {
            self.onReceivedCameraOpened(sender, opened);
        }
        [self reportLinkMicJoinList:nil];
    }
}

- (void)openMic:(NSString *)uid needOpen:(BOOL)needOpen completed:(void (^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    [self.liveService sendOpenMic:uid needOpen:needOpen completed:completed];
}

- (void)openCamera:(NSString *)uid needOpen:(BOOL)needOpen completed:(void (^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    [self.liveService sendOpenCamera:uid needOpen:needOpen completed:completed];
}

- (void)openLivePusherMic:(BOOL)open {
    [super openLivePusherMic:open];
    self.livePusher.displayView.isAudioOff = !self.isMicOpened;
    [self.liveService sendMicOpened:self.isMicOpened completed:nil];
    [self reportLinkMicJoinList:nil];
}

- (void)openLivePusherCamera:(BOOL)open {
    [super openLivePusherCamera:open];
    [self.liveService sendCameraOpened:self.isCameraOpened completed:nil];
    [self reportLinkMicJoinList:nil];
}

@end

