//
//  AUIBeautyQueenResource.m
//  AUIBeauty
//
//  Created by Bingo on 2023/11/24.
//

#ifdef ENABLE_QUEEN_PRO

#import "AUIBeautyQueenResource.h"
#import "AUIBeautyQueenHeader.h"

@interface AUIBeautyQueenResource () <QueenMaterialDelegate>

@property (nonatomic, copy) void (^checkResult)(BOOL completed);

@end

@implementation AUIBeautyQueenResource

- (BOOL)startCheck {
    return [[QueenMaterial sharedInstance] requestMaterial:kQueenMaterialModel];
}

- (void)checkResource:(void (^)(BOOL))completed {
    BOOL result = [self startCheck];
    if (!result) {
        if (completed) {
            completed(YES);
        }
    }
    else {
        self.checkResult = completed;
        [QueenMaterial sharedInstance].delegate = self;
    }
}

#pragma mark - QueenMaterialDelegate

- (void)queenMaterialOnReady:(kQueenMaterialType)type {
    // 资源下载成功
    if (type == kQueenMaterialModel) {
        if (self.checkResult) {
            self.checkResult(YES);
        }
    }
}

- (void)queenMaterialOnProgress:(kQueenMaterialType)type withCurrentSize:(int)currentSize withTotalSize:(int)totalSize withProgess:(float)progress {
    // 资源下载进度回调
    if (type == kQueenMaterialModel) {
        NSLog(@"====正在下载资源模型，进度：%f", progress);
    }
}

- (void)queenMaterialOnError:(kQueenMaterialType)type {
    // 资源下载出错
    if (type == kQueenMaterialModel){
        if (self.checkResult) {
            self.checkResult(NO);
        }
    }
}

@end

#endif
