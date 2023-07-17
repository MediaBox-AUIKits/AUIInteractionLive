//
//  AUILiveRoomPushStatusView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomPushStatusView.h"
#import "AUIFoundation.h"

@interface AUILiveRoomPushStatusView ()

@property (strong, nonatomic) UIView *flagView;
@property (strong, nonatomic) UILabel *statusLabel;

@end

@implementation AUILiveRoomPushStatusView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *flagView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.av_height - 4) / 2.0, 4, 4)];
        [self addSubview:flagView];
        self.flagView = flagView;
        
        UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(flagView.av_right + 4, 0, self.av_width - flagView.av_right - 4, self.av_height)];
        statusLabel.font = AVGetRegularFont(10);
        statusLabel.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        [self addSubview:statusLabel];
        self.statusLabel = statusLabel;
        
        self.pushStatus = AUILiveRoomPushStatusFluent;
    }
    return self;
}

- (void)setPushStatus:(AUILiveRoomPushStatus)pushStatus {
    _pushStatus = pushStatus;
    if (pushStatus == AUILiveRoomPushStatusFluent) {
        self.statusLabel.text = @"网络良好";
        self.flagView.backgroundColor = [UIColor av_colorWithHexString:@"#3BB346" alpha:1.0];
    }
    else if (pushStatus == AUILiveRoomPushStatusStuttering) {
        self.statusLabel.text = @"网络不佳";
        self.flagView.backgroundColor = [UIColor av_colorWithHexString:@"#FFC422" alpha:1.0];
    }
    else if (pushStatus == AUILiveRoomPushStatusBrokenOff) {
        self.statusLabel.text = @"网络异常";
        self.flagView.backgroundColor = [UIColor av_colorWithHexString:@"#F53F3F" alpha:1.0];
    }
}


@end
