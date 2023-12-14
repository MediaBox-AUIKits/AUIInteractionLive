//
//  AUIBeautyQueenHeader.h
//  AUIBeauty
//
//  Created by Bingo on 2023/11/24.
//

#ifndef AUIBeautyQueenHeader_h
#define AUIBeautyQueenHeader_h

#if __has_include(<Queen/Queen.h>)
#import <Queen/Queen.h>

#elif __has_include(<AliVCSDK_Standard/AliVCSDK_Standard.h>)
#import <AliVCSDK_Standard/AliVCSDK_Standard.h>

#elif __has_include(<AliVCSDK_UGC/AliVCSDK_UGC.h>)
#import <AliVCSDK_UGC/AliVCSDK_UGC.h>

#elif __has_include(<AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>)
#import <AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>

#elif __has_include(<AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>)
#import <AliVCSDK_BasicLive/AliVCSDK_BasicLive.h>

#endif




#endif /* AUIBeautyQueenHeader_h */
