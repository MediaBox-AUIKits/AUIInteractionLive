//
//  AUILiveRoomBottomView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/7.
//

#import "AUILiveRoomBottomView.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"

@interface AUILiveRoomBottomView()

@property (strong, nonatomic) AUILiveRoomCommentTextField* commentTextField;

@property (strong, nonatomic) AUILiveRoomLikeButton* likeButton;
@property (strong, nonatomic) UIButton *linkMicButton;
@property (strong, nonatomic) UIButton *shareButton;

@end

@implementation AUILiveRoomBottomView


- (instancetype)initWithFrame:(CGRect)frame linkMic:(BOOL)linkMic {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColorForNormalNormal = UIColor.clearColor;
        self.backgroundColorForEdit = AUIFoundationColor(@"bg_weak");
        
        CGFloat startY = 4;
        
        AUILiveRoomLikeButton *likeButton = [[AUILiveRoomLikeButton alloc] initWithFrame:CGRectMake(self.av_right - 16 - 36, startY, 36, 36)];
        [likeButton setImage:AUIRoomGetCommonImage(@"ic_living_bottom_like") forState:UIControlStateNormal];
        likeButton.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
        [likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        likeButton.layer.masksToBounds = YES;
        likeButton.layer.cornerRadius = 18;
        [self addSubview:likeButton];
        self.likeButton = likeButton;
        
        if (linkMic) {
            UIButton* linkMicButton = [[UIButton alloc] initWithFrame:CGRectMake(likeButton.av_left - 12 - 36, startY, 36, 36)];
            [linkMicButton setImage:AUIRoomGetCommonImage(@"ic_living_bottom_link") forState:UIControlStateNormal];
            linkMicButton.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
            [linkMicButton addTarget:self action:@selector(linkButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            linkMicButton.layer.masksToBounds = YES;
            linkMicButton.layer.cornerRadius = 18;
            [self addSubview:linkMicButton];
            self.linkMicButton = linkMicButton;
        }
        
        UIButton* shareButton = [[UIButton alloc] initWithFrame:CGRectMake((self.linkMicButton ? self.linkMicButton.av_left : self.likeButton.av_left) - 12 - 36, startY, 36, 36)];
        [shareButton setImage:AUIRoomGetCommonImage(@"ic_living_bottom_share") forState:UIControlStateNormal];
        shareButton.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
        [shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        shareButton.layer.masksToBounds = YES;
        shareButton.layer.cornerRadius = 18;
        [self addSubview:shareButton];
        self.shareButton = shareButton;
        
        AUILiveRoomCommentTextField* commentTextField = [[AUILiveRoomCommentTextField alloc] initWithFrame:CGRectMake(16, startY, 120, 36)];
        commentTextField.layer.masksToBounds = YES;
        commentTextField.layer.cornerRadius = 18;
        [self addSubview:commentTextField];
        self.commentTextField = commentTextField;
        
        __weak typeof(self) weakSelf = self;
        self.commentTextField.sendCommentBlock = ^(AUILiveRoomCommentTextField * _Nonnull sender, NSString * _Nonnull comment) {
            if (weakSelf.sendCommentBlock) {
                weakSelf.sendCommentBlock(weakSelf, comment);
            }
        };
        self.commentTextField.willEditBlock = ^(AUILiveRoomCommentTextField * _Nonnull sender, CGRect keyboardFrame) {
            [weakSelf willEditBlock:keyboardFrame];
        };
        self.commentTextField.endEditBlock = ^(AUILiveRoomCommentTextField * _Nonnull sender) {
            [weakSelf endEditBlock];
        };
    }
    
    return self;
}

#pragma mark --UIButton Selectors

- (void)likeButtonAction:(UIButton *)sender {
    if (self.onLikeButtonClickedBlock) {
        self.onLikeButtonClickedBlock(self);
    }
}

- (void)linkButtonAction:(UIButton *)sender {
    if (self.onLinkMicButtonClickedBlock) {
        self.onLinkMicButtonClickedBlock(self);
    }
}

- (void)shareButtonAction:(UIButton *)sender {
    if (self.onShareButtonClickedBlock) {
        self.onShareButtonClickedBlock(self);
    }
}

- (void)willEditBlock:(CGRect)keyboardEndFrame {
    self.likeButton.hidden = YES;
    self.linkMicButton.hidden = YES;
    self.backgroundColor = self.backgroundColorForEdit;
    self.commentTextField.av_width = self.av_width - 16 * 2;
    self.transform = CGAffineTransformMakeTranslation(0, -keyboardEndFrame.size.height + self.av_height - (self.commentTextField.av_height + 4 * 2));
}

- (void)endEditBlock {
    self.likeButton.hidden = NO;
    self.linkMicButton.hidden = NO;
    self.backgroundColor = self.backgroundColorForNormalNormal;
    self.commentTextField.av_width = 120;
    self.transform = CGAffineTransformIdentity;
}

// 重写该方法，使超出此view的输入框能响应点击事件
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (self.commentTextField.isFirstResponder && view != self.commentTextField) {
        [self.commentTextField resignFirstResponder];
    }
    return view;
}

@end
