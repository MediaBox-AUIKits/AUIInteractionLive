//
//  AUILiveRoomAnchorPrestartView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomAnchorPrestartView.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"
#import <SDWebImage/SDWebImage.h>

@interface AUILiveRoomAnchorPrestartView()

@property (nonatomic, strong) UIView *infoView;
@property (nonatomic, strong) AVBlockButton *startLiveButton;
@property (nonatomic, strong) AVBaseButton *beautyButton;
@property (nonatomic, strong) AVBaseButton *switchCameraButton;
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation AUILiveRoomAnchorPrestartView

- (instancetype)initWithFrame:(CGRect)frame withModel:(nonnull AUIRoomLiveInfoModel *)model {
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *infoView = [[UIView alloc] initWithFrame:CGRectMake(16, 128, self.av_width - 16 * 2, 80)];
        infoView.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
        [self addSubview:infoView];
        _infoView = infoView;
        
        UIImageView *cover = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, 48, 48)];
        if (model.cover.length > 0) {
            [cover sd_setImageWithURL:[NSURL URLWithString:model.cover] placeholderImage:AUIRoomGetCommonImage(@"ic_room_cover")];
        }
        else {
            cover.image = AUIRoomGetCommonImage(@"ic_room_cover");
        }
        [infoView addSubview:cover];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(cover.av_right + 12, 16, infoView.av_width - cover.av_right - 12 - 16, 24)];
        title.text = model.title;
        title.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        title.font = AVGetRegularFont(16);
        [infoView addSubview:title];
        
        if (model.notice.length > 0) {
            UILabel *notice = [[UILabel alloc] initWithFrame:CGRectMake(cover.av_right + 12, title.av_bottom + 6, infoView.av_width - cover.av_right - 12 - 16, 18)];
            notice.text = model.notice;
            notice.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
            notice.font = AVGetRegularFont(12);
            [infoView addSubview:notice];
        }
        else {
            title.av_centerY = cover.av_centerY;
        }
        
        AVBlockButton *startLiveButton = [[AVBlockButton alloc] initWithFrame:CGRectMake(88, self.av_height - 55 - 44, self.av_width - 88 * 2, 44)];
        startLiveButton.layer.cornerRadius = 22;
        startLiveButton.titleLabel.font = AVGetRegularFont(16);
        [startLiveButton setTitle:@"开始直播" forState:UIControlStateNormal];
        [startLiveButton setTitleColor:[UIColor av_colorWithHexString:@"#FCFCFD"] forState:UIControlStateNormal];
        [startLiveButton setBackgroundColor:AUIRoomColourfulFillStrong forState:UIControlStateNormal];
        [self addSubview:startLiveButton];
        _startLiveButton = startLiveButton;
        
        AVBaseButton *beautyButton = [[AVBaseButton alloc] initWithType:AVBaseButtonTypeImageText titlePos:AVBaseButtonTitlePosBottom];
        beautyButton.frame = CGRectMake(25, startLiveButton.av_top, 40, 44);
        beautyButton.image = AUIRoomGetCommonImage(@"ic_living_beauty");
        beautyButton.title = @"美颜";
        beautyButton.font = AVGetRegularFont(12);
        beautyButton.color = [UIColor av_colorWithHexString:@"#FCFCFD"];
        [self addSubview:beautyButton];
        _beautyButton = beautyButton;
        
        AVBaseButton *switchCameraButton = [[AVBaseButton alloc] initWithType:AVBaseButtonTypeImageText titlePos:AVBaseButtonTitlePosBottom];
        switchCameraButton.frame = CGRectMake(self.av_width - 25 - 40, startLiveButton.av_top, 40, 44);
        switchCameraButton.image = AUIRoomGetCommonImage(@"ic_living_camera");
        switchCameraButton.title = @"翻转";
        switchCameraButton.font = AVGetRegularFont(12);
        switchCameraButton.color = [UIColor av_colorWithHexString:@"#FCFCFD"];
        [self addSubview:switchCameraButton];
        _switchCameraButton = switchCameraButton;
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
        timeLabel.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
        timeLabel.font = AVGetMediumFont(60);
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        timeLabel.layer.cornerRadius = 80;
        timeLabel.layer.masksToBounds = YES;
        timeLabel.hidden = YES;
        [self addSubview:timeLabel];
        self.timeLabel = timeLabel;
        self.timeLabel.center = CGPointMake(self.av_width / 2.0, self.av_height / 2.0);
        
        __weak typeof(self) weakSelf = self;
        startLiveButton.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            [weakSelf start];
        };
        beautyButton.action = ^(AVBaseButton * _Nonnull btn) {
            if (weakSelf.onBeautyBlock) {
                weakSelf.onBeautyBlock(weakSelf);
            }
        };
        switchCameraButton.action = ^(AVBaseButton * _Nonnull btn) {
            if (weakSelf.onSwitchCameraBlock) {
                weakSelf.onSwitchCameraBlock(weakSelf);
            }
        };
    }
    return self;
}

- (void)restore {
    self.infoView.hidden = NO;
    self.startLiveButton.hidden = NO;
    self.beautyButton.hidden = NO;
    self.switchCameraButton.hidden = NO;
    self.timeLabel.hidden = YES;
}

- (void)start {
    self.infoView.hidden = YES;
    self.startLiveButton.hidden = YES;
    self.beautyButton.hidden = YES;
    self.switchCameraButton.hidden = YES;
    self.timeLabel.hidden = NO;

    if (self.onWillStartLiveBlock) {
        if (!self.onWillStartLiveBlock(self)) {
            [self restore];
            return;
        }
    }
    
    [self timeToStart:3];
}

- (void)timeToStart:(NSUInteger)time {
    self.timeLabel.text = [NSString stringWithFormat:@"%tu", time];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSUInteger restTime = time - 1;
        if (restTime == 0) {
            if (self.onStartLiveBlock) {
                self.onStartLiveBlock(self);
            }
        }
        else {
            [self timeToStart:restTime];
        }
    });
}

@end
