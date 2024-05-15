//
//  AUILiveRoomProductCard.m
//  AUIInteractionLiveDemo
//
//  Created by Bingo on 2024/2/8.
//

#import "AUILiveRoomProductCard.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"

@interface AUILiveRoomProductCard ()

@property (strong, nonatomic) AVBlockButton* closeButton;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *infoLabel;

@end

@implementation AUILiveRoomProductCard

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 4.0;
        self.backgroundColor = UIColor.whiteColor;
        
        _imageView = [UIImageView new];
        _imageView.backgroundColor = AVTheme.fill_weak;
        [self addSubview:_imageView];
        
        
        _titleLabel = [UILabel new];
        _titleLabel.textColor = AVTheme.text_strong;
        _titleLabel.font = AVGetRegularFont(16);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        
        _infoLabel = [UILabel new];
        _infoLabel.textColor = UIColor.redColor;
        _infoLabel.font = AVGetRegularFont(20);
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_infoLabel];
        
        AVBlockButton* button = [[AVBlockButton alloc] initWithFrame:CGRectZero];
        button.layer.cornerRadius = 12;
        button.layer.masksToBounds = YES;
        [button setImage:AUIRoomGetCommonImage(@"ic_living_close") forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4] forState:UIControlStateNormal];
        [self addSubview:button];
        
        __weak typeof(self) weakSelf = self;
        button.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            if (weakSelf.onCloseButtonClickedBlock) {
                weakSelf.onCloseButtonClickedBlock(weakSelf);
            }
        };
        _closeButton = button;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
    _titleLabel.frame = CGRectMake(0, self.av_height - 20 - 8, self.av_width, 20);
    _infoLabel.frame = CGRectMake(0, _titleLabel.av_top - 32, self.av_width, 32);
    _closeButton.frame = CGRectMake(self.av_width - 16 - 24, 10, 24, 24);
}

- (void)setProduct:(AUIRoomProductModel *)product {
    _product = product;
    
    _titleLabel.text = _product.title;
    _infoLabel.text = _product.info;
}

@end
