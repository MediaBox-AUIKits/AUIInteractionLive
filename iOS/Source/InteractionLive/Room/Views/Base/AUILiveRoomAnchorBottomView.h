//
//  AUILiveRoomAnchorBottomView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>
#import "AUILiveRoomCommentTextField.h"

NS_ASSUME_NONNULL_BEGIN


@interface AUILiveRoomAnchorBottomView : UIView

@property (strong, nonatomic, readonly) AUILiveRoomCommentTextField* commentTextField;

@property (copy, nonatomic) void (^onMoreButtonClickedBlock)(AUILiveRoomAnchorBottomView *sender);
@property (copy, nonatomic) void (^onBeautyButtonClickedBlock)(AUILiveRoomAnchorBottomView *sender);
@property (copy, nonatomic) void (^onLinkMicButtonClickedBlock)(AUILiveRoomAnchorBottomView *sender);
@property (copy, nonatomic) void (^sendCommentBlock)(AUILiveRoomAnchorBottomView *sender, NSString *comment);

- (instancetype)initWithFrame:(CGRect)frame linkMic:(BOOL)linkMic;

- (void)updateLinkMicNumber:(NSUInteger)number;

@end

NS_ASSUME_NONNULL_END
