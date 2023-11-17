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
        return nil;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)parseJson:(NSString *)json {
    if (json.length == 0) {
        return nil;
    }
    return [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
}

+ (NSError *)error:(NSInteger)code msg:(NSString *)msg {
    return [NSError errorWithDomain:@"auimessage" code:code userInfo:@{NSLocalizedDescriptionKey:msg}];
}

@end

