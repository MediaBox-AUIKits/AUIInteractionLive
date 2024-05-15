//
//  AUIRoomUser.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/8/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomUser : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *nickName;

- (instancetype)initWithData:(NSDictionary *)data;
- (NSDictionary *)toData;

@end

NS_ASSUME_NONNULL_END
