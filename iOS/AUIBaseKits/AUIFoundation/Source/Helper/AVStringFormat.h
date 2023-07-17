//
//  AVStringFormat.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVStringFormat : NSObject
// 00:00
+ (NSString *)formatWithDuration:(float)duration;

// 00:00:00
+ (NSString *)format2WithDuration:(float)duration;

@end

NS_ASSUME_NONNULL_END
