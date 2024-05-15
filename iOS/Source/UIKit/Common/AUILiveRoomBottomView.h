//
//  AUILiveRoomBottomView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/7.
//

#import <UIKit/UIKit.h>
#import "AUILiveRoomCommentTextField.h"
#import "AUILiveRoomLikeButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomBottomView : UIView

@property (strong, nonatomic, readonly) AUILiveRoomCommentTextField* commentTextField;
@property (strong, nonatomic, readonly) AUILiveRoomLikeButton* likeButton;
@property (strong, nonatomic, readonly) UIButton *linkMicButton;
@property (strong, nonatomic, readonly) UIButton *shareButton;
@property (strong, nonatomic, readonly) UIButton *smallWinBtn;
@property (strong, nonatomic, readonly) UIButton *shoppingButton;
@property (strong, nonatomic, readonly) UIButton *giftButton;

@property (strong, nonatomic) UIColor *backgroundColorForNormalNormal;
@property (strong, nonatomic) UIColor *backgroundColorForEdit;

@property (copy, nonatomic) void (^onLikeButtonClickedBlock)(AUILiveRoomBottomView *sender);
@property (copy, nonatomic) void (^onSmallWindowButtonClickedBlock)(AUILiveRoomBottomView *sender);
@property (copy, nonatomic) void (^onShoppingButtonClickedBlock)(AUILiveRoomBottomView *sender);
@property (copy, nonatomic) void (^onGiftButtonClickedBlock)(AUILiveRoomBottomView *sender);
@property (copy, nonatomic) void (^onLinkMicButtonClickedBlock)(AUILiveRoomBottomView *sender);
@property (copy, nonatomic) void (^onShareButtonClickedBlock)(AUILiveRoomBottomView *sender);
@property (copy, nonatomic) void (^sendCommentBlock)(AUILiveRoomBottomView *sender, NSString *comment);

- (instancetype)initWithFrame:(CGRect)frame linkMic:(BOOL)linkMic;



@end

NS_ASSUME_NONNULL_END
