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

- (instancetype)initWithPresentView:(UIView *)presentView contextMode:(BOOL)contextMode;

- (void)setupBeautyController;
- (void)destroyBeautyController;

- (void)detectVideoBuffer:(long)buffer withWidth:(int)width withHeight:(int)height withVideoFormat:(AlivcLivePushVideoFormat)videoFormat withPushOrientation:(AlivcLivePushOrientation)pushOrientation;

// contextMode=NO进行处理
- (int)processGLTextureWithTextureID:(int)textureID withWidth:(int)width withHeight:(int)height;

// contextMode=YES进行处理
- (BOOL)processPixelBuffer:(CVPixelBufferRef)pixelBufferRef withPushOrientation:(AlivcLivePushOrientation)pushOrientation;

- (void)showPanel:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
