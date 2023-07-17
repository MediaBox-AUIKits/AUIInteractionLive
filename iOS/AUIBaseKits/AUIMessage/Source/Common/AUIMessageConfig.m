//
//  AUIMessageConfig.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import "AUIMessageConfig.h"
#import <UIKit/UIKit.h>

@implementation AUIMessageConfig

+ (NSString *)deviceId {
    static NSString * _deviceId = nil;
    if (!_deviceId) {
        _deviceId = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    }
    return _deviceId;
}


@end
