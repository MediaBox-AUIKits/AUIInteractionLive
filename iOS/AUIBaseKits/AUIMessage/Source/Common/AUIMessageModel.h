//
//  AUIMessageModel.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import <Foundation/Foundation.h>
#import "AUIMessageUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUIMessageLevel) {
    AUIMessageLevelNormal,
    AUIMessageLevelHigh,
};

@protocol AUIMessageDataProtocol <NSObject>

- (instancetype)initWithData:(NSDictionary *)data;
- (NSDictionary *)toData;

@end

@interface AUIMessageDefaultData : NSObject<AUIMessageDataProtocol>


@end

@interface AUIMessageModel : NSObject

@property (nonatomic, copy, nullable) NSString *messageId;
@property (nonatomic, copy, nullable) NSString *groupId;
@property (nonatomic, assign) NSInteger msgType;
@property (nonatomic, assign) AUIMessageLevel msgLevel;

@property (nonatomic, strong, nullable) id<AUIUserProtocol> sender;
@property (nonatomic, copy, nullable) NSDictionary *data;


@end

NS_ASSUME_NONNULL_END
