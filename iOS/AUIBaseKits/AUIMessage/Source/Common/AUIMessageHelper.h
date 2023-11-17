//
//  AUIMessageHelper.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIMessageHelper : NSObject

+ (nullable NSString *)jsonStringWithDict:(NSDictionary *)dict;
+ (nullable NSDictionary *)parseJson:(NSString *)json;

+ (NSError *)error:(NSInteger)code msg:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
