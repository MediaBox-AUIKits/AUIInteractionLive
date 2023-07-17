//
//  AUILiveRoomAnchorPrestartView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>
#import "AUIRoomLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomAnchorPrestartView : UIView

@property (copy, nonatomic) void (^onBeautyBlock)(AUILiveRoomAnchorPrestartView *sender);
@property (copy, nonatomic) void (^onSwitchCameraBlock)(AUILiveRoomAnchorPrestartView *sender);
@property (copy, nonatomic) BOOL (^onWillStartLiveBlock)(AUILiveRoomAnchorPrestartView *sender);
@property (copy, nonatomic) void (^onStartLiveBlock)(AUILiveRoomAnchorPrestartView *sender);

- (instancetype)initWithFrame:(CGRect)frame withModel:(AUIRoomLiveInfoModel *)model;

- (void)restore;

@end

NS_ASSUME_NONNULL_END
