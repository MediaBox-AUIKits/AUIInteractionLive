//
//  AUILiveRoomActionManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/29.
//

#import "AUILiveRoomActionManager.h"

@implementation AUILiveRoomActionManager

+ (AUILiveRoomActionManager *)defaultManager {
    static AUILiveRoomActionManager *_instance = nil;
    if (!_instance) {
        _instance = [AUILiveRoomActionManager new];
    }
    return _instance;
}

@end
