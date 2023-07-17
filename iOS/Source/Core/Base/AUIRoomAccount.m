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

+ (AUIRoomUser *)me {
    static AUIRoomUser *_instance = nil;
    if (!_instance) {
        _instance = [AUIRoomUser new];
    }
    return _instance;
}

+ (NSString *)deviceId {
    return AUIMessageConfig.deviceId;
}

@end
