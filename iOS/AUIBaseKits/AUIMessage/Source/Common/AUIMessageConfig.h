//
//  AUIMessageConfig.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIMessageConfig : NSObject

@property (nonatomic, copy, readonly, class) NSString *deviceId;
@property (nonatomic, copy, nullable) NSDictionary *tokenData;

@end

NS_ASSUME_NONNULL_END
