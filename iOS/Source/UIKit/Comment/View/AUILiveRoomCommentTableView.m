//
//  AUILiveRoomCommentTableView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomCommentTableView.h"
#import "AUILiveRoomCommentCell.h"
#import "AUIFoundation.h"

#define ReuseableCellId @"CommentViewCell"

@interface AUILiveRoomCommentTableView ()<UITableViewDelegate, UITableViewDataSource, AUILiveRoomCommentCellDelegate>

@property (strong, nonatomic) NSMutableArray<AUILiveRoomCommentModel *> *commentsPresented;
@property (assign, nonatomic) CGFloat maxHeight;
@property (assign, nonatomic) BOOL autoScroll;
@property (assign, nonatomic) BOOL topMode;

@end


@implementation AUILiveRoomCommentTableView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame topMode:NO];
}

- (instancetype)initWithFrame:(CGRect)frame topMode:(BOOL)topMode {
    self = [super initWithFrame:frame];
    if (self) {
        self.topMode  = topMode;
        self.maxHeight = frame.size.height;
        
        self.backgroundColor = UIColor.clearColor;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.showsVerticalScrollIndicator = NO;
        self.dataSource = self;
        self.delegate = self;
        self.contentInset = UIEdgeInsetsMake(8, 0, 8, 0);
        [self registerClass:[AUILiveRoomCommentCell class] forCellReuseIdentifier:ReuseableCellId];
        
        _commentsPresented = [[NSMutableArray alloc] init];
        _autoScroll = YES;
    }
    return self;
}

- (void)scrollToLastComment {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkAutoScroll) object:nil];
    self.autoScroll = YES;
    if (self.commentsPresented.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.commentsPresented.count - 1 inSection:0];
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (BOOL)presentingOnLastComment {
    if (self.contentSize.height <= self.maxHeight || self.contentOffset.y + self.maxHeight >= self.contentSize.height + self.contentInset.bottom - self.commentList.lastObject.cellHeight) {
        return YES;
    }
    return NO;
}

- (NSArray<AUILiveRoomCommentModel *> *)commentList {
    return self.commentsPresented;
}

- (void)insertNewComment:(AUILiveRoomCommentModel *)comment {
    comment.cellHeight = [AUILiveRoomCommentCell heightWithModel:comment withLimitWidth:self.av_width];
    [self.commentsPresented addObject:comment];
    
    if (!self.topMode) {
        CGFloat height = MIN(self.contentSize.height + comment.cellHeight + self.contentInset.top + self.contentInset.bottom, self.maxHeight);
        if (height < self.maxHeight) {
            [UIView animateWithDuration:0.3 animations:^{
                self.frame = CGRectMake(self.av_left, self.av_bottom - height, self.av_width, height);
            }];
        }
    }
    
    [CATransaction begin];
    [self beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.commentsPresented.count - 1 inSection:0];
    [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self endUpdates];
    [CATransaction commit];
    
    if (self.autoScroll) {
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUILiveRoomCommentModel *model = self.commentsPresented[indexPath.row];
    if (model.cellHeight <= 0) {
        model.cellHeight = [AUILiveRoomCommentCell heightWithModel:model withLimitWidth:self.av_width];
    }
    return model.cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentsPresented.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUILiveRoomCommentCell* cell = [self dequeueReusableCellWithIdentifier:ReuseableCellId];
    cell.delegate = self;
    cell.commentModel = self.commentsPresented[indexPath.row];
    cell.backgroundColor = self.commentBackgroundColor;
    return cell;
}

#pragma mark - auto scroll

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.commentDelegate respondsToSelector:@selector(onCommentDidScroll)]) {
        [self.commentDelegate onCommentDidScroll];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    NSLog(@"scrollViewWillBeginDragging");
    self.autoScroll = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkAutoScroll) object:nil];

}

//#define AUTO_SCROLL
// 滚动方案，打开宏AUTO_SCROLL使用方案2，默认方案1
// 方案1：是否滑动到底，是的话，切换到自动滚动
// 方案2：5.0s后自动滚动

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    NSLog(@"scrollViewDidEndDragging");
#ifndef AUTO_SCROLL
    [self performSelector:@selector(checkAutoScroll) withObject:nil afterDelay:0.5];
#else
    [self performSelector:@selector(checkAutoScroll) withObject:nil afterDelay:5.0];
#endif
}

- (void)checkAutoScroll {
#ifndef AUTO_SCROLL
    if ([self presentingOnLastComment]) {
        self.autoScroll = YES;
    }
#else
    self.autoScroll = YES;
#endif
}

#pragma mark - AUILiveRoomCommentCellDelegate

-(void)onCommentCellLongPressGesture:(UILongPressGestureRecognizer *)recognizer commentModel:(AUILiveRoomCommentModel *)commentModel{
    if(recognizer.state == UIGestureRecognizerStateBegan){
        if([self.commentDelegate respondsToSelector:@selector(onCommentCellTapped:)]){
            [self.commentDelegate onCommentCellTapped:commentModel];
        }
    }
}

-(void)onCommentCellTapGesture:(UITapGestureRecognizer *)recognizer
                       commentModel:(AUILiveRoomCommentModel *)commentModel {
    if([self.commentDelegate respondsToSelector:@selector(onCommentCellTapped:)]){
        [self.commentDelegate onCommentCellTapped:commentModel];
    }
}

@end
