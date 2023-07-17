//
//  AUIRoomBaseLiveManagerAnchor+Private.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/4.
//

#import "AUIRoomBaseLiveManagerAnchor.h"
#import "AUIRoomLiveService.h"
#import "AUIRoomLivePusher.h"
#import "AUIRoomBeautyManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomBaseLiveManagerAnchor ()

@property (strong, nonatomic) AUIRoomLiveService *liveService;
@property (strong, nonatomic, nullable) AUIRoomLivePusher *livePusher;
@property (assign, nonatomic) BOOL isLiving;

- (void)setupLiveService;

- (void)prepareLivePusher;
- (void)startLivePusher;
- (void)stopLivePusher;
- (void)destoryLivePusher;

@end

NS_ASSUME_NONNULL_END
