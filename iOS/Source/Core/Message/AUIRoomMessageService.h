//
//  AUIRoomMessageService.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/2/24.
//

#import <Foundation/Foundation.h>
#import "AUIMessageService.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AUIRoomMessageServiceObserver <NSObject>

@optional

/**
 * 消息所在的群
 */
- (NSString *)groupId;

/**
 * 收到评论消息
 */
- (void)onCommentReceived:(AUIMessageModel *)message;

/**
 * 收到点赞消息
 */
- (void)onLikeReceived:(AUIMessageModel *)message;

/**
 * 收到其他信令
 */
- (void)onCommandReceived:(AUIMessageModel *)message;

/**
 * 加入消息组
 */
- (void)onJoinGroup:(AUIMessageModel *)message;

/**
 * 离开消息组
 */
- (void)onLeaveGroup:(AUIMessageModel *)message;

/**
 * 禁言群组
 */
- (void)onMuteGroup:(AUIMessageModel *)message;

/**
 * 取消禁言群组
 */
- (void)onCancelMuteGroup:(AUIMessageModel *)message;

/**
 * 被动离开群组
 */
- (void)onExitedGroup:(NSString *)groupId;

@end


typedef void(^AUIRoomMessageCallback)(NSError * _Nullable error);

@protocol AUIRoomMessageServiceProtocol

- (void)login:(void(^)(BOOL))completed;
- (void)logout;

- (void)addObserver:(id<AUIRoomMessageServiceObserver>)observer;
- (void)removeObserver:(id<AUIRoomMessageServiceObserver>)observer;

- (void)joinGroup:(NSString *)groupID
        completed:(AUIMessageDefaultCallback _Nullable)completed;

- (void)leaveGroup:(NSString *)groupID
         completed:(AUIMessageDefaultCallback _Nullable)completed;

- (void)queryStatistics:(NSString *)groupID
           completed:(void (^)(NSInteger pv, NSInteger onlineCount, NSError * _Nullable))completed;

- (void)muteAll:(NSString *)groupID
      completed:(AUIMessageDefaultCallback _Nullable)completed;

- (void)cancelMuteAll:(NSString *)groupID
            completed:(AUIMessageDefaultCallback _Nullable)completed;

- (void)queryMuteAll:(NSString *)groupID
           completed:(void (^)(BOOL, NSError * _Nullable))completed;

- (void)sendLike:(NSString *)groupID
           count:(NSUInteger)count
       completed:(AUIMessageDefaultCallback _Nullable)completed;

- (void)sendComment:(NSString *)groupID
            comment:(NSDictionary *)comment
          completed:(AUIMessageDefaultCallback)completed;

- (void)sendCommand:(NSInteger)type
               data:(id<AUIMessageDataProtocol> _Nullable)data
            groupID:(NSString * _Nullable)groupID
         receiverId:(NSString * _Nullable)receiverId
          completed:(AUIMessageDefaultCallback _Nullable)completed;

@end

@interface AUIRoomMessage : NSObject

@property (nonatomic, strong, readonly, class) id<AUIRoomMessageServiceProtocol> currentService;

+ (NSArray<NSString *> *)currentIMServers;
+ (void)useAlivcIMWhenCompatMode:(BOOL)isAlivcIM;
+ (NSDictionary *)fetchTokenData:(NSDictionary *)rspData;

@end



NS_ASSUME_NONNULL_END
