//
//  AUIRoomLivePusher.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/24.
//

#import <UIKit/UIKit.h>
#import "AUIRoomDisplayView.h"
#import "AUIRoomBeautyManager.h"
#import "AUIRoomLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomLivePusher : NSObject

@property (strong, nonatomic) AUIRoomLiveInfoModel *liveInfoModel;

@property (strong, nonatomic, readonly) AUIRoomDisplayView *displayView;
@property (strong, nonatomic) id<AUIRoomBeautyControllerProtocol> beautyController;

@property (copy, nonatomic) void(^onStartedBlock)(void);
@property (copy, nonatomic) void(^onPausedBlock)(void);
@property (copy, nonatomic) void(^onResumedBlock)(void);
@property (copy, nonatomic) void(^onRestartBlock)(void);

@property (copy, nonatomic) void(^onConnectionPoorBlock)(void);
@property (copy, nonatomic) void(^onConnectionLostBlock)(void);
@property (copy, nonatomic) void(^onConnectionRecoveryBlock)(void);

@property (copy, nonatomic) void(^onConnectErrorBlock)(void);

@property (copy, nonatomic) void(^onReconnectStartBlock)(void);
@property (copy, nonatomic) void(^onReconnectSuccessBlock)(void);
@property (copy, nonatomic) void(^onReconnectErrorBlock)(void);

@property (assign, nonatomic) BOOL isMute; // prepare前设置有效
@property (assign, nonatomic) BOOL isPause; // prepare前设置有效
@property (assign, nonatomic, readonly) BOOL isBackCamera;
@property (assign, nonatomic, readonly) BOOL isMirror;


@property (assign, nonatomic, class) BOOL canRtsPush; // 是否使用rts进行推送，默认为YES
@property (assign, nonatomic, class) AlivcLivePushFPS pushFPS; // 推流FPS


- (void)prepare;
- (BOOL)start;
- (BOOL)stop;
- (void)destory;

- (void)pause:(BOOL)pause; // 关闭视频
- (void)mute:(BOOL)mute;   // 关闭音频
- (void)switchCamera;
- (void)mirror:(BOOL)mirror;
- (void)setLiveMixTranscodingConfig:(AlivcLiveTranscodingConfig * _Nullable )liveTranscodingConfig;

@end

NS_ASSUME_NONNULL_END
