//
//  AUIRoomInteractionLiveManagerAnchor.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/4.
//

#import <Foundation/Foundation.h>
#import "AUIRoomBaseLiveManagerAnchor.h"
#import "AUIRoomLiveRtcPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomInteractionLiveManagerAnchor : AUIRoomBaseLiveManagerAnchor

- (instancetype)initWithModel:(AUIRoomLiveInfoModel *)liveInfoModel withJoinList:(nullable NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)joinList;

// 当前申请列表
@property (copy, nonatomic, readonly) NSArray<AUIRoomUser *> *currentApplyList;
// 当前正在连麦列表
@property (copy, nonatomic, readonly) NSArray<AUIRoomUser *> *currentJoiningList;
// 当前连麦列表
@property (copy, nonatomic, readonly) NSArray<AUIRoomLiveRtcPlayer *> *currentJoinList;

// 是否可以连麦
- (BOOL)checkCanLinkMic;


// 收到观众申请连麦事件
@property (nonatomic, copy) void (^onReceivedApplyLinkMic)(AUIRoomUser *sender);
// 收到观众取消申请连麦事件
@property (nonatomic, copy) void (^onReceivedCancelApplyLinkMic)(AUIRoomUser *sender);
// 连麦申请列表变化事件
@property (copy, nonatomic) void(^applyListChangedBlock)(AUIRoomInteractionLiveManagerAnchor *sender);
// 响应一个观众的连麦申请
- (void)responseApplyLinkMic:(AUIRoomUser *)user agree:(BOOL)agree force:(BOOL)force completed:(nullable void(^)(BOOL))completed;


// 收到观众上麦事件
@property (nonatomic, copy) void (^onReceivedJoinLinkMic)(AUIRoomUser *sender);
// 收到观众下麦事件
@property (nonatomic, copy) void (^onReceivedLeaveLinkMic)(NSString *userId);
// 踢人下麦
- (void)kickoutLinkMic:(NSString *)uid completed:(nullable void(^)(BOOL))completed;


// 收到观众摄像头开关事件
@property (nonatomic, copy) void (^onReceivedCameraOpened)(AUIRoomUser *sender, BOOL opened);
// 收到观众麦克风开关事件
@property (nonatomic, copy) void (^onReceivedMicOpened)(AUIRoomUser *sender, BOOL opened);
// 打开/关闭观众麦克风
- (void)openMic:(NSString *)uid needOpen:(BOOL)needOpen completed:(nullable void(^)(BOOL))completed;
// 打开/关闭观众摄像头
- (void)openCamera:(NSString *)uid needOpen:(BOOL)needOpen completed:(nullable void(^)(BOOL))completed;

@end


NS_ASSUME_NONNULL_END
