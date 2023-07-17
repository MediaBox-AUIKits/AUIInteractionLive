//
//  AUILiveRoomAnchorBottomView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomAnchorBottomView.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"


@interface AUILiveRoomAnchorBottomView()

@property (strong, nonatomic) AUILiveRoomCommentTextField *commentTextField;

@property (strong, nonatomic) UIButton *beautyButton;
@property (strong, nonatomic) UIButton *linkMicButton;
@property (strong, nonatomic) UIButton *moreButton;

@property (strong, nonatomic) UILabel *linkMicNumberLabel;

@end

@implementation AUILiveRoomAnchorBottomView

- (instancetype)initWithFrame:(CGRect)frame linkMic:(BOOL)linkMic {
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat startY = 10;
        
        UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(self.av_right - 16 - 36, startY, 36, 36)];
        [moreButton setImage:AUIRoomGetCommonImage(@"ic_living_bottom_more") forState:UIControlStateNormal];
        moreButton.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
        [moreButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        moreButton.layer.masksToBounds = YES;
        moreButton.layer.cornerRadius = 18;
        [self addSubview:moreButton];
        self.moreButton = moreButton;
        
        if (linkMic) {
            UIButton *linkMicButton = [[UIButton alloc] initWithFrame:CGRectMake(moreButton.av_left - 12 - 36, startY, 36, 36)];
            [linkMicButton setImage:AUIRoomGetCommonImage(@"ic_living_bottom_link") forState:UIControlStateNormal];
            linkMicButton.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
            [linkMicButton addTarget:self action:@selector(linkButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            linkMicButton.layer.masksToBounds = YES;
            linkMicButton.layer.cornerRadius = 18;
            [self addSubview:linkMicButton];
            self.linkMicButton = linkMicButton;
            
            UILabel *linkMicNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            linkMicNumberLabel.font = AVGetRegularFont(12);
            linkMicNumberLabel.textAlignment = NSTextAlignmentCenter;
            linkMicNumberLabel.textColor = UIColor.whiteColor;
            linkMicNumberLabel.backgroundColor = [UIColor av_colorWithHexString:@"#F53F3F"];
            linkMicNumberLabel.layer.cornerRadius = 8;
            linkMicNumberLabel.layer.borderWidth = 1;
            linkMicNumberLabel.layer.borderColor = UIColor.whiteColor.CGColor;
            linkMicNumberLabel.layer.masksToBounds = YES;
            linkMicNumberLabel.userInteractionEnabled = NO;
            [self addSubview:linkMicNumberLabel];
            self.linkMicNumberLabel = linkMicNumberLabel;
            self.linkMicNumberLabel.hidden = YES;
        }
        
        UIButton *beautyButton = [[UIButton alloc] initWithFrame:CGRectMake((self.linkMicButton ? self.linkMicButton.av_left : self.moreButton.av_left) - 12 - 36, startY, 36, 36)];
        [beautyButton setImage:AUIRoomGetCommonImage(@"ic_living_bottom_beauty") forState:UIControlStateNormal];
        beautyButton.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
        [beautyButton addTarget:self action:@selector(beautyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        beautyButton.layer.masksToBounds = YES;
        beautyButton.layer.cornerRadius = 18;
        [self addSubview:beautyButton];
        self.beautyButton = beautyButton;
        
        AUILiveRoomCommentTextField *commentTextField = [[AUILiveRoomCommentTextField alloc] initWithFrame:CGRectMake(16, startY, 120, 36)];
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

- (void)updateLinkMicNumber:(NSUInteger)number {
    self.linkMicNumberLabel.hidden = number == 0;
    if (!self.linkMicNumberLabel.hidden) {
        NSString *text = number > 99 ? @"99+" : [NSString stringWithFormat:@"%tu", number];
        self.linkMicNumberLabel.text = text;
        
        [self.linkMicNumberLabel sizeToFit];
        CGFloat width = self.linkMicNumberLabel.av_width + 8;
        width = MAX(width, 16);
        self.linkMicNumberLabel.frame = CGRectMake(self.linkMicButton.av_left + 19, self.linkMicButton.av_top - 2, width, 16);
    }
}

#pragma mark --UIButton Selectors

- (void)beautyButtonAction:(UIButton *)sender {
    if (self.onBeautyButtonClickedBlock) {
        self.onBeautyButtonClickedBlock(self);
    }
}

- (void)moreButtonAction:(UIButton *)sender {
    if (self.onMoreButtonClickedBlock) {
        self.onMoreButtonClickedBlock(self);
    }
}

- (void)linkButtonAction:(UIButton *)sender {
    if (self.onLinkMicButtonClickedBlock) {
        self.onLinkMicButtonClickedBlock(self);
    }
}

- (void)willEditBlock:(CGRect)keyboardEndFrame {
    self.moreButton.hidden = YES;
    self.linkMicButton.hidden = YES;
    self.beautyButton.hidden = YES;
    self.backgroundColor = AUIFoundationColor(@"bg_weak");
    self.commentTextField.av_width = self.av_width - 16 * 2;
    self.transform = CGAffineTransformMakeTranslation(0, -keyboardEndFrame.size.height + self.av_height - (self.commentTextField.av_height + 10 * 2));
}

- (void)endEditBlock {
    self.moreButton.hidden = NO;
    self.linkMicButton.hidden = NO;
    self.beautyButton.hidden = NO;
    self.backgroundColor = UIColor.clearColor;
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
