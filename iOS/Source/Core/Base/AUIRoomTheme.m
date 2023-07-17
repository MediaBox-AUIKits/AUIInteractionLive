//
//  AUIRoomTheme.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/4/19.
//

#import "AUIRoomTheme.h"

#define AUIResourceName @"AUIInteractionLive"

@implementation AUIRoomTheme

static NSString *g_resouceName = AUIResourceName;
+ (NSString *)resourceName {
    return g_resouceName;
}

+ (void)setResourceName:(NSString *)resourceName {
    g_resouceName = resourceName;
}

@end
