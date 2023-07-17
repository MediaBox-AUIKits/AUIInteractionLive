//
//  AUIMessageModel.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import "AUIMessageModel.h"

@interface AUIMessageDefaultData ()

@property (nonatomic, copy) NSDictionary *data;

@end

@implementation AUIMessageDefaultData

- (instancetype)initWithData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        _data = data;
    }
    return self;
}

- (NSDictionary *)toData {
    return _data;
}

@end

@implementation AUIMessageModel

@end
