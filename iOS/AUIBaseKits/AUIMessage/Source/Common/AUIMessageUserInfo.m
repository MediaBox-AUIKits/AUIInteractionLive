//
//  AUIMessageUserInfo.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import "AUIMessageUserInfo.h"

@implementation AUIMessageUserInfo

@synthesize userAvatar;
@synthesize userNick;
@synthesize userId = _userId;

- (instancetype)init:(NSString *)userId {
    self = [super init];
    if (self) {
        _userId = userId;
    }
    return self;
}

@end
