//
//  AUIMessageListener.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2023/5/9.
//

#import "AUIMessageListener.h"

@interface AUIMessageListenerObserver ()

@property (nonatomic, strong) NSHashTable<id<AUIMessageListenerProtocol>> *observerList;

@end

@implementation AUIMessageListenerObserver

- (NSHashTable<id<AUIMessageListenerProtocol>> *)observerList {
    if (!_observerList) {
        _observerList = [NSHashTable weakObjectsHashTable];
    }
    return _observerList;
}

- (void)addListener:(id<AUIMessageListenerProtocol>)listener {
    if ([NSThread isMainThread]) {
        if ([self.observerList containsObject:listener])
        {
            return;
        }
        [self.observerList addObject:listener];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addListener:listener];
        });
    }
}

- (void)removeListener:(id<AUIMessageListenerProtocol>)listener {
    if ([NSThread isMainThread]) {
        [self.observerList removeObject:listener];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeListener:listener];
        });
    }
}

- (void)onJoinGroup:(AUIMessageModel *)model {
    if ([NSThread isMainThread]) {
        NSEnumerator<id<AUIMessageListenerProtocol>>* enumerator = [[self.observerList copy] objectEnumerator];
        id<AUIMessageListenerProtocol> observer = nil;
        while ((observer = [enumerator nextObject])) {
            if ([observer respondsToSelector:@selector(onJoinGroup:)]) {
                [observer onJoinGroup:model];
            }
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onJoinGroup:model];
        });
    }
}

- (void)onLeaveGroup:(AUIMessageModel *)model {
    if ([NSThread isMainThread]) {
        NSEnumerator<id<AUIMessageListenerProtocol>>* enumerator = [[self.observerList copy] objectEnumerator];
        id<AUIMessageListenerProtocol> observer = nil;
        while ((observer = [enumerator nextObject])) {
            if ([observer respondsToSelector:@selector(onLeaveGroup:)]) {
                [observer onLeaveGroup:model];
            }
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onLeaveGroup:model];
        });
    }
}

- (void)onMuteGroup:(AUIMessageModel *)model {
    if ([NSThread isMainThread]) {
        NSEnumerator<id<AUIMessageListenerProtocol>>* enumerator = [[self.observerList copy] objectEnumerator];
        id<AUIMessageListenerProtocol> observer = nil;
        while ((observer = [enumerator nextObject])) {
            if ([observer respondsToSelector:@selector(onMuteGroup:)]) {
                [observer onMuteGroup:model];
            }
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onMuteGroup:model];
        });
    }
}

- (void)onUnmuteGroup:(AUIMessageModel *)model {
    if ([NSThread isMainThread]) {
        NSEnumerator<id<AUIMessageListenerProtocol>>* enumerator = [[self.observerList copy] objectEnumerator];
        id<AUIMessageListenerProtocol> observer = nil;
        while ((observer = [enumerator nextObject])) {
            if ([observer respondsToSelector:@selector(onUnmuteGroup:)]) {
                [observer onUnmuteGroup:model];
            }
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onUnmuteGroup:model];
        });
    }
}

- (void)onMessageReceived:(AUIMessageModel *)model {
    if ([NSThread isMainThread]) {
        NSEnumerator<id<AUIMessageListenerProtocol>>* enumerator = [[self.observerList copy] objectEnumerator];
        id<AUIMessageListenerProtocol> observer = nil;
        while ((observer = [enumerator nextObject])) {
            if ([observer respondsToSelector:@selector(onMessageReceived:)]) {
                [observer onMessageReceived:model];
            }
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onMessageReceived:model];
        });
    }
}

- (void)onExitedGroup:(NSString *)groudId {
    if ([NSThread isMainThread]) {
        NSEnumerator<id<AUIMessageListenerProtocol>>* enumerator = [[self.observerList copy] objectEnumerator];
        id<AUIMessageListenerProtocol> observer = nil;
        while ((observer = [enumerator nextObject])) {
            if ([observer respondsToSelector:@selector(onExitedGroup:)]) {
                [observer onExitedGroup:groudId];
            }
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onExitedGroup:groudId];
        });
    }
}

- (void)onGroup:(NSString *)groupId onlineCountChanged:(NSInteger)onlineCount {
    if ([NSThread isMainThread]) {
        NSEnumerator<id<AUIMessageListenerProtocol>>* enumerator = [[self.observerList copy] objectEnumerator];
        id<AUIMessageListenerProtocol> observer = nil;
        while ((observer = [enumerator nextObject])) {
            if ([observer respondsToSelector:@selector(onGroup:onlineCountChanged:)]) {
                [observer onGroup:groupId onlineCountChanged:onlineCount];
            }
        }
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onGroup:groupId onlineCountChanged:onlineCount];
        });
    }
}

@end
