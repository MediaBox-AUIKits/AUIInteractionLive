//
//  AUIRoomLivePusher.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/24.
//

#import "AUIRoomLivePusher.h"
#import "AUIRoomSDKHeader.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"
#import "AUIRoomAccount.h"

@interface AUIRoomLivePusher () <
AlivcLivePusherErrorDelegate,
AlivcLivePusherInfoDelegate,
AlivcLivePusherNetworkDelegate,
AlivcLivePusherCustomFilterDelegate,
AlivcLivePusherCustomDetectorDelegate
>

@property (strong, nonatomic) AlivcLivePushConfig *pushConfig;
@property (strong, nonatomic) AlivcLivePusher *pushEngine;

@end

@implementation AUIRoomLivePusher

@synthesize displayView = _displayView;

static BOOL g_canRtsPush = YES;
+ (BOOL)canRtsPush {
    return g_canRtsPush;
}

+ (void)setCanRtsPush:(BOOL)canRtsPush {
    g_canRtsPush = canRtsPush;
}

static AlivcLivePushFPS g_pushFPS = AlivcLivePushFPS20;
+ (AlivcLivePushFPS)pushFPS {
    return g_pushFPS;
}

+ (void)setPushFPS:(AlivcLivePushFPS)pushFPS {
    g_pushFPS = pushFPS;
}

- (void)dealloc {
    NSLog(@"dealloc:AUILiveRoomPusher");
}

- (AUIRoomDisplayView *)displayView {
    if (!_displayView) {
        _displayView = [[AUIRoomDisplayView alloc] initWithFrame:CGRectZero];
        _displayView.nickName = @"我";
        _displayView.isAnchor = [self.liveInfoModel.anchor_id isEqualToString:AUIRoomAccount.me.userId];
    }
    return _displayView;
}

+ (UIImage *)pushBlackImage {
    return [UIImage av_imageWithColor:UIColor.blackColor size:CGSizeMake(720, 1280)];
}

+ (UIImage *)pushPauseImage {
    return AUIRoomGetCommonImage(@"ic_push_default.jpg");
}

#pragma mark - live pusher

- (void)prepare {
    
    AlivcLivePushMode pushMode = AlivcLivePushBasicMode;
    AlivcPusherPreviewDisplayMode displayMode = ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FILL;
    if (self.liveInfoModel.mode == AUIRoomLiveModeLinkMic) {
        pushMode = AlivcLivePushInteractiveMode;
    }
    
    AlivcLivePushConfig *pushConfig = [[AlivcLivePushConfig alloc] init];
    pushConfig.resolution = AlivcLivePushResolution720P;
    pushConfig.previewDisplayMode = displayMode;
    pushConfig.livePushMode = pushMode;
    pushConfig.h5CompatibleMode = YES;
    pushConfig.fps = [self.class pushFPS];
    pushConfig.enableAutoBitrate = true;
    pushConfig.videoEncodeGop = AlivcLivePushVideoEncodeGOP_2;
    pushConfig.connectRetryInterval = 2000;
    pushConfig.orientation = AlivcLivePushOrientationPortrait;
    pushConfig.enableAutoResolution = YES;
    pushConfig.pauseImg = [self.class pushPauseImage];
    pushConfig.businessInfo = @{@"traceId":@"aui"};
    
    self.pushConfig = pushConfig;
    
    _pushEngine = [[AlivcLivePusher alloc] initWithConfig:pushConfig];
    [_pushEngine setErrorDelegate:self];
    [_pushEngine setInfoDelegate:self];
    [_pushEngine setNetworkDelegate:self];
    [_pushEngine setCustomFilterDelegate:self];
    [_pushEngine setCustomDetectorDelegate:self];
    [_pushEngine startPreview:self.displayView.renderView];
    
    if (pushMode == AlivcLivePushInteractiveMode) {
        [_pushEngine enableAudioVolumeIndication:400 smooth:3 reportVad:1];
    }
    
#if DEBUG
//    [self switchCamera];
//    [self mute:YES];
#endif
    
    [self mute:_isMute];
    [self pause:_isPause];
}

- (void)destory {
    [_pushEngine setLiveMixTranscodingConfig:nil];
    [_pushEngine stopPush];
    [_pushEngine stopPreview];
    [_pushEngine destory];
    _pushEngine = nil;
}

- (BOOL)start {
    if (!_pushEngine) {
        return NO;
    }
    if (self.liveInfoModel.mode == AUIRoomLiveModeBase) {
        NSString *pushUrl = self.liveInfoModel.push_url_info.rtmp_url;
        if (self.class.canRtsPush && self.liveInfoModel.push_url_info.rts_url.length > 0) {
            pushUrl = self.liveInfoModel.push_url_info.rts_url;
        }
        if (pushUrl.length > 0) {
            NSLog(@"LiveEvent:%@", pushUrl);
            [_pushEngine startPushWithURL:pushUrl];
            return YES;
        }
    }
    else {
        NSString *pushUrl = self.liveInfoModel.link_info.rtc_push_url;
        if (pushUrl.length > 0) {
            NSLog(@"LiveEvent:%@", pushUrl);
            [_pushEngine startPushWithURL:pushUrl];
            return YES;
        }
    }    
    return NO;
}

- (BOOL)stop {
    if (!_pushEngine) {
        return NO;
    }
    return [_pushEngine stopPush];
}

- (void)restart {
    if (!_pushEngine) {
        return;
    }
    [_pushEngine reconnectPushAsync];
    [self.displayView startLoading];
}

- (void)pause:(BOOL)pause {
    if (!_pushEngine) {
        return;
    }
    if (pause) {
        int ret = [_pushEngine pause];
        if (ret == 0) {
            _isPause = YES;
        }
    }
    else {
        int ret = [_pushEngine resume];
        if (ret == 0) {
            _isPause = NO;
        }
    }
}

- (void)mute:(BOOL)mute {
    if (!_pushEngine) {
        return;
    }
    [_pushEngine setMute:mute];
    _isMute = mute;
}

- (void)switchCamera {
    if (!_pushEngine) {
        return;
    }
    int ret = [_pushEngine switchCamera];
    if (ret == 0) {
        _isBackCamera = !_isBackCamera;
        [self mirror:_isMirror]; // 重置镜像
    }
}

- (void)mirror:(BOOL)mirror {
    if (!_pushEngine) {
        return;
    }
    if (self.liveInfoModel.mode == AUIRoomLiveModeLinkMic) {
        // 互动模式
        if (_isBackCamera) {
            // 后置摄像头
            [_pushEngine setPreviewMirror:mirror];
            [_pushEngine setPushMirror:mirror];
        }
        else {
            // 前置摄像头
            [_pushEngine setPreviewMirror:!mirror];
            [_pushEngine setPushMirror:mirror];
        }
    }
    else {
        // 普通模式
        [_pushEngine setPreviewMirror:mirror];
        [_pushEngine setPushMirror:mirror];
    }
    _isMirror = mirror;
}

- (void)setLiveMixTranscodingConfig:(AlivcLiveTranscodingConfig *)liveTranscodingConfig {
    [_pushEngine setLiveMixTranscodingConfig:liveTranscodingConfig];
}

#pragma mark - AlivcLivePusherInfoDelegate
- (void)onPreviewStarted:(AlivcLivePusher *)pusher {
    [self.beautyController setupPanelController];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onPreviewStarted");
    });
}

- (void)onPreviewStoped:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onPreviewStoped");
    });
}

- (void)onFirstFramePreviewed:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onFirstFramePreviewed");
    });
}

- (void)onFirstFramePushed:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onFirstFramePushed");
    });
}

- (void)onPushStarted:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onPushStarted");
        if (self.onStartedBlock) {
            self.onStartedBlock();
        }
    });
}

- (void)onPushPaused:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onPushPaused");
        if (self.onPausedBlock) {
            self.onPausedBlock();
        }
    });
}

- (void)onPushResumed:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onPushResumed");
        if (self.onResumedBlock) {
            self.onResumedBlock();
        }
    });
}

- (void)onPushRestart:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onPushRestart");
        if (self.onRestartBlock) {
            self.onRestartBlock();
        }
    });
}

- (void)onPushStoped:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onPushStoped");
    });
}

- (void)onPushStatistics:(AlivcLivePusher *)pusher statsInfo:(AlivcLivePushStatsInfo*)statistics {
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"LiveEvent:onPushStatistics");
    });
}

- (void)onMicrophoneVolumeUpdate:(AlivcLivePusher *)pusher volume:(int)volume {
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"LiveEvent:onPlayoutVolumeUpdate volume:%d", volume);
    });
}

#pragma mark - AlivcLivePusherErrorDelegate

- (void)onSystemError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onSystemError");
        [self.displayView endLoading];
        if (self.onConnectErrorBlock) {
            self.onConnectErrorBlock();
        }
    });
}

- (void)onSDKError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onSDKError");
        [self.displayView endLoading];
        if (self.onConnectErrorBlock) {
            self.onConnectErrorBlock();
        }
    });
}

#pragma mark - AlivcLivePusherNetworkDelegate
- (void)onNetworkPoor:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onNetworkPoor");
        if (self.onConnectionPoorBlock) {
            self.onConnectionPoorBlock();
        }
    });
}


- (void)onConnectionLost:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onConnectionLost");
        if (self.onConnectionLostBlock) {
            self.onConnectionLostBlock();
        }
    });
}

- (void)onConnectRecovery:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onConnectRecovery");
        if (self.onConnectionRecoveryBlock) {
            self.onConnectionRecoveryBlock();
        }
    });
}


- (void)onConnectFail:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onConnectFail");
        [self.displayView endLoading];
        if (self.onConnectErrorBlock) {
            self.onConnectErrorBlock();
        }
        [AVAlertController showWithTitle:nil message:@"直播中断，您可以检查网络连接后再次直播" cancelTitle:@"取消" okTitle:@"重试" onCompleted:^(BOOL isCancel) {
            if (!isCancel) {
                [self restart];
            }
        }];
    });
}

- (void)onReconnectStart:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onReconnectStart");
        [self.displayView startLoading];
        if (self.onReconnectStartBlock) {
            self.onReconnectStartBlock();
        }
    });
}

- (void)onReconnectSuccess:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onReconnectSuccess");
        [self.displayView endLoading];
        if (self.onReconnectSuccessBlock) {
            self.onReconnectSuccessBlock();
        }
    });
}

- (void)onReconnectError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onReconnectError");
        [self.displayView endLoading];
        if (self.onReconnectErrorBlock) {
            self.onReconnectErrorBlock();
        }
        [AVAlertController showWithTitle:nil message:@"直播中断，您可以检查网络连接后再次直播" cancelTitle:@"取消" okTitle:@"重试" onCompleted:^(BOOL isCancel) {
            if (!isCancel) {
                [self restart];
            }
        }];
    });
}

- (void)onSendDataTimeout:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onSendDataTimeout");
    });
}

- (NSString *)onPushURLAuthenticationOverdue:(AlivcLivePusher *)pusher {
    return @"";
}

- (void)onSendSeiMessage:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onSendSeiMessage");
    });
}

- (void)onPushURLTokenExpired:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onPushURLTokenExpired");
    });
}


- (void)onPushURLTokenWillExpire:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onPushURLTokenWillExpire");
    });
}

- (void)onPusherNetworkQualityChanged:(AlivcLivePusher *)pusher upNetworkQuality:(AlivcLiveNetworkQuality)upQuality downNetworkQuality:(AlivcLiveNetworkQuality)downQuality {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onPusherNetworkQualityChanged upQuality:%zd downQuality:%zd", upQuality, downQuality);
    });
}

- (void)onConnectionStatusChange:(AlivcLivePusher *)pusher connectionStatus:(AliLiveConnectionStatus)status reason:(AliLiveConnectionStatusChangeReason)reason { 
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onConnectionStatusChange");
    });
}


- (void)onLastmileDetectResultWithBandWidth:(AlivcLivePusher *)pusher code:(int)code result:(AliLiveNetworkQualityProbeResult * _Nonnull)result { 
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onLastmileDetectResultWithBandWidth");
    });
}


- (void)onLastmileDetectResultWithQuality:(AlivcLivePusher *)pusher networkQuality:(AlivcLiveNetworkQuality)networkQuality { 
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onLastmileDetectResultWithQuality");
    });
}


#pragma mark - AlivcLivePusherCustomFilterDelegate

- (void)onCreate:(AlivcLivePusher *)pusher context:(void*)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onCreate");
    });
}

- (int)onProcess:(AlivcLivePusher *)pusher texture:(int)texture textureWidth:(int)width textureHeight:(int)height extra:(long)extra {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"LiveEvent:onProcess");
//    });
    if (self.beautyController) {
        return [self.beautyController processGLTextureWithTextureID:texture withWidth:width withHeight:height];
    }
    return texture;
}

- (BOOL)onProcessVideoSampleBuffer:(AlivcLivePusher *)pusher sampleBuffer:(AlivcLiveVideoDataSample *)sampleBuffer {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"LiveEvent:onProcessVideoSampleBuffer");
//    });
    if (self.beautyController) {
        return [self.beautyController processPixelBuffer:sampleBuffer.pixelBuffer withPushOrientation:self.pushConfig.orientation];
    }
    
    return NO;
}

- (void)onDestory:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onDestory");
    });
    [self.beautyController destroyEngine];
}

#pragma mark - AlivcLivePusherCustomDetectorDelegate

- (void)onCreateDetector:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onCreateDetector");
    });
}

- (long)onDetectorProcess:(AlivcLivePusher *)pusher data:(long)data w:(int)w h:(int)h rotation:(int)rotation format:(int)format extra:(long)extra {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"LiveEvent:onDetectorProcess");
//    });
    [self.beautyController detectVideoBuffer:data
                                   withWidth:w
                                  withHeight:h
                             withVideoFormat:self.pushConfig.externVideoFormat
                         withPushOrientation:self.pushConfig.orientation];
    return data;
}

- (void)onDestoryDetector:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onDestoryDetector");
    });
}


@end
