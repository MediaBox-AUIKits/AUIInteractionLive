//
//  AUIRoomGiftPlayer.m
//  AUIInteractionLiveDemo
//
//  Created by Bingo on 2024/2/28.
//

#import "AUIRoomGiftPlayer.h"
#import "AUIFoundation.h"
#import "AUIRoomSDKHeader.h"

@interface AUIRoomGiftPlayer () <AVPDelegate>

@property (strong, nonatomic) AliPlayer *player;
@property (strong, nonatomic) AUIRoomGiftModel *giftModel;

@end

@implementation AUIRoomGiftPlayer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = false;
    }
    return self;
}

- (void)play:(AUIRoomGiftModel *)model onView:(UIView *)view {
    
    self.frame = CGRectMake(0, 0, model.size.width, model.size.height);
    self.center = CGPointMake(view.av_width / 2.0, view.av_height / 2.0);
    self.backgroundColor = UIColor.redColor;
    [view addSubview:self];
    
    self.giftModel = model;
    
    [self prepare];
}

- (void)stop {
    [_player stop];
    
    [self destory];
}


- (void)prepare {
    
    AVPConfig *config = [[AVPConfig alloc] init];
    
    _player = [[AliPlayer alloc] init];
    [_player setConfig:config];
    _player.delegate = self;
    _player.autoPlay = YES;
    [_player setAlphaRenderMode:AVP_RENDERMODE_ALPHA_AT_RIGHT];
    [_player setPlayerView:self];
    
    NSString *url = self.giftModel.filePath;
    if (url.length == 0) {
        url = self.giftModel.sourceUrl;
    }
    [_player setUrlSource:[[AVPUrlSource alloc] urlWithString:url]];
    [_player prepare];
    NSLog(@"AUIRoomGiftPlayer: start play  %@", url);
}

- (void)destory {
    [_player clearScreen];
    _player.playerView = nil;
    [_player destroy];
    _player = nil;
    
    [self removeFromSuperview];
}

#pragma mark -- AVPDelegate
- (void)onPlayerEvent:(AliPlayer *)player eventType:(AVPEventType)eventType {
    switch (eventType) {
        case AVPEventPrepareDone:
        {
            NSLog(@"AUIRoomGiftPlayer: prepare done");
        }
            break;
        case AVPEventFirstRenderedStart:
        {
            NSLog(@"AUIRoomGiftPlayer: render start");
        }
            break;
        case AVPEventCompletion:
        {
            NSLog(@"AUIRoomGiftPlayer: start play");
            [self destory];
        }
            break;
        default:
            break;
    }
}

- (void)onError:(AliPlayer *)player errorModel:(AVPErrorModel *)errorModel {
    NSLog(@"AUIRoomGiftPlayer: playe error");
    [self destory];
}

@end
