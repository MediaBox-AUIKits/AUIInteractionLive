//
//  AUIRoomDisplayView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/28.
//

#import "AUIRoomDisplayView.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"

@interface AUIRoomDisplayView ()

@property (nonatomic, strong) UIView *renderView;

@property (nonatomic, strong) UIView *userInfoView;
@property (nonatomic, strong) CAGradientLayer *userInfoViewLayer;

@property (nonatomic, strong) UILabel *anchorFlag;
@property (nonatomic, strong) UIButton *nickNameLabel;

@property (nonatomic, weak) AVProgressHUD *loadingHud;
@property (nonatomic, strong) UILabel *loadingLabel;

@property (nonatomic, assign) BOOL showBackground;
@property (nonatomic, assign) BOOL showBorder;
@property (nonatomic, assign) BOOL showRadius;
@property (nonatomic, assign) BOOL showUserInfo;

@end

@implementation AUIRoomDisplayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _renderView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_renderView];
        
        _userInfoView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_userInfoView];
        _userInfoViewLayer = [CAGradientLayer layer];
        _userInfoViewLayer.frame = _userInfoView.bounds;
        _userInfoViewLayer.colors = @[(id)AUIFoundationColor(@"tsp_fill_strong").CGColor,(id)AUIFoundationColor(@"tsp_fill_medium").CGColor];
        _userInfoViewLayer.startPoint = CGPointMake(0.5, 0);
        _userInfoViewLayer.endPoint = CGPointMake(0.5, 1);
        [_userInfoView.layer addSublayer:_userInfoViewLayer];
        
        _anchorFlag = [[UILabel alloc] initWithFrame:CGRectZero];
        _anchorFlag.font = AVGetRegularFont(12);
        _anchorFlag.textColor = [UIColor av_colorWithHexString:@"#FCFCFC"];
        _anchorFlag.text = @"主播";
        _anchorFlag.textAlignment = NSTextAlignmentCenter;
        _anchorFlag.backgroundColor = AUIRoomColourfulFillStrong;
        _anchorFlag.layer.cornerRadius = 2;
        _anchorFlag.layer.masksToBounds = YES;
        [_userInfoView addSubview:_anchorFlag];
        
        _nickNameLabel = [[UIButton alloc] initWithFrame:CGRectZero];
        _nickNameLabel.userInteractionEnabled = NO;
        _nickNameLabel.titleLabel.font = AVGetRegularFont(12);
        _nickNameLabel.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _nickNameLabel.backgroundColor = AUIFoundationColor(@"tsp_fill_infrared");
        _nickNameLabel.layer.cornerRadius = 2;
        _nickNameLabel.layer.masksToBounds = YES;
        [_nickNameLabel setTitleColor:[UIColor av_colorWithHexString:@"#3A3D48"] forState:UIControlStateNormal];
        [_nickNameLabel setImage:AUIRoomGetCommonImage(@"ic_linkmic_win_audio") forState:UIControlStateNormal];
        [_nickNameLabel setImage:AUIRoomGetCommonImage(@"ic_linkmic_win_audio_selected") forState:UIControlStateSelected];
        [_userInfoView addSubview:_nickNameLabel];
        
        self.layer.borderColor = [UIColor av_colorWithHexString:@"#3A3D48"].CGColor;
        self.layer.masksToBounds = YES;
        self.showBackground = NO;
        self.showBorder = NO;
        self.showRadius = NO;
        
        self.isAnchor = NO;
        self.showUserInfo = NO;
        
        self.showLoadingIndicator = YES;
        self.loadingText = @"加载中...";
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _renderView.frame = self.bounds;
    
    _userInfoView.frame = CGRectMake(0, self.av_height - 30, self.av_width, 30);
    _userInfoViewLayer.frame = _userInfoView.bounds;
    _anchorFlag.frame = CGRectMake(4, _userInfoView.av_height - 4 - 20, 32, 20);
    [_nickNameLabel sizeToFit];
    CGFloat x = self.isAnchor ? _anchorFlag.av_right + 2 : 4;
    _nickNameLabel.frame = CGRectMake(x, _anchorFlag.av_top, MIN(_nickNameLabel.av_width + 8, _userInfoView.av_width - x - 4), 20);
    
    _loadingLabel.frame = self.bounds;
    [_loadingHud layoutSubviews];
}

- (UILabel *)loadingLabel {
    if (!_loadingLabel) {
        _loadingLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _loadingLabel.text = self.loadingText;
        _loadingLabel.textColor = AUIFoundationColor(@"text_weak");
        _loadingLabel.font = AVGetRegularFont(12);
        _loadingLabel.textAlignment = NSTextAlignmentCenter;
        _loadingLabel.hidden = YES;
        [self addSubview:_loadingLabel];
    }
    return _loadingLabel;
}

- (void)setLoadingText:(NSString *)loadingText {
    _loadingText = loadingText;
    _loadingHud.labelText = _loadingText;
    _loadingLabel.text = _loadingText;
}

- (void)startLoading {
    if (self.showLoadingIndicator) {
        if (!self.loadingHud) {
            self.loadingHud = [AVProgressHUD ShowHUDAddedTo:self animated:YES];
            self.loadingHud.labelText = self.loadingText;
        }
        _loadingLabel.hidden = YES;
    }
    else {
        [_loadingHud hideAnimated:YES];
        self.loadingLabel.hidden = NO;
    }
}

- (void)endLoading {
    [_loadingHud hideAnimated:YES];
    _loadingLabel.hidden = YES;
}

- (void)setShowBackground:(BOOL)showBackground {
    _showBackground = showBackground;
    if (_showBackground) {
        self.backgroundColor = AUIFoundationColor(@"fill_strong");
    }
    else {
        self.backgroundColor = UIColor.clearColor;
    }
}

- (void)setIsAnchor:(BOOL)isAnchor {
    _isAnchor = isAnchor;
    _anchorFlag.hidden = !_isAnchor;
    [self setNeedsLayout];
}

- (void)setIsAudioOff:(BOOL)isAudioOff {
    _nickNameLabel.selected = isAudioOff;
}

- (BOOL)isAudioOff {
    return _nickNameLabel.selected;
}

- (void)setNickName:(NSString *)nickName {
    if ([_nickName isEqualToString:nickName]) {
        return;
    }
    _nickName = nickName;
    [_nickNameLabel setTitle:_nickName ?: @"" forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)setShowBorder:(BOOL)showBorder {
    _showBorder = showBorder;
    if (_showBorder) {
        self.layer.borderWidth = 1;
    }
    else {
        self.layer.borderWidth = 0;
    }
}

- (void)setShowRadius:(BOOL)showRadius {
    _showRadius = showRadius;
    if (_showRadius) {
        self.layer.cornerRadius = 2;
    }
    else {
        self.layer.cornerRadius = 0;
    }
}

- (void)setShowUserInfo:(BOOL)showUserInfo {
    _showUserInfo = showUserInfo;
    self.userInfoView.hidden = !_showUserInfo;
}

@end



@interface AUIRoomDisplayLayoutView ()

@property (nonatomic, strong) NSMutableArray<AUIRoomDisplayView *> *viewList;
@property (nonatomic, strong) UIScrollView *scrollView;


@end

@implementation AUIRoomDisplayLayoutView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
//        _scrollView.bounces = NO;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
//        _scrollView.alwaysBounceVertical = YES;
//        _scrollView.alwaysBounceHorizontal = YES;
        [self addSubview:_scrollView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = UIEdgeInsetsInsetRect(self.bounds, self.contentInsets);
    [self layoutAll];
}

- (NSArray<AUIRoomDisplayView *> *)displayViewList {
    return self.viewList;
}

- (NSMutableArray<AUIRoomDisplayView *> *)viewList {
    if (!_viewList) {
        _viewList = [NSMutableArray array];
    }
    return _viewList;
}

- (void)insertDisplayView:(AUIRoomDisplayView *)displayView atIndex:(NSUInteger)index {
    if ([self.viewList containsObject:displayView]) {
        return;
    }
    if (index < self.viewList.count) {
        AUIRoomDisplayView *indexView = [self.viewList objectAtIndex:index];
        [self.viewList insertObject:displayView atIndex:index];
        [self.scrollView insertSubview:displayView belowSubview:indexView];
    }
    else {
        [self addDisplayView:displayView];
    }
}

- (void)addDisplayView:(AUIRoomDisplayView *)displayView {
    if ([self.viewList containsObject:displayView]) {
        return;
    }
    [self.scrollView addSubview:displayView];
    [self.viewList addObject:displayView];
}

- (void)removeDisplayView:(AUIRoomDisplayView *)displayView {
    [displayView removeFromSuperview];
    [self.viewList removeObject:displayView];
}

- (CGRect)renderRect:(AUIRoomDisplayView *)displayView {
    CGRect canvasRect = CGRectMake(0, 0, self.resolution.width, self.resolution.height);
    CGSize displaySize = self.scrollView.bounds.size;
    CGFloat scale = canvasRect.size.width / displaySize.width;
    if (displaySize.width / displaySize.height < canvasRect.size.width / canvasRect.size.height) {
        scale = canvasRect.size.height / displaySize.height;
    }
    displaySize = CGSizeMake(displaySize.width * scale, displaySize.height * scale);
    
    
    CGRect displayRect = [self displayRect:displayView];
    CGFloat renderScale = displaySize.width / self.scrollView.bounds.size.width;
    CGRect renderRect = CGRectMake(displayRect.origin.x * renderScale, displayRect.origin.y * renderScale, displayRect.size.width * renderScale, displayRect.size.height * renderScale);
    renderRect.origin.x = renderRect.origin.x + (canvasRect.size.width - displaySize.width) / 2.0;
    renderRect.origin.y = renderRect.origin.y + (canvasRect.size.height - displaySize.height) / 2.0;
    
    return renderRect;
}

- (CGRect)displayRect:(AUIRoomDisplayView *)displayView {
    return [self displayRect1:displayView];  // 采用布局1
}

- (void)updateScrollViewContentSize {
    [self updateScrollViewContentSize1]; // 采用布局1
}

- (void)layoutAll {
    
    [self updateScrollViewContentSize];
    [self.viewList enumerateObjectsUsingBlock:^(AUIRoomDisplayView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = [self displayRect:obj];
        [obj layoutSubviews];
        if (obj.onLayoutUpdated) {
            obj.onLayoutUpdated();
        }
        
        if (self.viewList.count == 1 || self.isSmallWindow) {
            obj.showBackground = NO;
            obj.showBorder = NO;
            obj.showRadius = NO;
            obj.showUserInfo = NO;
        }
//        else if (self.viewList.count == 2) {
//            if (idx == 0) {
//                obj.showBackground = NO;
//                obj.showBorder = NO;
//                obj.showRadius = NO;
//                obj.showUserInfo = NO;
//            }
//            else {
//                obj.showBackground = YES;
//                obj.showBorder = YES;
//                obj.showRadius = YES;
//                obj.showUserInfo = YES;
//            }
//        }
        else {
            obj.showBackground = YES;
            obj.showBorder = YES;
            obj.showRadius = YES;
            obj.showUserInfo = YES;
        }
    }];
    
    if (self.onlayoutChangedBlock) {
        self.onlayoutChangedBlock(self);
    }
}

#pragma mark - 布局1

// 布局1: 2<x<=4，1行2个；4<x<=9，1行3个；9<x，1行4个；最后1行不足个数时居中
- (CGRect)displayRect1:(AUIRoomDisplayView *)displayView {
    if (![self.viewList containsObject:displayView]) {
        return CGRectZero;
    }
    
    if (self.isSmallWindow) {
        return self.scrollView.bounds;
    }
    
    if (self.viewList.count == 1) {
        return self.scrollView.bounds;
    }
    NSUInteger index = [self.viewList indexOfObject:displayView];
    if (index >= 16) {
        return CGRectZero;
    }
//    if (self.viewList.count == 2) {
//        if (index == 0) {
//            return self.scrollView.bounds;
//        }
//        CGFloat width = 120;
//        CGFloat height = 120;
//        return CGRectMake(CGRectGetMaxX(self.scrollView.bounds) - 4 - width, CGRectGetMaxY(self.scrollView.bounds) - 222 - height, width, height);
//    }
    
    NSInteger count_per_line = 4;
    if (self.viewList.count <= 4) {
        count_per_line = 2;
    }
    else if (self.viewList.count <= 9) {
        count_per_line = 3;
    }
    
    CGFloat top = AVSafeTop + 94;
    CGFloat left = 6;
    CGFloat margin = 1;
    CGFloat width = (CGRectGetWidth(self.scrollView.bounds) - left * 2 - margin) / count_per_line;
    CGFloat height = width;
    NSUInteger col = index % count_per_line;
    NSUInteger row = index / count_per_line;
    
    NSUInteger last_row = (self.viewList.count - 1) / count_per_line;
    if (row == last_row) {
        NSUInteger last_col = (self.viewList.count - 1) % count_per_line;
        left = (CGRectGetWidth(self.scrollView.bounds) - (last_col + 1) * width - last_col * margin) / 2.0;
    }
    
    return CGRectMake(left + col * (width + margin), top + row * (height + margin), width, height);
}

- (void)updateScrollViewContentSize1 {
    self.scrollView.contentSize = CGSizeMake(self.scrollView.av_width, self.scrollView.av_height);
}

#pragma mark - 布局2
// 布局2，1行2个，超出页面时使用滚动。暂不使用，代码保留
- (CGRect)displayRect2:(AUIRoomDisplayView *)displayView {
    if (![self.viewList containsObject:displayView]) {
        return CGRectZero;
    }
    if (self.viewList.count == 1) {
        return self.scrollView.bounds;
    }
    NSUInteger index = [self.viewList indexOfObject:displayView];
    if (self.viewList.count == 2) {
        if (index == 0) {
            return self.scrollView.bounds;
        }
        CGFloat width = CGRectGetWidth(self.scrollView.bounds) / 4.0;
        CGFloat height = width * self.resolution.height / self.resolution.width;
        return CGRectMake(CGRectGetMaxX(self.scrollView.bounds) - 16 - width, CGRectGetMaxY(self.scrollView.bounds) - 240 - 16 - height, width, height);
    }
    
    // 1行2个
    CGFloat left = 5;
    CGFloat margin = 1;
    CGFloat width = (CGRectGetWidth(self.scrollView.bounds) - left * 2 - margin) / 2.0;
    CGFloat height = width;
    CGFloat top = (CGRectGetHeight(self.scrollView.bounds) - margin - height * 2) / 2.0;
    NSUInteger hor_pos = index % 2;
    NSUInteger ver_pos = index / 2;
    return CGRectMake(left + hor_pos * (width + margin), top + ver_pos * (height + margin), width, height);
}

- (void)updateScrollViewContentSize2 {
    if (self.viewList.count > 2) {
        CGFloat left = 5;
        CGFloat margin = 1;
        CGFloat width = (CGRectGetWidth(self.scrollView.bounds) - left * 2 - margin) / 2.0;
//        CGFloat height = width * self.resolution.height / self.resolution.width;
        CGFloat height = width;
        CGFloat top = (CGRectGetHeight(self.scrollView.bounds) - margin - height * 2) / 2.0;
        NSUInteger ver_count = (self.viewList.count + 1) / 2;
        self.scrollView.contentSize = CGSizeMake(self.scrollView.av_width, height * ver_count + margin * (ver_count - 1) + top * 2);
    }
    else {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.av_width, self.scrollView.av_height);
    }
}

@end
