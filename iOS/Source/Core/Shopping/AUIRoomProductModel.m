//
//  AUIRoomProductModel.m
//  AUIInteractionLiveDemo
//
//  Created by Bingo on 2024/2/28.
//

#import "AUIRoomProductModel.h"
#import "AUIFoundation.h"


@implementation AUIRoomProductModel

- (instancetype)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _productId = [data objectForKey:@"id"];
        _title = [data objectForKey:@"title"];
        _info = [data objectForKey:@"info"];
        _coverUrl = [data objectForKey:@"coverUrl"];
        _sellUrl = [data objectForKey:@"sellUrl"];
    }
    return self;
}

- (NSDictionary *)toData {
    return @{
        @"id":_productId ?: @"",
        @"title":_title ?: @"",
        @"info":_info ?: @"",
        @"coverUrl":_coverUrl ?: @"",
        @"sellUrl":_sellUrl ?: @"",
    };
}

@end
