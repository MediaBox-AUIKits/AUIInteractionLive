//
//  AUIRoomLiveRtcPlayer.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/25.
//

#import <UIKit/UIKit.h>
#import "AUIRoomDisplayView.h"
#import "AUIRoomLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomLiveRtcPlayer : NSObject

@property (strong, nonatomic) AUIRoomLiveLinkMicJoinInfoModel *joinInfo;

@property (strong, nonatomic, readonly) AUIRoomDisplayView *displayView;

@property (copy, nonatomic) void(^onPlayErrorBlock)(void);

- (void)prepare;
- (BOOL)start;
- (void)destory;

@end

NS_ASSUME_NONNULL_END
