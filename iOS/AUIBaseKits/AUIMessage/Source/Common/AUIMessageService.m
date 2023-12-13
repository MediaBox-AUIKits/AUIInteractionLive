//
//  AUIMessageService.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import "AUIMessageService.h"

#if __has_include(<AliVCInteractionMessage/AliVCInteractionMessage.h>)

#if !__has_include(<AlivcInteraction/AlivcInteraction.h>)

#define AUIMESSAGE_IMPL_CLASS AUIMessageServiceImpl_AliVCIM
#import "AUIMessageServiceImpl_AliVCIM.h"

#else

#define AUIMESSAGE_IMPL_CLASS AUIMessageServiceImpl_AliVCIMCompat
#import "AUIMessageServiceImpl_AliVCIMCompat.h"

#endif

#elif __has_include(<AlivcInteraction/AlivcInteraction.h>)
#define AUIMESSAGE_IMPL_CLASS AUIMessageServiceImpl_Alivc
#import "AUIMessageServiceImpl_Alivc.h"

#elif __has_include(<RongIMLib/RongIMLib.h>)
#define AUIMESSAGE_IMPL_CLASS AUIMessageServiceImpl_RCChatRoom
#import "AUIMessageServiceImpl_RCChatRoom.h"

#endif


@implementation AUIMessageServiceFactory

+ (id<AUIMessageServiceProtocol>)getMessageService {
    static id<AUIMessageServiceProtocol> _instance = nil;
    if (!_instance) {
#ifdef AUIMESSAGE_IMPL_CLASS
        _instance = [AUIMESSAGE_IMPL_CLASS new];
#endif
    }
    return _instance;
}

@end
