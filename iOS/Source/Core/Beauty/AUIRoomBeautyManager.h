//
//  AUIRoomBeautyManager.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/3.
//

#import <UIKit/UIKit.h>
#import "AUIRoomBeautyControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomBeautyManager : NSObject

+ (void)registerBeautyEngine;
+ (id<AUIRoomBeautyControllerProtocol>)createController:(UIView *)presentView contextMode:(BOOL)contextMode;
+ (void)checkResourceWithCurrentView:(UIView *)view completed:(void (^)(BOOL completed))completed;

@end

NS_ASSUME_NONNULL_END
