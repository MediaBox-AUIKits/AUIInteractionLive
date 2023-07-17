//
//  AUIRoomVodPlayer.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/21.
//

#import <UIKit/UIKit.h>
#import "AUIRoomLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomVodPlayer : UIView

@property (strong, nonatomic) AUIRoomLiveVodInfoModel *vodInfoModel;
@property (assign, nonatomic) BOOL scaleAspectFit;
@property (assign, nonatomic) BOOL isFullScreen;

@property (copy, nonatomic) void(^onPrepareStartBlock)(void);
@property (copy, nonatomic) void(^onPrepareDoneBlock)(void);
@property (copy, nonatomic) void(^onLoadingStartBlock)(void);
@property (copy, nonatomic) void(^onLoadingEndBlock)(void);
@property (copy, nonatomic) void(^onPlayErrorBlock)(BOOL willRetry);

@property (copy, nonatomic) void (^onBottomViewHiddenBlock)(AUIRoomVodPlayer *sender, BOOL hidden);
@property (copy, nonatomic) void (^onFullScreenButtonClickBlock)(AUIRoomVodPlayer *sender, BOOL fullScreen);

@property (assign, nonatomic) UIEdgeInsets bottomBarEdgeInset; // 默认为(0,0,AVSafeBottom,0)

@property (assign, nonatomic) BOOL hiddenFullscreenBtn; // 默认为YES


- (void)start;
- (void)stop;


@end

NS_ASSUME_NONNULL_END
