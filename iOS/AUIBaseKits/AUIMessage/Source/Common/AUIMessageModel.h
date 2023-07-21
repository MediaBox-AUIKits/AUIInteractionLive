//
//  AUIMessageModel.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import <Foundation/Foundation.h>
#import "AUIMessageUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AUIMessageDataProtocol <NSObject>

- (instancetype)initWithData:(NSDictionary *)data;
- (NSDictionary *)toData;

@end

@interface AUIMessageDefaultData : NSObject<AUIMessageDataProtocol>


@end

@interface AUIMessageModel : NSObject

@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, assign) NSInteger msgType;

@property (nonatomic, strong) id<AUIUserProtocol> sender;
@property (nonatomic, copy) NSDictionary *data;


@end

NS_ASSUME_NONNULL_END
