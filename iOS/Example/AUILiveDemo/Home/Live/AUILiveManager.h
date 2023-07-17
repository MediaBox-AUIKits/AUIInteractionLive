//
//  AUILiveManager.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/19.
//

#import <Foundation/Foundation.h>

#define INTERACTION_LIVE 0  // 互动直播
#define ENTERPRISE_LIVE 1   // 企业直播

//#define LIVE_TYPE ENTERPRISE_LIVE

#if LIVE_TYPE==INTERACTION_LIVE
#import "AUIInteractionLiveManager.h"
#else
#import "AUIEnterpriseLiveManager.h"
#endif


NS_ASSUME_NONNULL_BEGIN

@interface AUILiveManager : NSObject

#if LIVE_TYPE==INTERACTION_LIVE
+ (AUIInteractionLiveManager *)liveManager;
#else
+ (AUIEnterpriseLiveManager *)liveManager;
#endif

@end

NS_ASSUME_NONNULL_END
