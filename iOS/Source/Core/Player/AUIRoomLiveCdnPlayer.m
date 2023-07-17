//
//  AUIRoomLiveCdnPlayer.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/25.
//

#import "AUIRoomLiveCdnPlayer.h"
#import "AUIRoomSDKHeader.h"
#import "AUIFoundation.h"

@interface AUIRoomLiveCdnPlayer () <AVPDelegate>

@property (strong, nonatomic) AliPlayer *player;
@property (assign, nonatomic) BOOL startCompleted;
@property (assign, nonatomic) BOOL playOnError;
@property (assign, nonatomic) BOOL isDestroy;

@property (assign, nonatomic) BOOL playRts;
@property (assign, nonatomic) BOOL canRts;

@end

@implementation AUIRoomLiveCdnPlayer

@synthesize displayView = _displayView;

static BOOL g_canRtsPull = YES;
+ (BOOL)canRtsPull {
    return g_canRtsPull;
}

+ (void)setCanRtsPull:(BOOL)canRtsPull {
    g_canRtsPull = canRtsPull;
}

- (AUIRoomDisplayView *)displayView {
    if (!_displayView) {
        _displayView = [[AUIRoomDisplayView alloc] initWithFrame:CGRectZero];
        _displayView.nickName = @"主播";
        _displayView.isAnchor = YES;
    }
    return _displayView;
}

- (void)setLiveInfoModel:(AUIRoomLiveInfoModel *)liveInfoModel {
    _liveInfoModel = liveInfoModel;
    
    BOOL canRts = NO;
    if (self.liveInfoModel.mode == AUIRoomLiveModeBase) {
        if (self.liveInfoModel.pull_url_info.rts_url.length > 0) {
            canRts = YES;
        }
    }
    if (self.liveInfoModel.mode == AUIRoomLiveModeLinkMic) {
        if (self.liveInfoModel.link_info.cdn_pull_info.rts_url.length > 0) {
            canRts = YES;
        }
    }
    if (!self.class.canRtsPull) {
        canRts = NO;
    }
    self.canRts = canRts;
    self.playRts = canRts;
    NSLog(@"cdn拉流：%@支持rts播放", self.canRts ? @"" : @"不");
}

#pragma mark - live play

- (AVPConfig *)rtsConfig {
    AVPConfig *config = [[AVPConfig alloc] init];
    [config setNetworkTimeout:15000];
    [config setMaxDelayTime:1000];
    [config setHighBufferDuration:10];
    [config setStartBufferDuration:10];
    [config setNetworkRetryCount:2];
//    [config setEnableSEI:YES];
    return config;
}

- (AVPConfig *)playConfig {
    AVPConfig *config = [[AVPConfig alloc] init];
    [config setNetworkTimeout:15000];
    [config setNetworkRetryCount:2];
//    [config setEnableSEI:YES];
    return config;
}

- (void)prepare {
    self.playOnError = NO;
    AVPConfig *config = self.playRts ? [self rtsConfig] : [self playConfig];

    _player = [[AliPlayer alloc] init];
    [_player setConfig:config];
    _player.delegate = self;
    _player.autoPlay = YES;
    _player.scalingMode = self.scaleAspectFit ?  AVP_SCALINGMODE_SCALEASPECTFIT : AVP_SCALINGMODE_SCALEASPECTFILL;
    [_player setPlayerView:self.displayView.renderView];
    
    self.isDestroy = NO;
}

- (BOOL)start {
    [_player stop];
    
    NSString *playUrl = nil;
    if (self.liveInfoModel.mode == AUIRoomLiveModeBase) {
        if (self.playRts) {
            playUrl = self.liveInfoModel.pull_url_info.rts_url;
        }
        else if (self.liveInfoModel.pull_url_info.flv_oriaac_url.length > 0)  {
            playUrl = self.liveInfoModel.pull_url_info.flv_oriaac_url;
        }
        else {
            playUrl = self.liveInfoModel.pull_url_info.flv_url;
        }
    }
    else if (self.liveInfoModel.mode == AUIRoomLiveModeLinkMic) {
        if (self.playRts) {
            playUrl = self.liveInfoModel.link_info.cdn_pull_info.rts_url;
        }
        else if (self.liveInfoModel.link_info.cdn_pull_info.flv_oriaac_url.length > 0) {
            playUrl = self.liveInfoModel.link_info.cdn_pull_info.flv_oriaac_url;
        }
        else {
            playUrl = self.liveInfoModel.link_info.cdn_pull_info.flv_url;
        }
    }
    
    if (playUrl.length > 0) {
        [_player setUrlSource:[[AVPUrlSource alloc] urlWithString:playUrl]];
        [self.displayView startLoading];
        if (self.onPrepareStartBlock) {
            self.onPrepareStartBlock();
        }
        [_player prepare];
        NSLog(@"cdn拉流：开始播放，播放地址：%@", playUrl);
        
        return YES;
    }
    
    [AVAlertController show:@"播放失败，缺少播放地址"];
    return NO;
}

- (BOOL)pause:(BOOL)pause {
    if (self.playOnError) {
        return YES;
    }
    if (!self.startCompleted) {
        return NO;
    }
    if (pause) {
        [_player pause];
        return YES;
    }
    [_player start];
    return NO;
}

- (void)destory {
    NSLog(@"cdn拉流：停止与释放实例");
    [_player stop];
    [_player clearScreen];
    _player.playerView = nil;
    [_player destroy];
    _player = nil;
    self.startCompleted = NO;
    self.isDestroy = YES;
}

#pragma mark - AVPDelegate
-(void)onPlayerEvent:(AliPlayer*)player eventType:(AVPEventType)eventType {
    switch (eventType) {
        case AVPEventPrepareDone: {
            NSLog(@"cdn拉流：播放已准备好");
            [self.displayView endLoading];
            if (self.onPrepareDoneBlock) {
                self.onPrepareDoneBlock();
            }
            self.startCompleted = YES;
        }
            break;
        case AVPEventLoadingStart: {
            NSLog(@"cdn拉流：开始加载");
            [self.displayView startLoading];
            if (self.onLoadingStartBlock) {
                self.onLoadingStartBlock();
            }
        }
            break;
        case AVPEventLoadingEnd: {
            NSLog(@"cdn拉流：加载结束");
            [self.displayView endLoading];
            if (self.onLoadingEndBlock) {
                self.onLoadingEndBlock();
            }
        }
            break;
        case AVPEventFirstRenderedStart: {
            NSLog(@"cdn拉流：首帧渲染完成");
        }
            break;
            
        default:
            break;
    }
}

- (void)onError:(AliPlayer *)player errorModel:(AVPErrorModel *)errorModel {
    NSLog(@"cdn拉流：播放出错(%tu, %@)", errorModel.code, errorModel.message);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        if (self.isDestroy) {
            [self.displayView endLoading];
            return;
        }
        
        if (self.playRts) {
            NSLog(@"cdn拉流：rts播放失败，使用flv进行播放");
            self.playRts = NO;
            [self destory];
            [self prepare];
            [self start];
            return;
        }

        self.playOnError = YES;
        NSLog(@"cdn拉流：使用flv播放失败，是否重试");
        NSString *title = @"直播中断，您可尝试再次拉流";
        [AVAlertController showWithTitle:nil message:title cancelTitle:@"取消" okTitle:@"重试" onCompleted:^(BOOL isCanced) {
            if (!isCanced) {
                NSLog(@"cdn拉流：开始重试");
                self.playRts = self.canRts;
                [self destory];
                [self prepare];
                [self start];
            }
        }];
        
        [self.displayView endLoading];
        if (self.onPlayErrorBlock) {
            self.onPlayErrorBlock();
        }
    });
}

/*
- (void)onSEIData:(AliPlayer *)player type:(int)type data:(NSData *)data {
    // 接收来之混流的SEI消息
    if (type == 5) {
//        NSError *jsonError = nil;
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
//        NSLog(@"混流SEI字典数据：%@", dict);
//
        NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"混流SEI json：%@", jsonStr);
        jsonStr = [jsonStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; // 去掉首尾的空白字符
        jsonStr = [jsonStr stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]];// 去除掉控制字符
        NSDictionary *dict2 = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
        NSLog(@"混流SEI字典数据：%@", dict2);
    }
}
*/
 
@end
