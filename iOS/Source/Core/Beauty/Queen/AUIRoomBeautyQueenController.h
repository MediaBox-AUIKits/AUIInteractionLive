//
//  AUIRoomBeautyQueenController.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/4.
//

#ifndef DISABLE_QUEEN

#import "AUIRoomBeautyControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomBeautyQueenController : NSObject <AUIRoomBeautyControllerProtocol>

+ (void)setupMotionManager;
+ (void)destroyMotionManager;

@end

NS_ASSUME_NONNULL_END

#endif
