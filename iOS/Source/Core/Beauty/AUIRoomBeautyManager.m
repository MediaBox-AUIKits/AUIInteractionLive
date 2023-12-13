//
//  AUIRoomBeautyManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/3.
//

#import "AUIRoomBeautyManager.h"
#import "AUIRoomBeautyResourceProtocol.h"

#ifndef DISABLE_QUEEN
#import "AUIRoomBeautyQueenController.h"
#import "AUIRoomBeautyQueenResource.h"
#endif


@interface AUIRoomBeautyManager ()

@property (nonatomic, strong) id<AUIRoomBeautyResourceProtocol> resource;

@end

@implementation AUIRoomBeautyManager

+ (void)registerBeautyEngine {
#ifndef DISABLE_QUEEN
    [AUIRoomBeautyQueenResource requestResource];
    [AUIRoomBeautyQueenController setupMotionManager];
#endif
}

+ (id<AUIRoomBeautyControllerProtocol>)createController:(UIView *)presentView contextMode:(BOOL)contextMode {
#ifndef DISABLE_QUEEN
    return [[AUIRoomBeautyQueenController alloc] initWithPresentView:presentView contextMode:contextMode];
#else
    return nil;
#endif
}

static id<AUIRoomBeautyResourceProtocol> g_resource = nil;
+ (void)checkResourceWithCurrentView:(UIView *)view completed:(void (^)(BOOL completed))completed {
    if (!g_resource) {
#ifndef DISABLE_QUEEN
        g_resource = [AUIRoomBeautyQueenResource new];
#endif
    }
    if (g_resource) {
        g_resource.checkResult = completed;
        [g_resource startCheckWithCurrentView:view];
    }
    else {
        if (completed) {
            completed(YES);
        }
    }
}

@end
