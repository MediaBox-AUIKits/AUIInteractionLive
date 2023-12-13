//
//  AUIRoomSDKHeader.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/4.
//

#ifndef AUIRoomSDKHeader_h
#define AUIRoomSDKHeader_h


#if __has_include(<AliVCSDK_Premium/AliVCSDK_Premium.h>)
#import <AliVCSDK_Premium/AliVCSDK_Premium.h>
#elif __has_include(<AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>)
#import <AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>
#elif __has_include(<AliVCSDK_PremiumLive/AliVCSDK_PremiumLive.h>)
#import <AliVCSDK_PremiumLive/AliVCSDK_PremiumLive.h>
#endif

#if __has_include(<Queen/Queen.h>)
#import <Queen/Queen.h>
#endif

#if __has_include(<RtsSDK/RtsSDK.h>)
#define RTS_SUPPORT
#import <RtsSDK/RtsSDK.h>
#endif

#if __has_include(<AliyunPlayer/AliyunPlayer.h>)
#import <AliyunPlayer/AliyunPlayer.h>
#endif

#if !__has_include(<AliyunQueenUIKit/AliyunQueenUIKit.h>)
#define DISABLE_QUEEN
#endif

#endif /* AUIRoomSDKHeader_h */
