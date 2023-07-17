//
//  AUILiveManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/19.
//

#import "AUILiveManager.h"

@implementation AUILiveManager

#if LIVE_TYPE==INTERACTION_LIVE
+ (AUIInteractionLiveManager *)liveManager {
    return [AUIInteractionLiveManager defaultManager];
}
#else
+ (AUIEnterpriseLiveManager *)liveManager {
    return [AUIEnterpriseLiveManager defaultManager];
}
#endif


@end
