//
//  AUIRoomBeautyControllerProtocol.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/20.
//

#import <UIKit/UIKit.h>
#import "AUIRoomSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AUIRoomBeautyControllerProtocol <NSObject>

// 初始化美颜控制面板，需要在主线程调用
- (void)setupPanelController;
// 创建美颜引擎
- (void)createEngine;
// 释放美颜引擎
- (void)destroyEngine;
// 显示美颜控制面板
- (void)showPanel:(BOOL)animated;

// Texture 模式处理
- (void)detectVideoBuffer:(long)buffer withWidth:(int)width withHeight:(int)height withVideoFormat:(AlivcLivePushVideoFormat)videoFormat withPushOrientation:(AlivcLivePushOrientation)pushOrientation;
- (int)processGLTextureWithTextureID:(int)textureID withWidth:(int)width withHeight:(int)height;

// PixelBuffer模式处理
- (BOOL)processPixelBuffer:(CVPixelBufferRef)pixelBufferRef withPushOrientation:(AlivcLivePushOrientation)pushOrientation;

@end

NS_ASSUME_NONNULL_END
