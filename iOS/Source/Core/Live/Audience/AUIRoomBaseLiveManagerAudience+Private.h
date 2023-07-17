//
//  AUIRoomBaseLiveManagerAudience+Private.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/29.
//

#import "AUIRoomBaseLiveManagerAudience.h"
#import "AUIRoomLiveService.h"
#import "AUIRoomLiveCdnPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomBaseLiveManagerAudience ()

@property (strong, nonatomic) AUIRoomLiveService *liveService;
@property (strong, nonatomic, nullable) AUIRoomLiveCdnPlayer *cdnPull;
@property (assign, nonatomic) BOOL isLiving;

- (void)setupLiveService;

- (void)preparePullPlayer;
- (void)startPullPlayer;
- (void)destoryPullPlayer;

@end

NS_ASSUME_NONNULL_END
