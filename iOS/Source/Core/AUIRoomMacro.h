//
//  AUIRoomMacro.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/14.
//

#ifndef AUIRoomMacro_h
#define AUIRoomMacro_h

#import "AUIFoundation.h"
#import "AUIRoomTheme.h"

#define AUIRoomGetImage(key) AVGetImage(key, AUIRoomTheme.resourceName)
#define AUIRoomGetCommonImage(key) AVGetCommonImage(key, AUIRoomTheme.resourceName)
#define AUIRoomGetString(key) AVGetString(key, AUIRoomTheme.resourceName)

#define AUIRoomColourfulFillStrong [UIColor av_colorWithHexString:@"#FF5722"]
#define AUIRoomColourfulFillDisable [UIColor av_colorWithHexString:@"#FFCCBC"]

#endif /* AUIRoomMacro_h */
