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

@property (assign, nonatomic, class) BOOL canRtsPull; // 是否使用rts进行拉流，默认为YES

- (void)prepare;
- (BOOL)start;
- (BOOL)pause:(BOOL)pause;
- (void)destory;

@end

NS_ASSUME_NONNULL_END
