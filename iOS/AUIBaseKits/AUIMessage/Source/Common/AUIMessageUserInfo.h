//
//  AUIMessageUserInfo.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AUIUserProtocol <NSObject>

@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, nullable) NSString *userNick;
@property (nonatomic, copy, nullable) NSString *userAvatar;

@end

@interface AUIMessageUserInfo : NSObject<AUIUserProtocol>

- (instancetype)init:(NSString *)userId;


@end

NS_ASSUME_NONNULL_END
