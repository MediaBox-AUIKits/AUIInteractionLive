//
//  AUIRoomBeautyResourceProtocol.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/20.
//

#import <UIKit/UIKit.h>
#import "AUIRoomSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AUIRoomBeautyResourceProtocol <NSObject>

@property (nonatomic, copy) void (^checkResult)(BOOL completed);
- (void)startCheckWithCurrentView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
