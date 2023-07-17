//
//  AUILiveRoomLivingContainerView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/10/6.
//

#import "AUILiveRoomLivingContainerView.h"

@implementation AUILiveRoomLivingContainerView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return nil;
    }
    return view;
}

@end
