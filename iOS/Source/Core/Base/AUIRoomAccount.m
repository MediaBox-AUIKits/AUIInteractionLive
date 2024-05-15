//
//  AUIRoomAccount.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/10/6.
//

#import <UIKit/UIKit.h>
#import "AUIRoomAccount.h"
#import "AUIMessageService.h"

@implementation AUIRoomAccount

+ (AUIRoomAccount *)myAccount {
    static AUIRoomAccount *_instance = nil;
    if (!_instance) {
        _instance = [AUIRoomAccount new];
    }
    return _instance;
}

+ (AUIRoomUser *)me {
    return [self myAccount].myInfo;
}

+ (NSString *)deviceId {
    return AUIMessageConfig.deviceId;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _myInfo = [AUIRoomUser new];
        _myToken = @"";
    }
    return self;
}

- (void)changedAccount:(nullable AUIRoomAccount *)newAccount {
    _myInfo = newAccount.myInfo ?: [AUIRoomUser new];
    _myToken = newAccount.myToken;
}

@end
