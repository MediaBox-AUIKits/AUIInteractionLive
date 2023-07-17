//
//  AUILiveRoomCommentView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomCommentView.h"
#import "AUILiveRoomCommentTableView.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"


@interface AUILiveRoomCommentView() <AUILiveRoomCommentTableViewDelegate>

@property (strong, nonatomic) AUILiveRoomCommentTableView *internalCommentView;
@property (assign, nonatomic) AUILiveRoomCommentViewMode mode;

@end

@implementation AUILiveRoomCommentView

- (instancetype)initWithFrame:(CGRect)frame mode:(AUILiveRoomCommentViewMode)mode  needShowNewCommentTips:(BOOL)needShowNewCommentTips {
    self = [super initWithFrame:frame];
    if (self) {
        _mode = mode;
        _internalCommentView = [[AUILiveRoomCommentTableView alloc] initWithFrame:CGRectMake(16, 0, self.av_width - 16 * 2, self.av_height) topMode:mode == AUILiveRoomCommentViewModeTop];
        _internalCommentView.commentDelegate = self;
        [self addSubview:_internalCommentView];
        
        if (needShowNewCommentTips) {
            _showNewCommentTipsButton = [[UIButton alloc] initWithFrame:CGRectZero];
            _showNewCommentTipsButton.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
            [_showNewCommentTipsButton setTitle:@"你有新消息" forState:UIControlStateNormal];
            [_showNewCommentTipsButton setTitleColor:[UIColor av_colorWithHexString:@"#FCFCFD"] forState:UIControlStateNormal];
            _showNewCommentTipsButton.titleLabel.font = AVGetRegularFont(14);
            [_showNewCommentTipsButton setImage:AUIRoomGetCommonImage(@"ic_living_comment_tips") forState:UIControlStateNormal];
            [_showNewCommentTipsButton sizeToFit];
            _showNewCommentTipsButton.av_width = _showNewCommentTipsButton.av_width + 12;
            _showNewCommentTipsButton.av_height = 28;
            _showNewCommentTipsButton.av_left = self.av_width - _showNewCommentTipsButton.av_width;
            _showNewCommentTipsButton.av_top = self.av_height - _showNewCommentTipsButton.av_height - 12;
            
            UIBezierPath *roundedRectPath = [UIBezierPath bezierPathWithRoundedRect:_showNewCommentTipsButton.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(14, 14)];
            CAShapeLayer *shapLayer = [[CAShapeLayer alloc] init];
            shapLayer.path = roundedRectPath.CGPath;
            _showNewCommentTipsButton.layer.mask = shapLayer;
            
            _showNewCommentTipsButton.hidden = YES;
            [_showNewCommentTipsButton addTarget:self action:@selector(onClickShowNewCommentTipsButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_showNewCommentTipsButton];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame mode:AUILiveRoomCommentViewModeBottom needShowNewCommentTips:NO];
}

- (void)setCommentBackgroundColor:(UIColor *)commentBackgroundColor {
    self.internalCommentView.commentBackgroundColor = commentBackgroundColor;
}

- (UIColor *)commentBackgroundColor {
    return self.internalCommentView.commentBackgroundColor;
}

- (NSArray<AUILiveRoomCommentModel *> *)commentList {
    return self.internalCommentView.commentList;
}

#pragma mark -Public Methods

- (void)insertLiveComment:(AUILiveRoomCommentModel *)comment {
    [self.internalCommentView insertNewComment:comment];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkNewCommentTips) object:nil];
    [self performSelector:@selector(checkNewCommentTips) withObject:nil afterDelay:0.5];
}

- (void)insertLiveComment:(NSString *)content
        commentSenderNick:(NSString *)nick
          commentSenderID:(NSString *)userID {
    AUILiveRoomCommentModel* model = [[AUILiveRoomCommentModel alloc] init];
    model.senderID = userID;
    model.senderNick = nick;
    model.sentContent = content;
    
    [self insertLiveComment:model];
}

//- (void)runAutoCommentInputTest {
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(arc4random() % 1000 / 500.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSString *string = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
//        NSUInteger count = string.length;
//        NSMutableString *nick = [NSMutableString new];
//        NSUInteger nickLength = arc4random() % 10 + 1;
//        for (NSUInteger i=0; i<nickLength; i++) {
//            [nick appendString:[string substringWithRange:NSMakeRange(arc4random()%count, 1)]];
//        }
//
//        NSMutableString *comment = [NSMutableString new];
//        NSUInteger commentLength = arc4random() % 50 + 5;
//        for (NSUInteger i=0; i<commentLength; i++) {
//            [comment appendString:[string substringWithRange:NSMakeRange(arc4random()%count, 1)]];
//        }
//
//        AUILiveRoomCommentModel* model = [[AUILiveRoomCommentModel alloc] init];
//        model.sentContent = comment;
//        model.senderNick = nick;
//        model.sentContentColor = AUIFoundationColor(@"text_strong");
//        model.senderNickColor = AUIFoundationColor(@"text_weak");
//        model.useFlag = YES;
//        model.isAnchor = YES;
//        model.isMe = YES;
//        [self insertLiveComment:model];
//
//        if (self.internalCommentView.commentList.count < 100) {
//            [self runAutoCommentInputTest];
//        }
//    });
//}

#pragma mark - new comment tips

- (void)checkNewCommentTips {
    if (_showNewCommentTipsButton) {
        _showNewCommentTipsButton.hidden = [self.internalCommentView presentingOnLastComment];
    }
}

- (void)onClickShowNewCommentTipsButton:(UIButton *)sender {
    _showNewCommentTipsButton.hidden = YES;
    [self.internalCommentView scrollToLastComment];
}

#pragma mark -AUILiveRoomCommentTableViewDelegate

- (void)onCommentDidScroll {
    if ([self.internalCommentView presentingOnLastComment]) {
        _showNewCommentTipsButton.hidden = YES;
    }
}

-(void)onCommentCellLongPressed:(AUILiveRoomCommentModel *)commentModel {

}

-(void)onCommentCellTapped:(AUILiveRoomCommentModel *)commentModel {

}

@end
