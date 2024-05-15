//
//  AUIRoomGiftModel.m
//  AUIInteractionLiveDemo
//
//  Created by Bingo on 2024/2/28.
//

#import "AUIRoomGiftModel.h"
#import "AUIFoundation.h"

@implementation AUIRoomGiftModel

- (instancetype)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _giftId = [data av_stringValueForKey:@"id"];
        _name = [data av_stringValueForKey:@"name"];
        _info = [data av_stringValueForKey:@"info"];
        _imageUrl = [data av_stringValueForKey:@"imageUrl"];
        _sourceUrl = [data av_stringValueForKey:@"sourceUrl"];
        CGFloat width = [data av_floatValueForKey:@"width"];
        if (width <= 0) {
            width = 375.0;
        }
        CGFloat height = [data av_floatValueForKey:@"height"];
        if (height <= 0) {
            height = 812.0;
        }
        _size = CGSizeMake(width, height);
    }
    return self;
}

@end
