//
//  AUIRoomGiftPlayer.h
//  AUIInteractionLiveDemo
//
//  Created by Bingo on 2024/2/28.
//

#import <UIKit/UIKit.h>
#import "AUIRoomGiftModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomGiftPlayer : UIView

- (void)play:(AUIRoomGiftModel *)model onView:(UIView *)view;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
