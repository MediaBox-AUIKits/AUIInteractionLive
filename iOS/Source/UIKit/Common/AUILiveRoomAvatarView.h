//
//  AUILiveRoomAvatarView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/8.
//

#import <UIKit/UIKit.h>
#import "AUIRoomUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomAvatarView : UIView

@property (nonatomic, strong, readonly) UIImageView *iconView;

@property (nonatomic, strong) AUIRoomUser *user;

@end

NS_ASSUME_NONNULL_END
