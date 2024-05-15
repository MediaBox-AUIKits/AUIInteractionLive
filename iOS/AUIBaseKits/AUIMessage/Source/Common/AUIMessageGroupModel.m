//
//  AUIMessageGroupModel.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import "AUIMessageGroupModel.h"

@implementation AUIMessageCreateGroupRequest

@end


@implementation AUIMessageCreateGroupResponse

@end

@implementation AUIMessageJoinGroupRequest

@end


@implementation AUIMessageLeaveGroupRequest

@end


@implementation AUIMessageSendMessageToGroupRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.repeatCount = 1;
    }
    return self;
}

@end


@implementation AUIMessageSendMessageToGroupResponse

@end


@implementation AUIMessageSendMessageToGroupUserRequest

@end


@implementation AUIMessageSendMessageToGroupUserResponse

@end



@implementation AUIMessageMuteAllRequest

@end

@implementation AUIMessageCancelMuteAllRequest

@end

@implementation AUIMessageQueryMuteAllRequest

@end

@implementation AUIMessageQueryMuteAllResponse

@end

@implementation AUIMessageSendLikeRequest

@end



@implementation AUIMessageGetGroupInfoRequest

@end


@implementation AUIMessageGetGroupInfoResponse

@end
