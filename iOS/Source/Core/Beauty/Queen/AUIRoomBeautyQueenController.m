//
//  AUIRoomBeautyQueenController.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/4.
//

#ifndef DISABLE_QUEEN

#import "AUIRoomBeautyQueenController.h"
#import <AliyunQueenUIKit/AliyunQueenUIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface AUIRoomBeautyQueenController ()

@property (nonatomic, strong) QueenEngine *beautyEngine;
@property (nonatomic, strong) AliyunQueenPanelController *beautyPanelController;

@property (nonatomic, strong) UIView *presentView;
@property (nonatomic, assign) BOOL contextMode;

@end

@implementation AUIRoomBeautyQueenController

- (instancetype)initWithPresentView:(UIView *)presentView contextMode:(BOOL)contextMode {
    self = [super init];
    if (self) {
        self.presentView = presentView;
        self.contextMode = contextMode;
    }
    return self;
}

- (void)setupBeautyController {
    @synchronized (self) {
        if (self.beautyEngine) {
            return;
        }
        
        QueenEngineConfigInfo *configInfo = [[QueenEngineConfigInfo alloc] init];
        configInfo.withContext = self.contextMode;
        configInfo.autoSettingImgAngle = NO;
        self.beautyEngine = [[QueenEngine alloc] initWithConfigInfo:configInfo];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.beautyPanelController = [[AliyunQueenPanelController alloc] initWithParentView:self.presentView];
            self.beautyPanelController.queenEngine = self.beautyEngine;
            [self.beautyPanelController selectDefaultBeautyEffect];
        });
    }
}

- (void)destroyBeautyController {
    @synchronized (self)
    {
        if (self.beautyEngine) {
            [self.beautyEngine destroyEngine];
            self.beautyEngine = nil;
        }
    }
}

- (void)detectVideoBuffer:(long)buffer withWidth:(int)width withHeight:(int)height withVideoFormat:(AlivcLivePushVideoFormat)videoFormat withPushOrientation:(AlivcLivePushOrientation)pushOrientation {
    if (!self.beautyEngine) {
        return;
    }
    
    int screenRotation = 0;
    if (pushOrientation == AlivcLivePushOrientationLandscapeLeft) {
        screenRotation = -90;
    }
    else if (pushOrientation == AlivcLivePushOrientationLandscapeRight) {
        screenRotation = 90;
    }
    
    kQueenImageFormat imageFormat = kQueenImageFormatNV12;
    switch (videoFormat) {
        case AlivcLivePushVideoFormatRGB:
            imageFormat = kQueenImageFormatRGB;
            break;
        case AlivcLivePushVideoFormatRGBA:
            imageFormat = kQueenImageFormatRGBA;
            break;
        case AlivcLivePushVideoFormatYUVNV21:
            imageFormat = kQueenImageFormatNV21;
            break;
        case AlivcLivePushVideoFormatYUVYV12:
        case AlivcLivePushVideoFormatYUVNV12:
            break;
        default:
            NSAssert(false, @"Invalid Image Format For Beauty.");
            break;
    }
    
    @synchronized (self) {
        [self.beautyEngine updateInputDataAndRunAlg:(uint8_t*)buffer
                                      withImgFormat:imageFormat
                                          withWidth:width
                                         withHeight:height
                                         withStride:0
                                     withInputAngle:(g_screenRotation + screenRotation + 360) % 360
                                    withOutputAngle:(g_screenRotation + screenRotation + 360) % 360
                                       withFlipAxis:0];
    }
}

- (int)processGLTextureWithTextureID:(int)textureID withWidth:(int)width withHeight:(int)height {
    if (!self.beautyEngine && self.contextMode) {
        return textureID;
    }

    @synchronized (self) {
        QETextureData* textureData = [[QETextureData alloc] init];
        textureData.inputTextureID = textureID;
        textureData.width = width;
        textureData.height = height;
        kQueenResultCode result = [self.beautyEngine processTexture:textureData];
        if (result != kQueenResultCodeOK) {
            return textureID;
        }
        return textureData.outputTextureID;
    }
}

- (BOOL)processPixelBuffer:(CVPixelBufferRef)pixelBufferRef withPushOrientation:(AlivcLivePushOrientation)pushOrientation {
    if (!self.beautyEngine && !self.contextMode) {
        return NO;
    }

    if (pixelBufferRef) {
        int screenRotation = 0;
        if (pushOrientation == AlivcLivePushOrientationLandscapeLeft) {
            screenRotation = 90;
        }
        else if (pushOrientation == AlivcLivePushOrientationLandscapeRight) {
            screenRotation = -90;
        }

        int motionScreenRotation = g_screenRotation;
        if (g_screenRotation == 90) {
            motionScreenRotation = 270;
        }
        else if (g_screenRotation == 270) {
            motionScreenRotation = 90;
        }
        int angle = (motionScreenRotation + screenRotation + 360) % 360;

        QEPixelBufferData *bufferData = [QEPixelBufferData new];
        bufferData.bufferIn = bufferData.bufferOut = pixelBufferRef;
        bufferData.inputAngle = bufferData.outputAngle = angle;
        kQueenResultCode result = kQueenResultCodeUnKnown;
        @synchronized (self) {
            result = [self.beautyEngine processPixelBuffer:bufferData];
        }
        if (result == kQueenResultCodeOK) {
            return YES;
        }
    }
    return NO;
}

- (void)showPanel:(BOOL)animated
{
    [self.beautyPanelController selectCurrentBeautyEffect];
    [self.beautyPanelController showPanel:animated];
}

#pragma mark - Gravity Motion

static int g_screenRotation = 0;
static CMMotionManager *g_motionManager = nil;

+ (void)setupMotionManager {
    if (g_motionManager) {
        return;
    }
    g_motionManager = [[CMMotionManager alloc] init];
    if (g_motionManager.accelerometerAvailable) {
        g_motionManager.accelerometerUpdateInterval = 0.1f;
        [g_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                                 withHandler:^(CMAccelerometerData* accelerometerData, NSError* error) {
            CMAccelerometerData* newestAccel = g_motionManager.accelerometerData;
            double accelerationX = newestAccel.acceleration.x;
            double accelerationY = newestAccel.acceleration.y;
            double ra = atan2(-accelerationY, accelerationX);
            double degree = ra * 180 / M_PI;
            if (degree >= -105 && degree <= -75) {
                //NSLog(@"@keria motion: %f, 倒立", degree);
                g_screenRotation = 180;
            } else if (degree >= -15 && degree <= 15) {
                //NSLog(@"@keria motion: %f, 右转", degree);
                g_screenRotation = 90;
            } else if (degree >= 75 && degree <= 105) {
                //NSLog(@"@keria motion: %f, 正立", degree);
                g_screenRotation = 0;
            } else if (degree >= 165 || degree <= -165) {
                //NSLog(@"@keria motion: %f, 左转", degree);
                g_screenRotation = 270;
            }
        }];
    }
}

+ (void)destroyMotionManager
{
    if (g_motionManager) {
        [g_motionManager stopAccelerometerUpdates];
        g_motionManager = nil;
    }
    g_screenRotation = 0;
}


@end

#endif
