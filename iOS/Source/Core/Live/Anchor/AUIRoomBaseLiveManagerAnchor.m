//
//  AUIRoomBaseLiveManagerAnchor.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/4.
//

#import "AUIRoomBaseLiveManagerAnchor+Private.h"


@implementation AUIRoomBaseLiveManagerAnchor

@synthesize displayLayoutView;
@synthesize roomVC;

@synthesize onStartedBlock;
@synthesize onResumedBlock;
@synthesize onRestartBlock;
@synthesize onReconnectSuccessBlock;
@synthesize onReconnectStartBlock;
@synthesize onReconnectErrorBlock;
@synthesize onPausedBlock;
@synthesize onConnectionRecoveryBlock;
@synthesize onConnectionPoorBlock;
@synthesize onConnectionLostBlock;
@synthesize onConnectErrorBlock;
@synthesize onReceivedLeaveRoom;

- (instancetype)initWithModel:(AUIRoomLiveInfoModel *)liveInfoModel {
    self = [super init];
    if (self) {
        AUIRoomLiveService *liveService = [[AUIRoomLiveService alloc] initWithModel:liveInfoModel withJoinList:nil];
        self.liveService = liveService;
        [self setupLiveService];
    }
    return self;
}

- (AUIRoomLiveInfoModel *)liveInfoModel {
    return self.liveService.liveInfoModel;
}

- (void)setupLiveService {
    __weak typeof(self) weakSelf = self;
    self.liveService.onReceivedLeaveRoom = ^{
        [weakSelf destoryLivePusher];
        if (weakSelf.onReceivedLeaveRoom) {
            weakSelf.onReceivedLeaveRoom();
        }
    };
}

- (void)setupLivePusher {
    self.livePusher = [[AUIRoomLivePusher alloc] init];
    self.livePusher.liveInfoModel = self.liveService.liveInfoModel;
    self.livePusher.onStartedBlock = self.onStartedBlock;
    self.livePusher.onPausedBlock = self.onPausedBlock;
    self.livePusher.onResumedBlock = self.onResumedBlock;
    self.livePusher.onRestartBlock = self.onRestartBlock;
    self.livePusher.onConnectionPoorBlock = self.onConnectionPoorBlock;
    self.livePusher.onConnectionLostBlock = self.onConnectionLostBlock;
    self.livePusher.onConnectionRecoveryBlock = self.onConnectionRecoveryBlock;
    self.livePusher.onConnectErrorBlock = self.onConnectErrorBlock;
    self.livePusher.onReconnectStartBlock = self.onReconnectStartBlock;
    self.livePusher.onReconnectSuccessBlock = self.onReconnectSuccessBlock;
    self.livePusher.onReconnectErrorBlock = self.onReconnectErrorBlock;
    if (self.roomVC) {
        self.livePusher.beautyController = [AUIRoomBeautyManager createController:self.roomVC.view pixelBufferMode:self.liveService.liveInfoModel.mode == AUIRoomLiveModeLinkMic];
    }
    self.isLiving = NO;
}

- (void)enterRoom:(void (^)(BOOL))completed {
    __weak typeof(self) weakSelf = self;
    [self.liveService enterRoom:^(BOOL success) {
        if (completed) {
            completed(success);
        }
        if (success) {
            if (weakSelf.liveService.liveInfoModel.status == AUIRoomLiveStatusNone) {
                [weakSelf prepareLivePusher];
            }
            else if (weakSelf.liveService.liveInfoModel.status == AUIRoomLiveStatusLiving) {
                [weakSelf prepareLivePusher];
                [weakSelf startLivePusher];
            }
            else if (weakSelf.liveService.liveInfoModel.status == AUIRoomLiveStatusFinished) {
            }
            else {
                // 状态出错
            }
        }
    }];
}

- (void)leaveRoom:(void (^)(BOOL))completed {
    [self destoryLivePusher];
    __weak typeof(self) weakSelf = self;
    [self.liveService finishLive:^(BOOL success) {
        if (success) {
            [weakSelf.liveService leaveRoom:completed];
        }
        else {
            if (completed) {
                completed(NO);
            }
        }
    }];
}

- (void)startLive:(void (^)(BOOL))completed {
    __weak typeof(self) weakSelf = self;
    [self startLivePusher];
    [self.liveService startLive:^(BOOL success) {
        if (completed) {
            completed(success);
        }
        if (!success) {
            [weakSelf stopLivePusher];
        }
    }];
}

- (void)finishLive:(void (^)(BOOL))completed {
    [self.liveService finishLive:completed];
}

- (void)prepareLivePusher {
    [self.displayLayoutView addDisplayView:self.livePusher.displayView];
    [self.displayLayoutView layoutAll];
    [self.livePusher prepare];
}

- (void)startLivePusher {
    [self.livePusher start];
    self.isLiving = YES;
}

- (void)stopLivePusher {
    [self.livePusher stop];
    self.isLiving = NO;
}

- (void)destoryLivePusher {
    [self.displayLayoutView removeDisplayView:self.livePusher.displayView];
    [self.displayLayoutView layoutAll];
    [self.livePusher destory];
    self.livePusher = nil;
    self.isLiving = NO;
}

- (void (^)(BOOL))onReceivedMuteAll {
    return self.liveService.onReceivedMuteAll;
}

- (void)setOnReceivedMuteAll:(void (^)(BOOL))onReceivedMuteAll {
    self.liveService.onReceivedMuteAll = onReceivedMuteAll;
}

- (BOOL)isMuteAll {
    return self.liveService.isMuteAll;
}

- (void)muteAll:(void (^)(BOOL))completed {
    [self.liveService muteAll:completed];
}

- (void)cancelMuteAll:(void (^)(BOOL))completed {
    [self.liveService cancelMuteAll:completed];
}

- (void (^)(AUIRoomUser * _Nonnull, NSString * _Nonnull))onReceivedComment {
    return self.liveService.onReceivedComment;
}

- (void)setOnReceivedComment:(void (^)(AUIRoomUser * _Nonnull, NSString * _Nonnull))onReceivedComment {
    self.liveService.onReceivedComment = onReceivedComment;
}

- (void)sendComment:(NSString *)comment completed:(void (^)(BOOL))completed {
    [self.liveService sendComment:comment completed:completed];
}

- (void (^)(AUIRoomUser * _Nonnull, NSInteger))onReceivedLike {
    return self.liveService.onReceivedLike;
}

- (void)setOnReceivedLike:(void (^)(AUIRoomUser * _Nonnull, NSInteger))onReceivedLike {
    self.liveService.onReceivedLike = onReceivedLike;
}

- (void (^)(NSInteger))onReceivedPV {
    return self.liveService.onReceivedPV;
}

- (void)setOnReceivedPV:(void (^)(NSInteger))onReceivedPV {
    self.liveService.onReceivedPV = onReceivedPV;
}

- (NSInteger)pv {
    return self.liveService.pv;
}

- (NSString *)notice {
    return self.liveService.notice;
}

- (void)updateNotice:(NSString *)notice completed:(void (^)(BOOL))completed {
    [self.liveService updateNotice:notice completed:completed];
}

- (void (^)(AUIRoomUser * _Nonnull, AUIRoomGiftModel * _Nonnull))onReceivedGift {
    return self.liveService.onReceivedGift;
}

- (void)setOnReceivedGift:(void (^)(AUIRoomUser * _Nonnull, AUIRoomGiftModel * _Nonnull))onReceivedGift {
    self.liveService.onReceivedGift = onReceivedGift;
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

- (BOOL)isMirror {
    return self.livePusher.isMirror;
}

- (void)openLivePusherMic:(BOOL)open {
    [self.livePusher mute:!open];
}

- (void)openLivePusherCamera:(BOOL)open {
    [self.livePusher pause:!open];
}

- (void)switchLivePusherCamera {
    [self.livePusher switchCamera];
}

- (void)openLivePusherMirror:(BOOL)mirror {
    [self.livePusher mirror:mirror];
}

- (void)openBeautyPanel {
    [self.livePusher.beautyController showPanel:YES];
}

@end

