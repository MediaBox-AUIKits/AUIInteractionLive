//
//  AUIBeautyQueenController.m
//  AUIBeauty
//
//  Created by Bingo on 2023/11/24.
//

#ifdef ENABLE_QUEEN

#import "AUIBeautyQueenController.h"
#import "AUIBeautyQueenHeader.h"
#import <AliyunQueenUIKit/AliyunQueenUIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface AUIBeautyQueenController () <AUIBeautyProcessTextureProtocol, AUIBeautyProcessPixelBufferProtocol, AUIBeautyProcessPixelBufferAutoAngleProtocol>

@property (nonatomic, strong) QueenEngine *beautyEngine;
@property (nonatomic, strong) AliyunQueenPanelController *beautyPanelController;

@property (nonatomic, strong) UIView *presentView;
@property (nonatomic, assign) AUIBeautyProcessMode processMode;

@end

@implementation AUIBeautyQueenController

- (instancetype)initWithPresentView:(UIView *)presentView processMode:(AUIBeautyProcessMode)processMode {
    self = [super init];
    if (self) {
        self.presentView = presentView;
        self.processMode = processMode;
        if (self.processMode == AUIBeautyProcessModeTexture | self.processMode == AUIBeautyProcessModePixelBuffer) {
            [self.class setupMotionManager];
        }
    }
    return self;
}

- (void)createPanelController {
    self.beautyPanelController = [[AliyunQueenPanelController alloc] initWithParentView:self.presentView];
    self.beautyPanelController.queenEngine = _beautyEngine;
    [self.beautyPanelController selectDefaultBeautyEffect];
}

- (void)updatePanelController {
    self.beautyPanelController.queenEngine = _beautyEngine;
    [self.beautyPanelController selectCurrentBeautyEffect];
}

- (void)setupPanelController {
    if (NSThread.isMainThread) {
        if (self.beautyPanelController) {
            return;
        }
        
        [self createEngine];
        [self createPanelController];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupPanelController];
        });
    }
}

- (void)showPanel:(BOOL)animated {
    if (NSThread.isMainThread) {
        [self.beautyPanelController selectCurrentBeautyEffect];
        [self.beautyPanelController showPanel:animated];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showPanel:animated];
        });
    }
    
}

- (void)createEngine {
    @synchronized (self) {
        if (self.beautyEngine) {
            return;
        }
        
        BOOL contextMode = self.processMode != AUIBeautyProcessModeTexture;
        BOOL autoSettingImgAngle = self.processMode == AUIBeautyProcessModePixelBufferAutoAngle;
        BOOL runOnCustomThread = self.processMode != AUIBeautyProcessModePixelBufferAutoAngle;

        QueenEngineConfigInfo *configInfo = [[QueenEngineConfigInfo alloc] init];
        configInfo.withContext = contextMode;
        configInfo.autoSettingImgAngle = autoSettingImgAngle;
        configInfo.runOnCustomThread = runOnCustomThread;
        self.beautyEngine = [[QueenEngine alloc] initWithConfigInfo:configInfo];
    }
    
    if (NSThread.isMainThread) {
        if (self.beautyPanelController) {
            [self updatePanelController];
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.beautyPanelController) {
                [self updatePanelController];
            }
        });
    }
}

- (void)destroyEngine {
    @synchronized (self) {
        if (self.beautyEngine) {
            [self.beautyEngine destroyEngine];
            self.beautyEngine = nil;
        }
    }
}

#pragma mark - 模式1
- (id<AUIBeautyProcessTextureProtocol>)processTexture {
    if (self.processMode == AUIBeautyProcessModeTexture) {
        return self;
    }
    return nil;
}

- (void)detectVideoBuffer:(long)buffer withWidth:(int)width withHeight:(int)height withVideoFormat:(int)imageFormat withOrientation:(int)orientation {
    if (!self.beautyEngine) {
        return;
    }
    if (self.processMode != AUIBeautyProcessModeTexture) {
        return;
    }
    
    int screenRotation = 0;
    if (orientation == 1) {
        screenRotation = -90;
    }
    else if (orientation == 2) {
        screenRotation = 90;
    }
    
    @synchronized (self) {
        [self.beautyEngine updateInputDataAndRunAlg:(uint8_t*)buffer
                                      withImgFormat:(kQueenImageFormat)imageFormat
                                          withWidth:width
                                         withHeight:height
                                         withStride:0
                                     withInputAngle:(g_screenRotation + screenRotation + 360) % 360
                                    withOutputAngle:(g_screenRotation + screenRotation + 360) % 360
                                       withFlipAxis:0];
    }
}

- (int)processGLTextureWithTextureID:(int)textureID withWidth:(int)width withHeight:(int)height {
    if (!self.beautyEngine) {
        return textureID;
    }
    
    if (self.processMode != AUIBeautyProcessModeTexture) {
        return textureID;
    }

    QETextureData* textureData = [[QETextureData alloc] init];
    textureData.inputTextureID = textureID;
    textureData.width = width;
    textureData.height = height;
    kQueenResultCode result = kQueenResultCodeUnKnown;
    @synchronized (self) {
        result = [self.beautyEngine processTexture:textureData];
    }
    [self checkProcessResult:result];
    if (result != kQueenResultCodeOK) {
        return textureID;
    }
    return textureData.outputTextureID;
}


#pragma mark - 模式2

- (id<AUIBeautyProcessPixelBufferProtocol>)processPixelBuffer {
    if (self.processMode == AUIBeautyProcessModePixelBuffer) {
        return self;
    }
    return nil;
}

- (BOOL)processPixelBuffer:(CVPixelBufferRef)pixelBufferRef withOrientation:(int)orientation {
    if (!self.beautyEngine) {
        return NO;
    }
    
    if (self.processMode != AUIBeautyProcessModePixelBuffer) {
        return NO;
    }

    if (pixelBufferRef) {
        int screenRotation = 0;
        if (orientation == 1) {
            screenRotation = 90;
        }
        else if (orientation == 2) {
            screenRotation = -90;
        }

        int motionScreenRotation = g_screenRotation;
//        if (g_screenRotation == 90) {
//            motionScreenRotation = 270;
//        }
//        else if (g_screenRotation == 270) {
//            motionScreenRotation = 90;
//        }
        int angle = (motionScreenRotation + screenRotation + 360) % 360;

        QEPixelBufferData *bufferData = [QEPixelBufferData new];
        bufferData.bufferIn = bufferData.bufferOut = pixelBufferRef;
        bufferData.inputAngle = bufferData.outputAngle = angle;
        kQueenResultCode result = kQueenResultCodeUnKnown;
        @synchronized (self) {
            result = [self.beautyEngine processPixelBuffer:bufferData];
        }
        [self checkProcessResult:result];
        if (result == kQueenResultCodeOK) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 模式3

- (id<AUIBeautyProcessPixelBufferAutoAngleProtocol>)processPixelBufferAutoAngle {
    if (self.processMode == AUIBeautyProcessModePixelBufferAutoAngle) {
        return self;
    }
    return nil;
}

- (BOOL)processPixelBuffer:(CVPixelBufferRef)pixelBufferRef {
    if (!self.beautyEngine) {
        return NO;
    }
    
    if (self.processMode != AUIBeautyProcessModePixelBufferAutoAngle) {
        return NO;
    }

    if (pixelBufferRef) {
        QEPixelBufferData *bufferData = [QEPixelBufferData new];
        bufferData.bufferIn = bufferData.bufferOut = pixelBufferRef;
        kQueenResultCode result = kQueenResultCodeUnKnown;
        @synchronized (self) {
            result = [self.beautyEngine processPixelBuffer:bufferData];
        }
        [self checkProcessResult:result];
        if (result == kQueenResultCodeOK) {
            return YES;
        }
    }
    return NO;
}

- (void)checkProcessResult:(kQueenResultCode)resultCode {
    if (resultCode == kQueenResultCodeOK) {
        // 正常
    }
    else if (resultCode == kQueenResultCodeInvalidLicense) {
        NSLog(@"============== queen license校验失败 ==============");
    }
    else if (resultCode == kQueenResultCodeInvalidParam) {
        NSLog(@"============== queen 非法参数 ============== ");
    }
    else if (resultCode == kQueenResultCodeNoEffect) {
//        NSLog(@"============== queen 没有开启任何特效 ============== ");
    }
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

+ (void)destroyMotionManager {
    if (g_motionManager) {
        [g_motionManager stopAccelerometerUpdates];
        g_motionManager = nil;
    }
    g_screenRotation = 0;
}


@end

#endif
