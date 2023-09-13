//
//  AUIMessageGroupModel.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import <Foundation/Foundation.h>
#import "AUIMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIMessageCreateGroupRequest : NSObject

/**
 * 扩展信息
 */
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> *extension;

@end


@interface AUIMessageCreateGroupResponse : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy) NSString *groupId;

@end


@interface AUIMessageJoinGroupRequest : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy) NSString *groupId;

@end

@interface AUIMessageLeaveGroupRequest : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy) NSString *groupId;

@end

@interface AUIMessageSendMessageToGroupRequest : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy) NSString *groupId;

/**
 * 消息类型
 */
@property (nonatomic, assign) NSInteger msgType;

/**
 * 消息体内容
 */
@property (nonatomic, strong) id<AUIMessageDataProtocol> data;

/**
 * 是否跳过审核
 */
@property (nonatomic, assign) BOOL skipAudit;


@end


@interface AUIMessageSendMessageToGroupResponse : NSObject

/**
 * 消息id
 */
@property (nonatomic, copy) NSString *messageId;

@end


@interface AUIMessageSendMessageToGroupUserRequest : NSObject

/**
 * 群组id，为空时全局发送
 */
@property (nonatomic, copy, nullable) NSString *groupId;

/**
 * 消息类型
 */
@property (nonatomic, assign) NSInteger msgType;

/**
 * 消息体内容
 */
@property (nonatomic, strong) id<AUIMessageDataProtocol> data;

/**
 * 接收用户ID
 */
@property (nonatomic, copy) NSString *receiverId;

/**
 * 是否跳过审核
 */
@property (nonatomic, assign) BOOL skipAudit;


@end

@interface AUIMessageSendMessageToGroupUserResponse : NSObject

/**
 * 消息id
 */
@property (nonatomic, copy) NSString *messageId;

@end





@interface AUIMessageGetGroupInfoRequest : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy) NSString *groupId;

@end


@interface AUIMessageGetGroupInfoResponse : NSObject

/**
 * 群组id
 */
@property (nonatomic, copy) NSString *groupId;

/**
 * 在线人数
 */
@property (nonatomic, assign) NSInteger onlineCount;


@end


NS_ASSUME_NONNULL_END
