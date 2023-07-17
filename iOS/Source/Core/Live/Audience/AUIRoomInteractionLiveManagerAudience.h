//
//  AUIRoomInteractionLiveManagerAudience.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/27.
//

#import <Foundation/Foundation.h>
#import "AUIRoomBaseLiveManagerAudience.h"
#import "AUIRoomLiveRtcPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomInteractionLiveManagerAudience : AUIRoomBaseLiveManagerAudience

- (instancetype)initWithModel:(AUIRoomLiveInfoModel *)liveInfoModel withJoinList:(nullable NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)joinList;

@property (copy, nonatomic, readonly) NSArray<AUIRoomLiveRtcPlayer *> *currentJoinList;
@property (assign, nonatomic, readonly) BOOL isJoinedLinkMic;
@property (assign, nonatomic, readonly) BOOL isApplyingLinkMic;


// 申请后，超时无响应事件
@property (copy, nonatomic) void(^onNotifyApplyNotResponse)(AUIRoomInteractionLiveManagerAudience *sender);
// 收到申请连麦响应结果事件
@property (nonatomic, copy) void (^onReceivedResponseApplyLinkMic)(AUIRoomUser *sender, BOOL agree, NSString *pullUrl);
// 收到同意上麦
- (void)receivedAgreeToLinkMic:(NSString *)userId willGiveUp:(BOOL)giveUp completed:(nullable void (^)(BOOL, BOOL, NSString *))completed;
// 收到不同意上麦
- (void)receivedDisagreeToLinkMic:(NSString *)userId completed:(nullable void (^)(BOOL))completed;
// 申请
- (void)applyLinkMic:(nullable void(^)(BOOL))completed;
// 取消申请
- (void)cancelApplyLinkMic:(nullable void (^)(BOOL))completed;
// 下麦
- (void)leaveLinkMic:(nullable void(^)(BOOL))completed;



// 收到观众上麦事件
@property (nonatomic, copy) void (^onReceivedJoinLinkMic)(AUIRoomUser *sender);
// 收到观众下麦事件
@property (nonatomic, copy) void (^onReceivedLeaveLinkMic)(NSString *userId);


// 收到主播要求打开摄像头事件
@property (nonatomic, copy) void (^onReceivedOpenCamera)(AUIRoomUser *sender,  BOOL needOpen);
// 收到主播要求打开麦克风事件
@property (nonatomic, copy) void (^onReceivedOpenMic)(AUIRoomUser *sender, BOOL needOpen);
@property (assign, nonatomic, readonly) BOOL isMicOpened;
@property (assign, nonatomic, readonly) BOOL isCameraOpened;
@property (assign, nonatomic, readonly) BOOL isBackCamera;
- (void)openLivePusherMic:(BOOL)open;
- (void)openLivePusherCamera:(BOOL)open;
- (void)switchLivePusherCamera;


@end

NS_ASSUME_NONNULL_END
