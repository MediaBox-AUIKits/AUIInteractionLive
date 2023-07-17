//
//  AUIRoomVodPlayer.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/21.
//

#import "AUIRoomVodPlayer.h"
#import "AUIRoomSDKHeader.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"

@interface AUIRoomVodPlayer () <AVPDelegate>

@property (strong, nonatomic) AliPlayer *player;
@property (strong, nonatomic) UIView *playerDisplayView;
@property (assign, nonatomic) NSUInteger retryCount;
@property (nonatomic, assign) BOOL playReachEnd;
@property (nonatomic, assign) BOOL seekTimeChangedByMoving;
@property (nonatomic, assign) BOOL hiddenBottomView;

@property (nonatomic, weak) AVProgressHUD *loadingHud;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) CAGradientLayer *bottomViewLayer;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) AVSliderView *progressView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIButton *fullscreenButton;

@end

@implementation AUIRoomVodPlayer

- (void)dealloc {
    [self destory];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _bottomBarEdgeInset = UIEdgeInsetsMake(0, 0, AVSafeBottom, 0);
        
        UIView *playerDisplayView = [UIView new];
        [self addSubview:playerDisplayView];
        self.playerDisplayView = playerDisplayView;
        self.playerDisplayView.userInteractionEnabled = YES;
        [self.playerDisplayView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPlayerDisplayViewClicked:)]];
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:bottomView];
        CAGradientLayer *bottomViewLayer = [CAGradientLayer layer];
        bottomViewLayer.frame = bottomView.bounds;
        bottomViewLayer.colors = @[(id)[UIColor av_colorWithHexString:@"#141416" alpha:0].CGColor,(id)[UIColor av_colorWithHexString:@"#141416" alpha:0.7].CGColor];
        bottomViewLayer.startPoint = CGPointMake(0.5, 0);
        bottomViewLayer.endPoint = CGPointMake(0.5, 1);
        [bottomView.layer addSublayer:bottomViewLayer];
        self.bottomViewLayer = bottomViewLayer;
        self.bottomView = bottomView;

        UIButton *play = [[UIButton alloc] initWithFrame:CGRectZero];
        play.titleEdgeInsets = UIEdgeInsetsMake(18, 18, 18, 18);
        [play setImage:AUIRoomGetCommonImage(@"ic_player_play") forState:UIControlStateNormal];
        [play setImage:AUIRoomGetCommonImage(@"ic_player_pause") forState:UIControlStateSelected];
        [play addTarget:self action:@selector(onPlayBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:play];
        self.playButton = play;
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        timeLabel.text = @"00:00:00";
        timeLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        timeLabel.font = AVGetRegularFont(10);
        timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.bottomView addSubview:timeLabel];
        self.timeLabel = timeLabel;

        __weak typeof(self) weakSelf = self;
        AVSliderView *progressView = [[AVSliderView alloc] initWithFrame:CGRectZero];
        progressView.thumbTintColor = UIColor.whiteColor;
        progressView.minimumTrackTintColor = AUIRoomColourfulFillStrong;
        progressView.maximumTrackTintColor = [UIColor av_colorWithHexString:@"#FCFCFD" alpha:0.4];
        progressView.onValueChangedByGesture = ^(float progress, UIGestureRecognizer * _Nonnull gesture) {
            [weakSelf onValueChanged:progress gesture:gesture];
            
        };
        [self.bottomView addSubview:progressView];
        self.progressView = progressView;
        
        UILabel *durationLabel = [UILabel new];
        durationLabel.text = @"00:00:00";
        durationLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        durationLabel.font = AVGetRegularFont(10);
        durationLabel.textAlignment = NSTextAlignmentCenter;
        [self.bottomView addSubview:durationLabel];
        self.durationLabel = durationLabel;
        
        UIButton *fullscreen = [[UIButton alloc] initWithFrame:CGRectZero];
        fullscreen.titleEdgeInsets = UIEdgeInsetsMake(18, 18, 18, 18);
        [fullscreen setImage:AUIRoomGetCommonImage(@"ic_player_fullscreen") forState:UIControlStateNormal];
        [fullscreen setImage:AUIRoomGetCommonImage(@"ic_player_fullscreen_selected") forState:UIControlStateSelected];
        [fullscreen addTarget:self action:@selector(onFullscreenBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:fullscreen];
        self.fullscreenButton = fullscreen;
        self.hiddenFullscreenBtn = YES;
    }
    return self;
 }

- (void)setBottomBarEdgeInset:(UIEdgeInsets)bottomBarEdgeInset {
    _bottomBarEdgeInset = bottomBarEdgeInset;
    [self setNeedsLayout];
}

- (void)setIsFullScreen:(BOOL)isFullScreen {
    _isFullScreen = isFullScreen;
    self.fullscreenButton.selected = _isFullScreen;
}

- (void)setHiddenFullscreenBtn:(BOOL)hiddenFullscreenBtn {
    self.fullscreenButton.hidden = hiddenFullscreenBtn;
}

- (BOOL)hiddenFullscreenBtn {
    return self.fullscreenButton.hidden;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playerDisplayView.frame = self.bounds;
    
    CGFloat height = self.bottomBarEdgeInset.bottom + 56;
    self.bottomView.frame = CGRectMake(self.bottomBarEdgeInset.left, self.av_height - height, self.av_width - (self.bottomBarEdgeInset.left + self.bottomBarEdgeInset.right), height);
    self.bottomViewLayer.frame = self.bottomView.bounds;
    self.playButton.frame = CGRectMake(8, 8, 40, 40);
    CGFloat fullscreenButtonWidth = self.hiddenFullscreenBtn ? 0 : 40;
    self.fullscreenButton.frame = CGRectMake(self.bottomView.av_width - 8 - fullscreenButtonWidth, 8, fullscreenButtonWidth, 40);
    self.timeLabel.frame = CGRectMake(self.playButton.av_right, 16, 58, 24);
    self.durationLabel.frame = CGRectMake(self.fullscreenButton.av_left - 50, 16, 50, 24);
    self.progressView.frame = CGRectMake(self.timeLabel.av_right, 16, self.durationLabel.av_left - self.timeLabel.av_right, 24);
}

- (void)onPlayerDisplayViewClicked:(UITapGestureRecognizer *)recoginizer {
    self.hiddenBottomView = !self.hiddenBottomView;
}

- (void)setHiddenBottomView:(BOOL)hiddenBottomView {
    if (_hiddenBottomView == hiddenBottomView) {
        return;
    }
    _hiddenBottomView = hiddenBottomView;
    self.bottomView.hidden = _hiddenBottomView;
    if (self.onBottomViewHiddenBlock) {
        self.onBottomViewHiddenBlock(self, _hiddenBottomView);
    }
}

- (void)onPlayBtnClicked:(UIButton *)sender {
    [self pause:self.playButton.selected];
}

- (void)onFullscreenBtnClicked:(UIButton *)sender {
    if (self.onFullScreenButtonClickBlock) {
        self.onFullScreenButtonClickBlock(self, !self.fullscreenButton.selected);
    }
}

- (void)onValueChanged:(float)value gesture:(UIGestureRecognizer *)gesture {
    switch(gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.seekTimeChangedByMoving = YES;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            
//            [self.player seekToTime:self.progressView.value * 1000 seekMode:AVP_SEEKMODE_INACCURATE];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            int64_t timePos = self.progressView.value * 1000;
            if (timePos > self.player.duration - 1) {
                timePos = self.player.duration - 1;
            }
            NSLog(@"player:seekToTime:%lld, duration:%lld", timePos, self.player.duration);
            [self.player seekToTime:timePos seekMode:AVP_SEEKMODE_ACCURATE];
            self.seekTimeChangedByMoving = NO;
        }
            break;
        default:
            break;
    }
}

- (void)startLoading {
    if (!self.loadingHud) {
        self.loadingHud = [AVProgressHUD ShowHUDAddedTo:self animated:YES];
    }
}

- (void)endLoading {
    [self.loadingHud hideAnimated:YES];
}

- (void)setVodInfoModel:(AUIRoomLiveVodInfoModel *)vodInfoModel {
    _vodInfoModel = vodInfoModel;
    [self destory];
    [self prepare];
}

- (void)prepare {
    AVPConfig *config = [[AVPConfig alloc] init];
    config.networkTimeout = 5000;
    config.networkRetryCount = 5;
    
    _player = [[AliPlayer alloc] init];
    [_player setConfig:config];
    _player.delegate = self;
    _player.autoPlay = YES;
    _player.scalingMode = self.scaleAspectFit ? AVP_SCALINGMODE_SCALEASPECTFIT : AVP_SCALINGMODE_SCALEASPECTFILL;
    [_player setPlayerView:self.playerDisplayView];
}

- (void)start {
    if (!_player) {
        return;
    }
    
    [_player stop];
    self.playReachEnd = NO;
    if (self.vodInfoModel.isValid) {
        [_player setUrlSource:[[AVPUrlSource alloc] urlWithString:self.vodInfoModel.play_url]];
        [self startLoading];
        if (self.onPrepareStartBlock) {
            self.onPrepareStartBlock();
        }
        [_player prepare];
        self.playButton.selected = YES;
    }
    else {
        [AVAlertController show:@"播放失败，播放地址无效"];
    }
}

- (void)stop {
    if (!_player) {
        return;
    }
    
    [_player stop];
}

- (void)pause:(BOOL)pause {
    if (pause) {
        [self.player pause];
    }
    else {
        if (self.playReachEnd) {
            [self start];
        }
        else {
            [self.player start];
        }
    }
    self.playButton.selected = !pause;
}

- (void)destory {
    [_player stop];
    [_player clearScreen];
    _player.playerView = nil;
    [_player destroy];
    _player = nil;
}

#pragma mark - AVPDelegate
-(void)onPlayerEvent:(AliPlayer*)player eventType:(AVPEventType)eventType {
    switch (eventType) {
        case AVPEventPrepareDone: {
            [self endLoading];
            if (self.onPrepareDoneBlock) {
                self.onPrepareDoneBlock();
            }
            self.retryCount = 0;
            self.timeLabel.text = @"00:00:00";
            self.progressView.maximumValue = self.player.duration / 1000.0;
            self.durationLabel.text = [AVStringFormat format2WithDuration:self.player.duration / 1000.0];
        }
            break;
        case AVPEventLoadingStart: {
            [self startLoading];
            if (self.onLoadingStartBlock) {
                self.onLoadingStartBlock();
            }
        }
            break;
        case AVPEventLoadingEnd: {
            [self endLoading];
            if (self.onLoadingEndBlock) {
                self.onLoadingEndBlock();
            }
        }
            break;
        case AVPEventCompletion: {
            self.playReachEnd = YES;
            self.hiddenBottomView = NO;
            self.playButton.selected = NO;
        }
            break;
            
        default:
            break;
    }
}

- (void)onCurrentPositionUpdate:(AliPlayer*)player position:(int64_t)position {
//    NSLog(@"player:onCurrentPositionUpdate:%lld, duration:%lld, pos:%lld", self.player.currentPosition, self.player.duration, position);
    self.timeLabel.text = [AVStringFormat format2WithDuration:position / 1000.0];
    if (!self.seekTimeChangedByMoving) {
        self.progressView.value = position / 1000.0;
//        NSLog(@"player:valueUpdate:%f, duration:%f", self.progressView.value, self.progressView.maximumValue);
    }
}

- (void)onError:(AliPlayer *)player errorModel:(AVPErrorModel *)errorModel {
    if (self.retryCount < 10) {
        if (self.onPlayErrorBlock) {
            self.onPlayErrorBlock(YES);
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self start];
        });
        self.retryCount++;
        return;
    }
    [self.player stop];

    [self endLoading];
    if (self.onPlayErrorBlock) {
        self.onPlayErrorBlock(NO);
    }
}

@end
