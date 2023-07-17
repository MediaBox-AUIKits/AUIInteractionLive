//
//  AUILiveRoomInfoView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>
#import "AUIFoundation.h"
#import "AUIRoomLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomInfoView : UIView

- (instancetype)initWithFrame:(CGRect)frame withModel:(AUIRoomLiveInfoModel *)model;

@property (copy, nonatomic) void (^onFollowButtonClickedBlock)(AUILiveRoomInfoView *sender, AVBlockButton *followButton);

@end

NS_ASSUME_NONNULL_END
