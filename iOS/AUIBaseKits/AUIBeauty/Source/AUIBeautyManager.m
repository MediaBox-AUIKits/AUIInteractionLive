//
//  AUIBeautyManager.m
//  AUIBeauty
//
//  Created by Bingo on 2023/11/24.
//

#import "AUIBeautyManager.h"
#import "AUIBeautyResourceProtocol.h"

#ifdef ENABLE_QUEEN
#import "AUIBeautyQueenController.h"
#endif

#ifdef ENABLE_QUEEN_PRO
#import "AUIBeautyQueenResource.h"
#endif

@interface AUIBeautyManager ()

@end

@implementation AUIBeautyManager

+ (id<AUIBeautyControllerProtocol>)createController:(UIView *)presentView processMode:(AUIBeautyProcessMode)processMode {
#ifdef ENABLE_QUEEN
    return [[AUIBeautyQueenController alloc] initWithPresentView:presentView processMode:processMode];
#else
    return nil;
#endif
}

static id<AUIBeautyResourceProtocol> g_resource = nil;
+ (id<AUIBeautyResourceProtocol>)resourceChecker {
    if (!g_resource) {
#ifdef ENABLE_QUEEN_PRO
        g_resource = [AUIBeautyQueenResource new];
#endif
    }
    return g_resource;
}

@end
