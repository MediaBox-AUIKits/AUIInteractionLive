//
//  AUIRoomBaseLiveManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/28.
//

#import "AUIRoomBaseLiveManagerAudience+Private.h"


@implementation AUIRoomBaseLiveManagerAudience

@synthesize displayLayoutView;
@synthesize onReceivedStartLive;
@synthesize onReceivedStopLive;
@synthesize onReceivedLeaveRoom;
@synthesize roomVC;

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
    self.liveService.onReceivedStartLive = ^(AUIRoomUser * _Nonnull sender) {
        [weakSelf.liveService.liveInfoModel updateStatus:AUIRoomLiveStatusLiving];
        [weakSelf preparePullPlayer];
        [weakSelf startPullPlayer];
        if (weakSelf.onReceivedStartLive) {
            weakSelf.onReceivedStartLive();
        }
    };
    self.liveService.onReceivedStopLive = ^(AUIRoomUser * _Nonnull sender) {
        [weakSelf.liveService.liveInfoModel updateStatus:AUIRoomLiveStatusFinished];
        [weakSelf destoryPullPlayer];
        if (weakSelf.onReceivedStopLive) {
            weakSelf.onReceivedStopLive();
        }
    };
    
    self.liveService.onReceivedLeaveRoom = ^{
        [weakSelf destoryPullPlayer];
        if (weakSelf.onReceivedLeaveRoom) {
            weakSelf.onReceivedLeaveRoom();
        }
    };
}

- (void)setupPullPlayer:(BOOL)scaleAspectFit {
    self.cdnPull = [[AUIRoomLiveCdnPlayer alloc] init];
    self.cdnPull.scaleAspectFit = scaleAspectFit;
    self.cdnPull.liveInfoModel = self.liveService.liveInfoModel;
    self.isLiving = NO;
}

- (BOOL)pause:(BOOL)pause {
    if (!pause && self.cdnPull.playOnError) {
        [self.cdnPull destory];
        [self.cdnPull prepare];
        [self.cdnPull start];
        return NO;
    }
    return [self.cdnPull pause:pause];
}

- (void)enterRoom:(void (^)(BOOL))completed {
    __weak typeof(self) weakSelf = self;
    [self.liveService enterRoom:^(BOOL success) {
        if (completed) {
            completed(success);
        }
        if (success) {
            [weakSelf.liveService queryMuteAll:^(BOOL success) {
                if (weakSelf.onReceivedMuteAll) {
                    weakSelf.onReceivedMuteAll(weakSelf.liveService.isMuteAll);
                }
            }];
                        
            if (weakSelf.liveService.liveInfoModel.status == AUIRoomLiveStatusNone) {
            }
            else if (weakSelf.liveService.liveInfoModel.status == AUIRoomLiveStatusLiving) {
                [weakSelf preparePullPlayer];
                [weakSelf startPullPlayer];
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
    [self destoryPullPlayer];
    [self.liveService leaveRoom:completed];
}

- (void)preparePullPlayer {
    [self.displayLayoutView addDisplayView:self.cdnPull.displayView];
    [self.displayLayoutView layoutAll];
    [self.cdnPull prepare];
}

- (void)startPullPlayer {
    [self.cdnPull start];
    self.isLiving = YES;
}

- (void)destoryPullPlayer {
    [self.displayLayoutView removeDisplayView:self.cdnPull.displayView];
    [self.displayLayoutView layoutAll];
    [self.cdnPull destory];
    self.cdnPull = nil;
    
    self.isLiving = NO;
    [self.cdnPull.displayView endLoading];
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

- (void)sendLike {
    [self.liveService sendLike];
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

- (void (^)(NSString * _Nonnull))onReceivedNoticeUpdate {
    return self.liveService.onReceivedNoticeUpdate;
}

- (void)setOnReceivedNoticeUpdate:(void (^)(NSString * _Nonnull))onReceivedNoticeUpdate {
    self.liveService.onReceivedNoticeUpdate = onReceivedNoticeUpdate;
}

- (NSString *)notice {
    return self.liveService.notice;
}

- (void (^)(AUIRoomUser * _Nonnull, AUIRoomGiftModel * _Nonnull, NSInteger))onReceivedGift {
    return self.liveService.onReceivedGift;
}

- (void)setOnReceivedGift:(void (^)(AUIRoomUser * _Nonnull, AUIRoomGiftModel * _Nonnull, NSInteger))onReceivedGift {
    self.liveService.onReceivedGift = onReceivedGift;
}

- (void)sendGift:(AUIRoomGiftModel *)gift completed:(void (^)(BOOL))completed {
    [self.liveService sendGift:gift completed:completed];
}

- (void (^)(AUIRoomUser * _Nonnull, AUIRoomProductModel * _Nonnull))onReceivedProduct {
    return self.liveService.onReceivedProduct;
}

- (void)setOnReceivedProduct:(void (^)(AUIRoomUser * _Nonnull, AUIRoomProductModel * _Nonnull))onReceivedProduct {
    self.liveService.onReceivedProduct = onReceivedProduct;
}

@end
