//
//  AUIMessageUserInfo.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import "AUIMessageUserInfo.h"

@implementation AUIMessageUserInfo

@synthesize userAvatar = _userAvatar;
@synthesize userNick = _userNick;
@synthesize userId = _userId;

- (instancetype)init:(NSString *)userId {
    self = [super init];
    if (self) {
        _userId = userId ?: @"";
        _userNick = @"";
        _userAvatar = @"";
    }
    return self;
}

@end
