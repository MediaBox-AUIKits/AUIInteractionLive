//
//  AUIMessageService.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import <Foundation/Foundation.h>
#import "AUIMessageConfig.h"
#import "AUIMessageUserInfo.h"
#import "AUIMessageModel.h"
#import "AUIMessageListener.h"
#import "AUIMessageGroupModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 错误类型
 */
typedef NS_ENUM(NSUInteger, AUIMessageErrorType) {
    AUIMessageErrorTypeInvalidState = -1,
    AUIMessageErrorTypeParamError = -2,
    AUIMessageErrorTypeUnImpl = -3,
    AUIMessageErrorTypeOperationFail = -4,
};


typedef void(^AUIMessageDefaultCallback)(NSError * _Nullable error);
typedef void(^AUIMessageCreateGroupCallback)(AUIMessageCreateGroupResponse * _Nullable rsp, NSError * _Nullable error);
typedef void(^AUIMessageSendMessageToGroupCallback)(AUIMessageSendMessageToGroupResponse * _Nullable rsp, NSError * _Nullable error);
typedef void(^AUIMessageSendMessageToGroupUserCallback)(AUIMessageSendMessageToGroupUserResponse * _Nullable rsp, NSError * _Nullable error);
typedef void(^AUIMessageQueryMuteAllCallback)(AUIMessageQueryMuteAllResponse * _Nullable rsp, NSError * _Nullable error);
typedef void(^AUIMessageGetGroupInfoCallback)(AUIMessageGetGroupInfoResponse * _Nullable rsp, NSError * _Nullable error);


@protocol AUIMessageServiceConnectionDelegate <NSObject>

@optional

/**
 * Token过期事件
 */
- (void)onTokenExpire;


@end


/*
 AUIMessageServiceProtocol的接口不能被实现时，通过该回调由业务方实现
 */
@protocol AUIMessageServiceUnImplDelegate <NSObject>

@optional

// 当底层SDK无法支持全员禁言时，需要通过该接口来实现，可以在业务层进行实现（通过服务端接口实现）
// 如果接入模式RCChatRoom时，需要实现该接口
- (void)muteAll:(AUIMessageMuteAllRequest *)req callback:(AUIMessageDefaultCallback _Nullable)callback;

// 当底层SDK无法支持取消全员禁言时，需要通过该接口来实现，可以在业务层进行实现（通过服务端接口实现）
// 如果接入模式RCChatRoom时，需要实现该接口
- (void)cancelMuteAll:(AUIMessageCancelMuteAllRequest *)req callback:(AUIMessageDefaultCallback _Nullable)callback;

// 当底层SDK无法查询全员禁言时，需要通过该接口来实现，可以在业务层进行实现（通过服务端接口实现）
// 如果接入模式RCChatRoom时，需要实现该接口
- (void)queryMuteAll:(AUIMessageQueryMuteAllRequest *)req callback:(AUIMessageQueryMuteAllCallback _Nullable)callback;

// 当底层SDK无法支持点赞时，需要通过该接口来实现，可以在业务层进行实现（通过服务端接口实现）
// 如果接入模式是AliVCIM和RCChatRoom时，需要实现该接口
- (void)sendLike:(AUIMessageSendLikeRequest *)req callback:(AUIMessageDefaultCallback _Nullable)callback;

// 当在群禁言时无法跳过禁言检测（即禁言时无法发送消息），且由于业务需要还需要发送群组消息，可以在业务层进行实现（通过服务端接口实现）
// 如果接入模式是RCChatRoom时，需要实现该接口
- (void)sendSysMessageToGroup:(AUIMessageSendMessageToGroupRequest *)req callback:(AUIMessageSendMessageToGroupCallback _Nullable)callback;

@end

/**
 * 接口的实现类型
 */
typedef NS_ENUM(NSUInteger, AUIMessageServiceImplType) {
    AUIMessageServiceImplTypeAlivc,   // 阿里视频云旧版互动消息SDK
    AUIMessageServiceImplTypeAlivcIM, // 阿里视频云新版互动消息SDK
    AUIMessageServiceImplTypeAlivcCompat, // 兼容模式，使用阿里视频云新老互动消息SDK
    AUIMessageServiceImplTypeRCChatRoom, // 融云聊天室SDK
};

/**
 * 消息服务接口，用于建连、进出群组、发送消息等
 */
@protocol AUIMessageServiceProtocol <NSObject>

/**
 * @return 当前接口的实现类型
 */
- (AUIMessageServiceImplType)implType;

/**
 * 设置配置
 *
 * @param config 配置参数
 */
- (void)setConfig:(AUIMessageConfig *)config;


/**
 * 设置连接回调
 *
 * @param delegate connection delegate
 */
- (void)setConnectionDelegate:(id<AUIMessageServiceConnectionDelegate> _Nullable)delegate;

/*
 设置SDK无法实现的接口回调
 */
- (void)setUnImplDelegate:(id<AUIMessageServiceUnImplDelegate> _Nullable)delegate;

/**
 * 登录 (支持重复登录和切换账号)
 *
 * @param userInfo 登录的用户
 * @param callback 登录的结果回调
 */
- (void)login:(id<AUIUserProtocol>)userInfo callback:(AUIMessageDefaultCallback _Nullable)callback;

/**
 * 登出
 *
 * @param callback 登出结果回调
 */
- (void)logout:(AUIMessageDefaultCallback _Nullable)callback;

/**
 * @return 当前是否登录
 */
- (BOOL)isLogin;

/**
 * @return 获取当前登录的用户
 */
- (id<AUIUserProtocol> _Nullable)currentUserInfo;

/**
 * @return 获取消息观察者
 */
- (AUIMessageListenerObserver *)getListenerObserver;

/**
 * 创建群组
 *
 * @param req      请求实体
 * @param callback 接口回调
 */
- (void)createGroup:(AUIMessageCreateGroupRequest *)req callback:(AUIMessageCreateGroupCallback)callback;

/**
 * 加入群组
 *
 * @param req      请求实体
 * @param callback 接口回调
 */
- (void)joinGroup:(AUIMessageJoinGroupRequest *)req callback:(AUIMessageDefaultCallback _Nullable)callback;

/**
 * 离开群组
 *
 * @param req      请求实体
 * @param callback 接口回调
 */
- (void)leaveGroup:(AUIMessageLeaveGroupRequest *)req callback:(AUIMessageDefaultCallback _Nullable)callback;

/**
 * 全员禁言
 *
 * @param req      请求实体
 * @param callback 接口回调
 */
- (void)muteAll:(AUIMessageMuteAllRequest *)req callback:(AUIMessageDefaultCallback _Nullable)callback;

/**
 * 取消全员禁言
 *
 * @param req      请求实体
 * @param callback 接口回调
 */
- (void)cancelMuteAll:(AUIMessageCancelMuteAllRequest *)req callback:(AUIMessageDefaultCallback _Nullable)callback;

/**
 * 查询全员禁言
 *
 * @param req      请求实体
 * @param callback 接口回调
 */
- (void)queryMuteAll:(AUIMessageQueryMuteAllRequest *)req callback:(AUIMessageQueryMuteAllCallback _Nullable)callback;

/**
 * 发消息给群组全员
 *
 * @param req      请求实体
 * @param callback 接口回调
 */
- (void)sendMessageToGroup:(AUIMessageSendMessageToGroupRequest *)req callback:(AUIMessageSendMessageToGroupCallback _Nullable)callback;

/**
 * 发消息给群组指定成员
 *
 * @param req      请求实体
 * @param callback 接口回调
 */
- (void)sendMessageToGroupUser:(AUIMessageSendMessageToGroupUserRequest *)req callback:(AUIMessageSendMessageToGroupUserCallback _Nullable)callback;

/**
 * 点赞
 *
 * @param req      请求实体
 * @param callback 接口回调
 */
- (void)sendLike:(AUIMessageSendLikeRequest *)req callback:(AUIMessageDefaultCallback _Nullable)callback;

/**
 * 查询群信息
 *
 * @param req      请求实体
 * @param callback 接口回调
 */
- (void)getGroupInfo:(AUIMessageGetGroupInfoRequest *)req callback:(AUIMessageGetGroupInfoCallback _Nullable)callback;


/**
 * 获取SDK的操作引擎
 */
- (id)getNativeEngine;

@end


/**
 * 消息服务工厂类
 */
@interface AUIMessageServiceFactory : NSObject

/**
 * @return 获取当前MessageService实例
 */
+ (id<AUIMessageServiceProtocol>)getMessageService;

@end

NS_ASSUME_NONNULL_END
