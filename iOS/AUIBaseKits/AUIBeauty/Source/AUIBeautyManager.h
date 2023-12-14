//
//  AUIBeautyManager.h
//  AUIBeauty
//
//  Created by Bingo on 2023/11/24.
//

#import "AUIBeautyControllerProtocol.h"
#import "AUIBeautyResourceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIBeautyManager : NSObject

+ (nullable id<AUIBeautyControllerProtocol>)createController:(UIView *)presentView processMode:(AUIBeautyProcessMode)processMode;
+ (nullable id<AUIBeautyResourceProtocol>)resourceChecker;

@end

NS_ASSUME_NONNULL_END
