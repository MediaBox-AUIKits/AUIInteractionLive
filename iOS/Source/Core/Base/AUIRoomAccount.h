//
//  AUIRoomAccount.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/10/6.
//

#import <Foundation/Foundation.h>
#import "AUIRoomUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomAccount : NSObject

+ (AUIRoomUser *)me;
@property (nonatomic, copy, readonly, class) NSString *deviceId;

@end

NS_ASSUME_NONNULL_END
