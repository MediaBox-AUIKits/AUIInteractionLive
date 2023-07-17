//
//  AUILiveRoomNoticeButton.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/9.
//

#import "AUILiveRoomNoticeButton.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"

@interface AUILiveRoomNoticeButton ()

@property (nonatomic, assign) CGSize normalSize;
@property (nonatomic, assign) CGSize noticeSize;

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIButton *showButton;

@property (nonatomic, strong) UIView *noticeView;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UILabel *noticeLabel;

@end

@implementation AUILiveRoomNoticeButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = YES;
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 16, 16)];
        iconView.image = AUIRoomGetCommonImage(@"ic_living_notice");
        [self addSubview:iconView];
        self.iconView = iconView;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        textLabel.font = AVGetRegularFont(12);
        textLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        textLabel.text = @"公告";
        [textLabel sizeToFit];
        textLabel.frame = CGRectMake(iconView.av_right + 5, 2, textLabel.av_width, 18);
        [self addSubview:textLabel];
        self.textLabel = textLabel;
        
        UIButton *showButton = [[UIButton alloc] initWithFrame:CGRectMake(textLabel.av_right + 8, 4, 16, 16)];
        [showButton setImage:AUIRoomGetCommonImage(@"ic_living_notice_open") forState:UIControlStateNormal];
        [showButton addTarget:self action:@selector(onShowClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:showButton];
        self.showButton = showButton;
        
        self.normalSize = CGSizeMake(showButton.av_right + 4, 24);
        self.av_size = self.normalSize;
        self.noticeSize = CGSizeMake(150, 116);
    }
    return self;
}

- (UIView *)noticeView {
    if (!_noticeView) {
        _noticeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.noticeSize.width, self.noticeSize.height)];
        [self addSubview:_noticeView];
        [self sendSubviewToBack:_noticeView];
        
        if (self.enableEdit) {
            _editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
            [_editButton setImage:AUIRoomGetCommonImage(@"ic_living_notice_edit") forState:UIControlStateNormal];
            [_editButton addTarget:self action:@selector(onEditClicked) forControlEvents:UIControlEventTouchUpInside];
            [_noticeView addSubview:_editButton];
        }
        
        _noticeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _noticeLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        _noticeLabel.font = AVGetRegularFont(12);
        _noticeLabel.numberOfLines = 0;
        [_noticeView addSubview:_noticeLabel];
        
        [self updateNoticeContent];
    }
    return _noticeView;
}

- (void)updateNoticeContent {
    if (!_noticeView) {
        return;
    }
    
    if (_noticeContent.length == 0) {
        _noticeLabel.text = @"暂无公告";
        self.noticeSize = CGSizeMake(self.noticeSize.width, 116);
        CGSize size = [_noticeLabel sizeThatFits:CGSizeZero];
        CGFloat startX = (self.noticeSize.width - (size.width + 6 + _editButton.av_width)) / 2;
        CGFloat startY = self.normalSize.height + (self.noticeSize.height - self.normalSize.height) / 2  - size.height;
        _noticeLabel.frame = CGRectMake(startX, startY, size.width, size.height);
        _editButton.av_left = _noticeLabel.av_right + 6;
        _editButton.av_centerY = _noticeLabel.av_centerY;
        self.av_size = self.noticeSize;
        self.noticeView.av_size = self.noticeSize;
    }
    else {
        _editButton.av_top = 4;
        _editButton.av_right = _noticeView.av_width - 4;
        _noticeLabel.text = _noticeContent;
        CGSize size = [_noticeLabel sizeThatFits:CGSizeMake(self.noticeSize.width - 8, 0)];
        _noticeLabel.frame = CGRectMake(4, self.normalSize.height, size.width, size.height);
        self.noticeSize = CGSizeMake(self.noticeSize.width, _noticeLabel.av_bottom + 2);
        self.av_size = self.noticeSize;
        self.noticeView.av_size = self.noticeSize;
    }
}

- (void)setNoticeContent:(NSString *)noticeContent {
    _noticeContent = noticeContent;
    [self updateNoticeContent];
}

- (void)onShowClicked {
    self.showNoticeContent = !self.showNoticeContent;
}

- (void)onEditClicked {
    if (self.onEditNoticeContentBlock) {
        self.onEditNoticeContentBlock();
    }
}

- (void)setShowNoticeContent:(BOOL)showNoticeContent {
    if (showNoticeContent) {
        [self openNoticeContent];
    }
    else {
        [self closeNoticeContent];
    }
}

- (void)openNoticeContent {
    _showNoticeContent = YES;
    self.noticeView.hidden = NO;
    self.noticeView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.av_size = self.noticeSize;
        self.noticeView.alpha = 1.0;
        self.showButton.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)closeNoticeContent {
    _showNoticeContent = NO;
    _noticeView.alpha = 1;
    [UIView animateWithDuration:0.3 animations:^{
        self.av_size = self.normalSize;
        self->_noticeView.alpha = 0;
        self.showButton.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self->_noticeView.hidden = YES;
    }];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect showClickRect = CGRectMake(0, 0, self.normalSize.width, self.normalSize.height);
    if (CGRectContainsPoint(showClickRect, point)) {
        return self.showButton;
    }
    
    if (_editButton) {
        CGRect editRect = _editButton.frame;
        editRect = CGRectInset(editRect, 4, 4);
        if (CGRectContainsPoint(editRect, point)) {
            return _editButton;
        }
    }
    
    return [super hitTest:point withEvent:event];
}

@end
