//
//  AUIRoomBeautyQueenController.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/4.
//

#import "AUIRoomBeautyQueenController.h"

#ifndef DISABLE_QUEEN

#import "AUIBeauty/AUIBeautyManager.h"

@interface AUIRoomBeautyQueenController ()

@property (nonatomic, strong) id<AUIBeautyControllerProtocol> beautyController;

@end

@implementation AUIRoomBeautyQueenController

- (nonnull instancetype)initWithPresentView:(nonnull UIView *)presentView pixelBufferMode:(BOOL)pixelBufferMode {
    self = [super init];
    if (self) {
        _beautyController = [AUIBeautyManager createController:presentView processMode:pixelBufferMode ? AUIBeautyProcessModePixelBuffer : AUIBeautyProcessModeTexture];
    }
    return self;
}

- (void)setupPanelController {
    [_beautyController setupPanelController];
}

- (void)createEngine {
    [_beautyController createEngine];
}

- (void)destroyEngine {
    [_beautyController destroyEngine];
}

- (void)showPanel:(BOOL)animated {
    [_beautyController showPanel:animated];
}


- (void)detectVideoBuffer:(long)buffer withWidth:(int)width withHeight:(int)height withVideoFormat:(AlivcLivePushVideoFormat)videoFormat withPushOrientation:(AlivcLivePushOrientation)pushOrientation {
    int imageFormat = 0;
    switch (videoFormat) {
        case AlivcLivePushVideoFormatRGB:
            imageFormat = 0;
            break;
        case AlivcLivePushVideoFormatRGBA:
            imageFormat = 3;
            break;
        case AlivcLivePushVideoFormatYUVNV21:
            imageFormat = 1;
            break;
        case AlivcLivePushVideoFormatYUVYV12:
        case AlivcLivePushVideoFormatYUVNV12:
            imageFormat = 2;
            break;
        default:
            return;
    }
    [[_beautyController processTexture] detectVideoBuffer:buffer withWidth:width withHeight:height withVideoFormat:imageFormat withOrientation:(int)pushOrientation];
}

- (int)processGLTextureWithTextureID:(int)textureID withWidth:(int)width withHeight:(int)height { 
    id<AUIBeautyProcessTextureProtocol> process = [_beautyController processTexture];
    if (process) {
        return [process processGLTextureWithTextureID:textureID withWidth:width withHeight:height];
    }
    return textureID;
}

- (BOOL)processPixelBuffer:(nonnull CVPixelBufferRef)pixelBufferRef withPushOrientation:(AlivcLivePushOrientation)pushOrientation { 
    id<AUIBeautyProcessPixelBufferProtocol> process = [_beautyController processPixelBuffer];
    if (process) {
        return [process processPixelBuffer:pixelBufferRef withOrientation:(int)pushOrientation];
    }
    return NO;
}

@end

#endif
