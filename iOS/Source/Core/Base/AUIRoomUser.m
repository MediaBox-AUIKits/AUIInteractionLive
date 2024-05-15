//
//  AUIRoomUser.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/8/31.
//

#import "AUIRoomUser.h"

#import <UIKit/UIKit.h>

@implementation AUIRoomUser

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _userId = [data objectForKey:@"userId"];
        _nickName = [data objectForKey:@"userNick"];
        _avatar = [data objectForKey:@"userAvatar"];
    }
    return self;
}

- (NSDictionary *)toData {
    return @{
        @"userId":_userId ?: @"",
        @"userNick":_nickName ?: @"",
        @"userAvatar":_avatar ?: @"",
    };
}

@end
