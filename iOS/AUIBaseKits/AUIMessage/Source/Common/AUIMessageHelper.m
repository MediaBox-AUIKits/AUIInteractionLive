//
//  AUIMessageHelper.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import "AUIMessageHelper.h"

@implementation AUIMessageHelper


+ (NSString *)jsonStringWithDict:(NSDictionary *)dict {
    if (!dict) {
        return @"{}";
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}



@end

