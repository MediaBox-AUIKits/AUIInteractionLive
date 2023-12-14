//
//  AUIRoomBeautyManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/3.
//

#import "AUIRoomBeautyManager.h"

#ifndef DISABLE_QUEEN
#import "AUIRoomBeautyQueenController.h"
#import "AUIBeauty/AUIBeautyManager.h"
#import "AUIFoundation.h"
#endif


@interface AUIRoomBeautyManager ()

@end

@implementation AUIRoomBeautyManager

+ (void)registerBeautyEngine {
#ifndef DISABLE_QUEEN
    [[AUIBeautyManager resourceChecker] startCheck];
#endif
}

+ (id<AUIRoomBeautyControllerProtocol>)createController:(UIView *)presentView pixelBufferMode:(BOOL)pixelBufferMode {
#ifndef DISABLE_QUEEN
    return [[AUIRoomBeautyQueenController alloc] initWithPresentView:presentView pixelBufferMode:pixelBufferMode];
#else
    return nil;
#endif
}

+ (void)checkResourceWithCurrentView:(UIView *)view completed:(void (^)(BOOL completed))completed {
#ifndef DISABLE_QUEEN
    id<AUIBeautyResourceProtocol> checker = [AUIBeautyManager resourceChecker];
    if (checker) {
        AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:view animated:YES];
        loading.labelText = @"正在下载美颜模型中，请等待";
        [checker checkResource:^(BOOL result) {
            [loading hideAnimated:YES];
            if (completed) {
                completed(result);
            }
        }];
    }
    else {
        if (completed) {
            completed(YES);
        }
    }
#else
    if (completed) {
        completed(YES);
    }
#endif
}

@end
