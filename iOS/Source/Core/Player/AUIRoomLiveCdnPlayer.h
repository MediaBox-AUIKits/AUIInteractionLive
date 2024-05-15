//
//  AUIRoomLiveCdnPlayer.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/25.
//

#import <UIKit/UIKit.h>
#import "AUIRoomDisplayView.h"
#import "AUIRoomLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomLiveCdnPlayer : NSObject

@property (strong, nonatomic) AUIRoomLiveInfoModel *liveInfoModel;
@property (assign, nonatomic) BOOL scaleAspectFit;

@property (strong, nonatomic, readonly) AUIRoomDisplayView *displayView;
@property (assign, nonatomic, readonly) BOOL playOnError;

@property (copy, nonatomic) void(^onPrepareStartBlock)(void);
@property (copy, nonatomic) void(^onPrepareDoneBlock)(void);
@property (copy, nonatomic) void(^onLoadingStartBlock)(void);
@property (copy, nonatomic) void(^onLoadingEndBlock)(void);
@property (copy, nonatomic) void(^onPlayErrorBlock)(void);

// 是否使用rts_url地址进行拉流，默认为YES
@property (assign, nonatomic, class) BOOL canRtsPull;

// 是否使用flv_oriaac_url地址进行拉流，默认为NO
// 符合以下条件的话，需要设置为YES
// 1、没开通rts，也就是canRtsPull设置为NO
// 2、来自web端的推流，且需要配置一个aac模板
@property (assign, nonatomic, class) BOOL canOriaccPull;

- (void)prepare;
- (BOOL)start;
- (BOOL)pause:(BOOL)pause;
- (void)destory;

@end

NS_ASSUME_NONNULL_END
