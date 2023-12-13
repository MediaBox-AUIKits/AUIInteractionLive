//
//  AUIRoomLiveRtcPlayer.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/25.
//

#import "AUIRoomLiveRtcPlayer.h"
#import "AUIRoomSDKHeader.h"
#import "AUIFoundation.h"
#import <Masonry/Masonry.h>

@interface AUIRoomLiveRtcPlayer () <AliLivePlayerDelegate>

@property (strong, nonatomic) AlivcLivePlayer *player;

@property (strong, nonatomic) AVBlockButton *infoButton;

@end

@implementation AUIRoomLiveRtcPlayer

@synthesize displayView = _displayView;

- (AUIRoomDisplayView *)displayView {
    if (!_displayView) {
        _displayView = [[AUIRoomDisplayView alloc] initWithFrame:CGRectZero];
        _displayView.showLoadingIndicator = NO;
        _displayView.loadingText = @"连接中，请耐心等待";
    }
    return _displayView;
}

- (AVBlockButton *)infoButton {
    if (!_infoButton) {
        _infoButton = [[AVBlockButton alloc] initWithFrame:self.displayView.bounds];
        [_infoButton setTitleColor:AUIFoundationColor(@"text_weak") forState:UIControlStateNormal];
        _infoButton.titleLabel.font = AVGetRegularFont(12);
        _infoButton.titleLabel.numberOfLines = 0;
        _infoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.displayView addSubview:_infoButton];
        [_infoButton mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.edges.equalTo(self.displayView);
        }];
        
        __weak typeof(self) weakSelf = self;
        _infoButton.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            weakSelf.infoButton.hidden = YES;
            [weakSelf start];
        };
    }
    return _infoButton;
}

#pragma mark - live play

- (void)prepare {
    AlivcLivePlayConfig *playConfig = [[AlivcLivePlayConfig alloc] init];
    playConfig.renderMode = AlivcLivePlayRenderModeCrop;
    
    _player = [[AlivcLivePlayer alloc] init];
    [_player setLivePlayerDelegate:self];
    [_player setPlayView:self.displayView.renderView  playCofig:playConfig];
}

- (BOOL)start {
    [_player stopPlay];
    if (self.joinInfo.rtcPullUrl.length > 0) {
        [_player startPlayWithURL:self.joinInfo.rtcPullUrl];
        [self.displayView startLoading];
        return YES;
    }
    self.infoButton.hidden = NO;
    [self.infoButton setTitle:@"连接失败" forState:UIControlStateNormal];
    return NO;
}

- (void)destory {
    [_player stopPlay];
    _player = nil;
}

#pragma mark - AliLivePlayerDelegate

- (void)onError:(AlivcLivePlayer *)player code:(AlivcLivePlayerError)code message:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *title = msg ?: @"未知错误\n点击重试？";
        if (code == AlivcLivePlayErrorStreamNotFound) {
            title = [NSString stringWithFormat:@"找不到播放流\n点击重试？"];
        } else if (code == AlivcLivePlayErrorStreamStopped) {
            title = [NSString stringWithFormat:@"播放流已停止\n点击重试？"];
        }
        [self.infoButton setTitle:title forState:UIControlStateNormal];
        self.infoButton.hidden = NO;

        [self.player stopPlay];
        if (self.onPlayErrorBlock) {
            self.onPlayErrorBlock();
        }
        [self.displayView endLoading];
    });
}

- (void)onPlayStarted:(AlivcLivePlayer *)player {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.displayView endLoading];
    });
}

- (void)onPlayStoped:(AlivcLivePlayer *)player {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.displayView endLoading];
    });
}

- (void)onFirstVideoFrameDrawn:(AlivcLivePlayer *)player {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"RtcPlayerEvent:onFirstVideoFrameDrawn");
    });
}

- (void)onPlayoutVolumeUpdate:(AlivcLivePlayer *)player volume:(int)volume speechState:(BOOL)isSpeaking {
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"RtcPlayerEvent:onPlayoutVolumeUpdate volume:%d isSpeaking:%d", volume, isSpeaking);
    });
}

@end
