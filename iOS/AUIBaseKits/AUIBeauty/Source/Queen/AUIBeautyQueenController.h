//
//  AUIBeautyQueenController.h
//  AUIBeauty
//
//  Created by Bingo on 2023/11/24.
//


#ifdef ENABLE_QUEEN

#import "AUIBeautyControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIBeautyQueenController : NSObject <AUIBeautyControllerProtocol>

+ (void)setupMotionManager;
+ (void)destroyMotionManager;

@end

NS_ASSUME_NONNULL_END

#endif
