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


@property (nonatomic, copy, readonly) AUIRoomUser *myInfo;
@property (nonatomic, copy) NSString *myToken;
@property (nonatomic, copy, readonly, class) NSString *deviceId;

- (void)changedAccount:(nullable AUIRoomAccount *)newAccount;

+ (AUIRoomAccount *)myAccount;
+ (AUIRoomUser *)me;


@end

NS_ASSUME_NONNULL_END
