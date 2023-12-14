//
//  AUIBeautyControllerProtocol.h
//  AUIBeauty
//
//  Created by Bingo on 2023/11/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUIBeautyProcessMode) {
    AUIBeautyProcessModeTexture = 1,              // 模式1
    AUIBeautyProcessModePixelBuffer = 2,          // 模式2
    AUIBeautyProcessModePixelBufferAutoAngle = 3, // 模式3
};

// 模式1： 处理Texture
@protocol AUIBeautyProcessTextureProtocol <NSObject>

// imageFormat，参考kQueenImageFormat: 0:RGB 1:NV21  2:NV12 3:RGBA
// orientation: 0:竖屏  1:左横屏  2:右横屏
- (void)detectVideoBuffer:(long)buffer withWidth:(int)width withHeight:(int)height withVideoFormat:(int)imageFormat withOrientation:(int)orientation;

- (int)processGLTextureWithTextureID:(int)textureID withWidth:(int)width withHeight:(int)height;

@end

// 模式2： 处理PixelBuffer，
@protocol AUIBeautyProcessPixelBufferProtocol <NSObject>

// orientation: 0:竖屏  1:左横屏  2:右横屏
- (BOOL)processPixelBuffer:(CVPixelBufferRef)pixelBufferRef withOrientation:(int)orientation;

@end

// 模式3：处理PixelBuffer，使用自动角度方式
@protocol AUIBeautyProcessPixelBufferAutoAngleProtocol <NSObject>

- (BOOL)processPixelBuffer:(CVPixelBufferRef)pixelBufferRef;

@end


@protocol AUIBeautyControllerProtocol <NSObject>

- (instancetype)initWithPresentView:(UIView *)presentView processMode:(AUIBeautyProcessMode)processMode;

// 初始化美颜控制面板，需要在主线程调用
- (void)setupPanelController;
// 创建美颜引擎
- (void)createEngine;
// 释放美颜引擎
- (void)destroyEngine;
// 显示美颜控制面板
- (void)showPanel:(BOOL)animated;


// 获取美颜处理接口，processMode为AUIBeautyProcessModeTexture返回，否则返回nil
- (nullable id<AUIBeautyProcessTextureProtocol>)processTexture;

// 获取美颜处理接口，processMode为AUIBeautyProcessModePixelBuffer返回，否则返回nil
- (nullable id<AUIBeautyProcessPixelBufferProtocol>)processPixelBuffer;

// 获取美颜处理接口，processMode为AUIBeautyProcessModePixelBufferAutoAngle返回，否则返回nil
- (nullable id<AUIBeautyProcessPixelBufferAutoAngleProtocol>)processPixelBufferAutoAngle;



@end

NS_ASSUME_NONNULL_END
