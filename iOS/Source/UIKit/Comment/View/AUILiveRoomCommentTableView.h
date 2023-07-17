//
//  AUILiveRoomCommentTableView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>
#import "AUILiveRoomCommentModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AUILiveRoomCommentTableViewDelegate <NSObject>

- (void)onCommentDidScroll;
- (void)onCommentCellLongPressed:(AUILiveRoomCommentModel *)commentModel;
- (void)onCommentCellTapped:(AUILiveRoomCommentModel *)commentModel;

@end

@interface AUILiveRoomCommentTableView : UITableView

@property (nonatomic, weak) id<AUILiveRoomCommentTableViewDelegate> commentDelegate;

@property (nonatomic, copy, readonly) NSArray<AUILiveRoomCommentModel *> *commentList;
@property (nonatomic, strong) UIColor *commentBackgroundColor;


- (instancetype)initWithFrame:(CGRect)frame topMode:(BOOL)topMode;

- (void)insertNewComment:(AUILiveRoomCommentModel*)comment;

- (void)scrollToLastComment;

- (BOOL)presentingOnLastComment;

@end

NS_ASSUME_NONNULL_END
