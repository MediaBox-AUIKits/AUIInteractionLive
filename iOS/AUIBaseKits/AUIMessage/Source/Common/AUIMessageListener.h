//
//  AUIMessageListener.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import <Foundation/Foundation.h>
#import "AUIMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 消息服务回调监听者接口
 */
@protocol AUIMessageListenerProtocol <NSObject>

@optional

/**
 * 有人加入群组事件
 */
- (void)onJoinGroup:(AUIMessageModel *)model;

/**
 * 有人离开群组事件
 */
- (void)onLeaveGroup:(AUIMessageModel *)model;

/**
 * 群组禁言事件
 */
- (void)onMuteGroup:(AUIMessageModel *)model;

/**
 * 群组取消禁言事件
 */
- (void)onUnmuteGroup:(AUIMessageModel *)model;

/**
 * 收到消息
 */
- (void)onMessageReceived:(AUIMessageModel *)model;

@end


/**
 * 消息服务回调观察者
 */
@interface AUIMessageListenerObserver : NSObject <AUIMessageListenerProtocol>

/**
 * 添加监听者
 *
 * @param listener     消息回调监听者
 */
- (void)addListener:(id<AUIMessageListenerProtocol>)listener;


/**
 * 移除监听者
 *
 * @param listener     消息回调监听者
 */
- (void)removeListener:(id<AUIMessageListenerProtocol>)listener;

@end


NS_ASSUME_NONNULL_END
