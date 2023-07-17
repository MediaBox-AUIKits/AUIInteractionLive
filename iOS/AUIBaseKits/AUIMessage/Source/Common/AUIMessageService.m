//
//  AUIMessageService.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import "AUIMessageService.h"

#define AUIMESSAGE_IMPL_ALIVC 0  // 阿里互动SDK
#define AUIMESSAGE_IMPL_RC_CHATROOM 1   // 融云SDK-聊天室

//#define AUIMESSAGE_IMPL_TYPE AUIMESSAGE_IMPL_RC_CHATROOM

#if AUIMESSAGE_IMPL_TYPE==AUIMESSAGE_IMPL_ALIVC
#import "AUIMessageServiceImpl_Alivc.h"
#else
#import "AUIMessageServiceImpl_RCChatRoom.h"
#endif

@implementation AUIMessageServiceFactory

+ (id<AUIMessageServiceProtocol>)getMessageService {
    static id<AUIMessageServiceProtocol> _instance = nil;
    if (!_instance) {
#if AUIMESSAGE_IMPL_TYPE==AUIMESSAGE_IMPL_ALIVC
        _instance = [AUIMessageServiceImpl_Alivc new];
#else
        _instance = [AUIMessageServiceImpl_RCChatRoom new];
#endif
    }
    return _instance;
}

@end
