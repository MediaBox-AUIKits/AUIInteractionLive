//
//  AUILiveRoomFinishView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/8.
//

#import "AUILiveRoomFinishView.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"
#import "AUIRoomVodPlayer.h"
#import "AUILiveRoomLikeButton.h"

@interface AUILiveRoomFinishView ()

@property (nonatomic, assign) BOOL landscapeMode; // YES：横屏模式（企业直播）， NO：竖屏模式（互动直播）

@property (nonatomic, strong) UILabel* infoLabel;
@property (nonatomic, strong) AVBlockButton *replayBtn;

@property (nonatomic, strong) AUIRoomVodPlayer *player;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) AUILiveRoomLikeButton* likeButton;

@end

@implementation AUILiveRoomFinishView

- (void)dealloc {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame landscapeMode:NO];
}

- (instancetype)initWithFrame:(CGRect)frame landscapeMode:(BOOL)landscapeMode {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.landscapeMode = landscapeMode;
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.av_height - AVSafeTop - 56) / 2.0 + AVSafeTop, self.av_width, 22)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"直播已结束～";
        label.font = AVGetRegularFont(16);
        label.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        [self addSubview:label];
        self.infoLabel = label;
        
        AVBlockButton *replayBtn = [[AVBlockButton alloc] initWithFrame:CGRectMake(0, label.av_bottom, self.av_width, 22 + 12 * 2)];
        replayBtn.titleLabel.font = AVGetRegularFont(16);
        [replayBtn setTitleColor:[UIColor av_colorWithHexString:@"#FCFCFD"] forState:UIControlStateNormal];
        [replayBtn setImage:AUIRoomGetCommonImage(@"ic_living_playback") forState:UIControlStateNormal];
        [replayBtn setTitle:@"回放" forState:UIControlStateNormal];
        [replayBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
        [self addSubview:replayBtn];
        _replayBtn = replayBtn;
        
        __weak typeof(self) weakSelf = self;
        replayBtn.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            [weakSelf startToPlay];
        };
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.infoLabel.frame = CGRectMake(0, (self.av_height - AVSafeTop - 56) / 2.0 + AVSafeTop, self.av_width, 22);
    self.replayBtn.frame = CGRectMake(0, self.infoLabel.av_bottom, self.av_width, 22 + 12 * 2);
    
    CGFloat safeLeft = UIView.av_isIphoneX ? 48 : 0;
    CGFloat safeRight = UIView.av_isIphoneX ? 34 : 0;
    if (self.isFullScreen) {
        self.player.bottomBarEdgeInset = UIEdgeInsetsMake(0, safeLeft, AVSafeBottom, safeRight);
        self.player.frame = self.bounds;
    }
    else {
        CGFloat top = self.landscapeMode ? AVSafeTop : 0;
        self.player.bottomBarEdgeInset = UIEdgeInsetsMake(0, 0, self.landscapeMode ? 0 : AVSafeBottom, 0);
        self.player.frame = CGRectMake(0, top, self.av_width, self.av_height - top);
        
    }
}

- (void)setVodModel:(AUIRoomLiveVodInfoModel *)vodModel {
    _vodModel = vodModel;
    self.replayBtn.hidden = !_vodModel.isValid;
}

- (void)setIsFullScreen:(BOOL)isFullScreen {
    _isFullScreen = isFullScreen;
    self.player.isFullScreen = isFullScreen;
}

- (void)startToPlay {
    self.infoLabel.hidden = YES;
    self.replayBtn.hidden = YES;
    self.backgroundColor = UIColor.blackColor;
    CGFloat top = self.landscapeMode ? AVSafeTop : 0;
    self.player = [[AUIRoomVodPlayer alloc] initWithFrame:CGRectMake(0, top, self.av_width, self.av_height - top)];
    self.player.scaleAspectFit = self.landscapeMode;
    self.player.bottomBarEdgeInset = UIEdgeInsetsMake(0, 0, self.landscapeMode ? 0 : AVSafeBottom, 0);
    self.player.hiddenFullscreenBtn = !self.landscapeMode;
    self.player.isFullScreen = self.isFullScreen;
    __weak typeof(self) weakSelf = self;
    self.player.onBottomViewHiddenBlock = ^(AUIRoomVodPlayer * _Nonnull sender, BOOL hidden) {
        weakSelf.shareButton.hidden = hidden;
        weakSelf.likeButton.hidden = hidden;
        if (weakSelf.onPlayImmerseBlock) {
            weakSelf.onPlayImmerseBlock(weakSelf, hidden);
        }
    };
    self.player.onFullScreenButtonClickBlock = ^(AUIRoomVodPlayer * _Nonnull sender, BOOL fullScreen) {
        if (weakSelf.onPlayFullScreenBlock) {
            weakSelf.onPlayFullScreenBlock(weakSelf, fullScreen);
        }
    };
    [self addSubview:self.player];
    
    self.player.vodInfoModel = self.vodModel;
    [self.player start];
    
    if (!self.isAnchor && !self.landscapeMode) {
        AUILiveRoomLikeButton *likeButton = [[AUILiveRoomLikeButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        [likeButton setImage:AUIRoomGetCommonImage(@"ic_living_bottom_like") forState:UIControlStateNormal];
        likeButton.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
        [likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        likeButton.layer.masksToBounds = YES;
        likeButton.layer.cornerRadius = 18;
        [self addSubview:likeButton];
        self.likeButton = likeButton;
        
        UIButton* shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        [shareButton setImage:AUIRoomGetCommonImage(@"ic_living_bottom_share") forState:UIControlStateNormal];
        shareButton.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
        [shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        shareButton.layer.masksToBounds = YES;
        shareButton.layer.cornerRadius = 18;
        [self addSubview:shareButton];
        self.shareButton = shareButton;
        
        self.likeButton.frame = CGRectMake(self.av_width - 36 - 16, self.av_height - AVSafeBottom - 56 - 4 - 36, 36, 36);
        self.shareButton.frame = CGRectMake(self.likeButton.av_left - 36 - 12, self.likeButton.av_top, 36, 36);
    }
}

- (void)likeButtonAction:(UIButton *)sender {
    if (self.onLikeButtonClickedBlock) {
        self.onLikeButtonClickedBlock(self);
    }
}

- (void)shareButtonAction:(UIButton *)sender {
    if (self.onShareButtonClickedBlock) {
        self.onShareButtonClickedBlock(self);
    }
}


@end
