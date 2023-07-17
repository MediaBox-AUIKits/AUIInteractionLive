//
//  AUILiveRoomAudienceLinkMicButton.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/18.
//

#import "AUILiveRoomAudienceLinkMicButton.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"

@interface AUILiveRoomAudienceLinkMicButton ()

@property (assign, nonatomic) BOOL expand;
@property (assign, nonatomic) BOOL needToCollapse;

@property (strong, nonatomic) AVBlockButton *mainButton;
@property (strong, nonatomic) UIView *splitView;
@property (strong, nonatomic) AVBlockButton *applyButton;
@property (strong, nonatomic) AVBlockButton *leaveButton;
@property (strong, nonatomic) AVBlockButton *audioButton;
@property (strong, nonatomic) AVBlockButton *videoButton;
@property (strong, nonatomic) AVBlockButton *cameraButton;

@property (assign, nonatomic) CGFloat rightPos;
@property (assign, nonatomic) CGFloat topPos;
@property (assign, nonatomic) CGFloat height;


@end

@implementation AUILiveRoomAudienceLinkMicButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
         
        self.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];

        _rightPos = self.av_right;
        _topPos = self.av_top;
        _height = 32;
        self.layer.cornerRadius = _height / 2.0;
        self.layer.masksToBounds = YES;
        
        _state = AUILiveRoomAudienceLinkMicButtonStateInit;
        _expand = NO;
        [self updateLayout];
    }
    return self;
}

- (void)setState:(AUILiveRoomAudienceLinkMicButtonState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    if (_state == AUILiveRoomAudienceLinkMicButtonStateJoin) {
        _expand = YES;
    }
    [self updateLayout];
    if (_state == AUILiveRoomAudienceLinkMicButtonStateApply || (_state == AUILiveRoomAudienceLinkMicButtonStateJoin && _expand)) {
        [self startCollapse];
    }
}

- (void)setExpand:(BOOL)expand {
    if (_expand == expand) {
        return;
    }
    _expand = expand;
    if (_state == AUILiveRoomAudienceLinkMicButtonStateJoin) {
        [self updateLayout];
        if (_expand) {
            [self startCollapse];
        }
    }
}

- (void)setAudioOff:(BOOL)audioOff {
    _audioOff = audioOff;
    _audioButton.selected = _audioOff;
}

- (void)setVideoOff:(BOOL)videoOff {
    _videoOff = videoOff;
    _videoButton.selected = _videoOff;
}

- (void)updateLayout {
    CGFloat width = 0;
    switch (_state) {
        case AUILiveRoomAudienceLinkMicButtonStateInit:
        {
            self.mainButton.hidden = NO;
            _splitView.hidden = YES;
            _applyButton.hidden = YES;
            _leaveButton.hidden = YES;
            _cameraButton.hidden = YES;
            _videoButton.hidden = YES;
            _audioButton.hidden = YES;
            
            self.mainButton.frame = CGRectMake(0, 0, self.height, self.height);
            self.mainButton.selected = NO;
            width = self.mainButton.av_right;
        }
            break;
        case AUILiveRoomAudienceLinkMicButtonStateApply:
        {
            self.mainButton.hidden = NO;
            self.splitView.hidden = NO;
            self.applyButton.hidden = NO;
            _leaveButton.hidden = YES;
            _cameraButton.hidden = YES;
            _videoButton.hidden = YES;
            _audioButton.hidden = YES;
            
            self.mainButton.frame = CGRectMake(0, 0, self.height, self.height);
            self.mainButton.selected = NO;
            self.splitView.av_left = self.mainButton.av_right;
            self.applyButton.frame = CGRectMake(self.splitView.av_right, 0, 76, self.height);
            self.applyButton.selected = NO;
            width = self.applyButton.av_right;
            
            [self startCollapse];
        }
            break;
        case AUILiveRoomAudienceLinkMicButtonStateApplyCancel:
        {
            self.mainButton.hidden = NO;
            self.splitView.hidden = NO;
            self.applyButton.hidden = NO;
            _leaveButton.hidden = YES;
            _cameraButton.hidden = YES;
            _videoButton.hidden = YES;
            _audioButton.hidden = YES;
            
            self.mainButton.frame = CGRectMake(0, 0, self.height, self.height);
            self.mainButton.selected = NO;
            self.splitView.av_left = self.mainButton.av_right;
            self.applyButton.frame = CGRectMake(self.splitView.av_right, 0, 76, self.height);
            self.applyButton.selected = YES;
            width = self.applyButton.av_right;
        }
            break;
        case AUILiveRoomAudienceLinkMicButtonStateJoin:
        {
            if (self.expand) {
                _mainButton.hidden = YES;
                self.splitView.hidden = NO;
                _applyButton.hidden = YES;
                self.leaveButton.hidden = NO;
                self.cameraButton.hidden = NO;
                self.videoButton.hidden = NO;
                self.audioButton.hidden = NO;
                
                self.audioButton.frame = CGRectMake(10, 0, self.height, self.height);
                self.audioButton.selected = self.audioOff;
                self.videoButton.frame = CGRectMake(self.audioButton.av_right, 0, self.height, self.height);
                self.videoButton.selected = self.videoOff;
                self.cameraButton.frame = CGRectMake(self.videoButton.av_right, 0, self.height, self.height);
                self.splitView.av_left = self.cameraButton.av_right;
                self.leaveButton.frame = CGRectMake(self.splitView.av_right, 0, 52, self.height);
                width = self.leaveButton.av_right;
            }
            else {
                self.mainButton.hidden = NO;
                _splitView.hidden = YES;
                _applyButton.hidden = YES;
                _leaveButton.hidden = YES;
                _cameraButton.hidden = YES;
                _videoButton.hidden = YES;
                _audioButton.hidden = YES;
                
                self.mainButton.frame = CGRectMake(0, 0, self.height, self.height);
                self.mainButton.selected = YES;
                width = self.mainButton.av_right;
            }
        }
            break;
            
        default:
            break;
    }
    self.frame = CGRectMake(self.rightPos - width, self.topPos, width, self.height);
}

- (AVBlockButton *)mainButton {
    if (!_mainButton) {
        AVBlockButton *mainButton = [[AVBlockButton alloc] initWithFrame:CGRectZero];
        mainButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [mainButton setImage:AUIRoomGetCommonImage(@"ic_living_bottom_link") forState:UIControlStateNormal];
        [mainButton setBackgroundColor:UIColor.clearColor forState:UIControlStateNormal];
        [mainButton setBackgroundColor:AUIRoomColourfulFillStrong forState:UIControlStateSelected];
        [self addSubview:mainButton];
        _mainButton = mainButton;
        
        __weak typeof(self) weakSelf = self;
        _mainButton.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            if (weakSelf.state == AUILiveRoomAudienceLinkMicButtonStateInit) {
                weakSelf.state = AUILiveRoomAudienceLinkMicButtonStateApply;
            }
            else if (weakSelf.state == AUILiveRoomAudienceLinkMicButtonStateApply) {
                weakSelf.state = AUILiveRoomAudienceLinkMicButtonStateInit;
            }
            else if (weakSelf.state == AUILiveRoomAudienceLinkMicButtonStateJoin) {
                weakSelf.expand = YES;
            }
        };
    }
    return _mainButton;
}

- (UIView *)splitView {
    if (!_splitView) {
        _splitView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, 1, 16)];
        _splitView.backgroundColor = [UIColor av_colorWithHexString:@"#FCFCFD" alpha:0.4];
        [self addSubview:_splitView];
    }
    return _splitView;
}

- (AVBlockButton *)applyButton {
    if (!_applyButton) {
        AVBlockButton *applyButton = [[AVBlockButton alloc] initWithFrame:CGRectZero];
        applyButton.titleLabel.font = AVGetMediumFont(12);
        [applyButton setTitleColor:[UIColor av_colorWithHexString:@"#FCFCFD"] forState:UIControlStateNormal];
        [applyButton setTitle:@"申请连麦" forState:UIControlStateNormal];
        [applyButton setTitle:@"取消连麦" forState:UIControlStateSelected];
        [self addSubview:applyButton];
        _applyButton = applyButton;
        
        __weak typeof(self) weakSelf = self;
        _applyButton.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            if (weakSelf.state == AUILiveRoomAudienceLinkMicButtonStateApply) {
                if (weakSelf.onApplyBlock) {
                    weakSelf.onApplyBlock(weakSelf);
                }
            }
            else if (weakSelf.state == AUILiveRoomAudienceLinkMicButtonStateApplyCancel) {
                if (weakSelf.onApplyCancelBlock) {
                    weakSelf.onApplyCancelBlock(weakSelf);
                }
            }
        };
    }
    return _applyButton;
}

- (AVBlockButton *)leaveButton {
    if (!_leaveButton) {
        AVBlockButton *leaveButton = [[AVBlockButton alloc] initWithFrame:CGRectZero];
        leaveButton.titleLabel.font = AVGetMediumFont(12);
        [leaveButton setTitleColor:[UIColor av_colorWithHexString:@"#FCFCFD"] forState:UIControlStateNormal];
        [leaveButton setTitle:@"挂断" forState:UIControlStateNormal];
        [self addSubview:leaveButton];
        _leaveButton = leaveButton;
        
        __weak typeof(self) weakSelf = self;
        _leaveButton.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            if (weakSelf.state == AUILiveRoomAudienceLinkMicButtonStateJoin) {
                if (weakSelf.onLeaveBlock) {
                    weakSelf.onLeaveBlock(weakSelf);
                }
            }
        };
    }
    return _leaveButton;
}

- (AVBlockButton *)audioButton {
    if (!_audioButton) {
        AVBlockButton *audioButton = [[AVBlockButton alloc] initWithFrame:CGRectZero];
        [audioButton setImage:AUIRoomGetCommonImage(@"ic_linkmic_audio") forState:UIControlStateNormal];
        [audioButton setImage:AUIRoomGetCommonImage(@"ic_linkmic_audio_selected") forState:UIControlStateSelected];
        [self addSubview:audioButton];
        _audioButton = audioButton;
        
        __weak typeof(self) weakSelf = self;
        _audioButton.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            if (weakSelf.state == AUILiveRoomAudienceLinkMicButtonStateJoin) {
                if (weakSelf.onSwitchAudioBlock) {
                    weakSelf.onSwitchAudioBlock(weakSelf, weakSelf.audioOff);
                }
            }
        };
    }
    return _audioButton;
}

- (AVBlockButton *)videoButton {
    if (!_videoButton) {
        AVBlockButton *videoButton = [[AVBlockButton alloc] initWithFrame:CGRectZero];
        [videoButton setImage:AUIRoomGetCommonImage(@"ic_linkmic_video") forState:UIControlStateNormal];
        [videoButton setImage:AUIRoomGetCommonImage(@"ic_linkmic_video_selected") forState:UIControlStateSelected];
        [self addSubview:videoButton];
        _videoButton = videoButton;
        
        __weak typeof(self) weakSelf = self;
        _videoButton.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            if (weakSelf.state == AUILiveRoomAudienceLinkMicButtonStateJoin) {
                if (weakSelf.onSwitchVideoBlock) {
                    weakSelf.onSwitchVideoBlock(weakSelf, weakSelf.videoOff);
                }
            }
        };
    }
    return _videoButton;
}

- (AVBlockButton *)cameraButton {
    if (!_cameraButton) {
        AVBlockButton *cameraButton = [[AVBlockButton alloc] initWithFrame:CGRectZero];
        [cameraButton setImage:AUIRoomGetCommonImage(@"ic_linkmic_camera") forState:UIControlStateNormal];
        [self addSubview:cameraButton];
        _cameraButton = cameraButton;
        
        __weak typeof(self) weakSelf = self;
        _cameraButton.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            if (weakSelf.state == AUILiveRoomAudienceLinkMicButtonStateJoin) {
                if (weakSelf.onSwitchCameraBlock) {
                    weakSelf.onSwitchCameraBlock(weakSelf);
                }
            }
        };
    }
    return _cameraButton;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (self.state == AUILiveRoomAudienceLinkMicButtonStateApply) {
        if (view.superview != self) {
            self.state = AUILiveRoomAudienceLinkMicButtonStateInit;
        }
    }
    else if (self.state == AUILiveRoomAudienceLinkMicButtonStateJoin && self.expand == YES) {
        if (view.superview != self) {
            self.expand = NO;
        }
    }
    return view;
}

// 定时任务，是否收起

- (void)startCollapse {
    [self cancelCollapse];
    [self performSelector:@selector(timeCollapse) withObject:nil afterDelay:5];
    self.needToCollapse = YES;
}

- (void)cancelCollapse {
    if (self.needToCollapse) {
        self.needToCollapse = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeCollapse) object:nil];
    }
}

- (void)timeCollapse {
    if (self.needToCollapse) {
        self.needToCollapse = NO;
        if (self.state == AUILiveRoomAudienceLinkMicButtonStateApply) {
            self.state = AUILiveRoomAudienceLinkMicButtonStateInit;
        }
        if (self.state == AUILiveRoomAudienceLinkMicButtonStateJoin && self.expand == YES) {
            self.expand = NO;
        }
    }
}

@end
