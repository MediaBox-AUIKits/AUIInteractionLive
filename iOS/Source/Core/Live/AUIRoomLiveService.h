//
//  AUIRoomLiveService.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/2/25.
//

#import <Foundation/Foundation.h>
#import "AUIRoomUser.h"
#import "AUIRoomLiveModel.h"
#import "AUIRoomMessageService.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomGiftModel : NSObject<AUIMessageDataProtocol>

@property (nonatomic, copy) NSString *giftId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *imageUrl;

@end


@interface AUIRoomLiveService : NSObject


- (instancetype)initWithModel:(AUIRoomLiveInfoModel *)model
                 withJoinList:(nullable NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)joinList;

@property (assign, nonatomic, readonly) BOOL isAnchor;
@property (strong, nonatomic, readonly) AUIRoomLiveInfoModel *liveInfoModel;
@property (strong, nonatomic, readonly) NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *joinList;

// 房间管理
@property (assign, nonatomic, readonly) BOOL isJoined;
@property (assign, nonatomic, readonly) NSInteger pv;
- (void)enterRoom:(nullable void(^)(BOOL))completed;
- (void)leaveRoom:(nullable void(^)(BOOL))completed;

// 主播状态
- (void)startLive:(nullable void(^)(BOOL))completed;
- (void)finishLive:(nullable void(^)(BOOL))completed;

// 全局禁言
@property (assign, nonatomic, readonly) BOOL isMuteAll;
- (void)queryMuteAll:(nullable void (^)(BOOL))completed;
- (void)muteAll:(nullable void(^)(BOOL))completed;
- (void)cancelMuteAll:(nullable void(^)(BOOL))completed;

// 公告
@property (copy, nonatomic, readonly) NSString *notice;
- (void)updateNotice:(NSString *)notice completed:(nullable void(^)(BOOL))completed;

// 点赞
@property (assign, nonatomic, readonly) NSInteger allLikeCount;
- (void)sendLike;

// 给主播送礼物
- (void)sendGift:(AUIRoomGiftModel *)gift completed:(void(^)(BOOL))completed;

// 麦控
- (void)sendCameraOpened:(BOOL)opened completed:(nullable void(^)(BOOL))completed;
- (void)sendMicOpened:(BOOL)opened completed:(nullable void(^)(BOOL))completed;
- (void)sendOpenCamera:(NSString *)userId needOpen:(BOOL)needOpen completed:(nullable void(^)(BOOL))completed;
- (void)sendOpenMic:(NSString *)userId needOpen:(BOOL)needOpen completed:(nullable void(^)(BOOL))completed;

// 弹幕
- (void)sendComment:(NSString *)comment completed:(nullable void(^)(BOOL))completed;

// 发送信令（自定义）
- (void)sendData:(nullable id<AUIMessageDataProtocol>)data type:(NSInteger)type receiverId:(nullable NSString *)receiverId completed:(nullable void(^)(BOOL))completed;


// 申请/响应连麦
- (void)sendApplyLinkMic:(NSString *)uid completed:(nullable void(^)(BOOL))completed;
- (void)sendCancelApplyLinkMic:(NSString *)uid completed:(nullable void(^)(BOOL))completed;
- (void)sendResponseLinkMic:(NSString *)uid agree:(BOOL)agree pullUrl:(NSString *)pullUrl completed:(nullable void(^)(BOOL))completed;

// 广播自己要干什么：上麦/下麦/踢人下麦
- (void)sendJoinLinkMic:(NSString *)pullUrl completed:(nullable void(^)(BOOL))completed;
- (void)sendLeaveLinkMic:(BOOL)byKickout completed:(nullable void(^)(BOOL))completed;
- (void)sendKickoutLinkMic:(NSString *)uid completed:(nullable void(^)(BOOL))completed;

// 查询/更新连麦列表
@property (assign, nonatomic, class) NSUInteger maxLinkMicCount;
- (void)queryLinkMicJoinList:(nullable void(^)(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> * _Nullable))completed;
- (void)updateLinkMicJoinList:(nullable NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)joinList completed:(nullable void(^)(BOOL))completed;

// 房间事件
@property (nonatomic, copy) void (^onReceivedCustomMessage)(AUIMessageModel *message);
@property (nonatomic, copy) void (^onReceivedComment)(AUIRoomUser *sender, NSString *content);
@property (nonatomic, copy) void (^onReceivedStartLive)(AUIRoomUser *sender);
@property (nonatomic, copy) void (^onReceivedStopLive)(AUIRoomUser *sender);
@property (nonatomic, copy) void (^onReceivedLike)(AUIRoomUser *sender, NSInteger likeCount);
@property (nonatomic, copy) void (^onReceivedPV)(NSInteger pv);
@property (nonatomic, copy) void (^onReceivedMuteAll)(BOOL isMuteAll);
@property (nonatomic, copy) void (^onReceivedNoticeUpdate)(NSString *notice);
@property (nonatomic, copy) void (^onReceivedGift)(AUIRoomUser *sender, AUIRoomGiftModel *gift);
@property (nonatomic, copy) void (^onReceivedLeaveRoom)(void);

// 麦控事件
@property (nonatomic, copy) void (^onReceivedCameraOpened)(AUIRoomUser *sender, BOOL opened);
@property (nonatomic, copy) void (^onReceivedMicOpened)(AUIRoomUser *sender, BOOL opened);
@property (nonatomic, copy) void (^onReceivedOpenCamera)(AUIRoomUser *sender,  BOOL needOpen);
@property (nonatomic, copy) void (^onReceivedOpenMic)(AUIRoomUser *sender, BOOL needOpen);

// 连麦事件
@property (nonatomic, copy) void (^onReceivedApplyLinkMic)(AUIRoomUser *sender);
@property (nonatomic, copy) void (^onReceivedCancelApplyLinkMic)(AUIRoomUser *sender);
@property (nonatomic, copy) void (^onReceivedResponseApplyLinkMic)(AUIRoomUser *sender, BOOL agree, NSString *pullUrl);
@property (nonatomic, copy) void (^onReceivedJoinLinkMic)(AUIRoomUser *sender, AUIRoomLiveLinkMicJoinInfoModel *joinInfo);
@property (nonatomic, copy) void (^onReceivedLeaveLinkMic)(AUIRoomUser *sender, NSString *userId);


@end

NS_ASSUME_NONNULL_END
