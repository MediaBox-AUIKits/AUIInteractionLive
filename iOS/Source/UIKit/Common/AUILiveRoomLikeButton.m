//
//  AUILiveRoomLikeButton.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomLikeButton.h"
#import "AUIRoomMacro.h"

@interface AUILiveRoomLikeButton ()

@property (nonatomic, assign) BOOL isRepeatLikeAnimation;
@property (nonatomic, strong) NSTimer *animationTimer;
@property (nonatomic, strong) NSMutableArray *animationViewList;

@end

@implementation AUILiveRoomLikeButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    NSLog(@"like_button:touchesBegan");
    self.isRepeatLikeAnimation = YES;
    [self likeAnimation];
    [self startLikeTimer];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    NSLog(@"like_button:touchesEnded");
    self.isRepeatLikeAnimation = NO;
    [self stopLikeTimer];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    NSLog(@"like_button:touchesCancelled");
    self.isRepeatLikeAnimation = NO;
    [self stopLikeTimer];
}

- (void)startLikeTimer {
    self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(likeAnimation) userInfo:nil repeats:YES];
}

- (void)stopLikeTimer {
    [self.animationTimer invalidate];
    self.animationTimer = nil;
}

- (void)likeAnimation {
    NSLog(@"like_button:timer to animation");

    if (!self.isRepeatLikeAnimation) {
        [self stopLikeTimer];
        return;
    }
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(self.frame.origin.x + self.superview.frame.origin.x, self.frame.origin.y + self.superview.frame.origin.y, 30, 30);
    imageView.backgroundColor = [UIColor clearColor];
    imageView.clipsToBounds = YES;
    NSString *ic_like = [NSString stringWithFormat:@"ic_like_%u", arc4random() % 6 + 1];
    imageView.image = AUIRoomGetCommonImage(ic_like);
    [self.superview.superview addSubview:imageView];
    
    CGRect frame = self.superview.superview.frame;
    CGFloat finishX = frame.size.width - round(random() % 120);
    CGFloat finishY = imageView.frame.origin.y - 214;
    CGFloat scale = round(random() % 2) + 0.7;

    CGFloat speed = 1 / round(random() % 900) + 0.6;
    NSTimeInterval duration = 4* speed;
    if (duration == INFINITY) {
        duration =2.412346;
    }
    
    [UIView animateWithDuration:duration animations:^{
        imageView.frame = CGRectMake(finishX, finishY, 30 * scale, 30 * scale);
        imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
}

@end
