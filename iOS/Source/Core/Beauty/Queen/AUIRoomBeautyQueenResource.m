//
//  AUIRoomBeautyQueenResource.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/20.
//

#ifndef DISABLE_QUEEN

#import "AUIRoomBeautyQueenResource.h"
#import "AUIFoundation.h"
#import "AUIRoomSDKHeader.h"

@interface AUIRoomBeautyQueenResource () <QueenMaterialDelegate>

@property (nonatomic, strong) AVProgressHUD *hub;

@end

@implementation AUIRoomBeautyQueenResource

@synthesize checkResult;

+ (BOOL)requestResource {
    return [[QueenMaterial sharedInstance] requestMaterial:kQueenMaterialModel];
}

- (void)startCheckWithCurrentView:(UIView *)view {
    
    BOOL result = [self.class requestResource];
    if (!result) {
        if (self.checkResult) {
            self.checkResult(YES);
        }
    }
    else {
        [self.hub hideAnimated:NO];
        
        AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:view animated:YES];
        loading.labelText = @"正在下载美颜模型中，请等待";
        self.hub = loading;
        
        [QueenMaterial sharedInstance].delegate = self;
    }
}

#pragma mark - QueenMaterialDelegate

- (void)queenMaterialOnReady:(kQueenMaterialType)type
{
    // 资源下载成功
    if (type == kQueenMaterialModel) {
        [self.hub hideAnimated:YES];
        self.hub = nil;
        if (self.checkResult) {
            self.checkResult(YES);
        }
    }
}

- (void)queenMaterialOnProgress:(kQueenMaterialType)type withCurrentSize:(int)currentSize withTotalSize:(int)totalSize withProgess:(float)progress
{
    // 资源下载进度回调
    if (type == kQueenMaterialModel) {
        NSLog(@"====正在下载资源模型，进度：%f", progress);
    }
}

- (void)queenMaterialOnError:(kQueenMaterialType)type
{
    // 资源下载出错
    if (type == kQueenMaterialModel){
        [self.hub hideAnimated:YES];
        self.hub = nil;
        if (self.checkResult) {
            self.checkResult(NO);
        }
    }
}

@end

#endif
