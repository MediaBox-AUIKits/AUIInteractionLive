//
//  AUILiveRoomCommentCell.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>
#import "AUILiveRoomCommentModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AUILiveRoomCommentCellDelegate <NSObject>

- (void)onCommentCellLongPressGesture:(UILongPressGestureRecognizer*)recognizer
                              commentModel:(AUILiveRoomCommentModel*)commentModel;

- (void)onCommentCellTapGesture:(UITapGestureRecognizer*)recognizer
                        commentModel:(AUILiveRoomCommentModel*)commentModel;

@end


@interface AUILiveRoomCommentCell : UITableViewCell

@property (weak, nonatomic) id<AUILiveRoomCommentCellDelegate> delegate;

@property (strong, nonatomic) AUILiveRoomCommentModel *commentModel;

+ (CGFloat)heightWithModel:(AUILiveRoomCommentModel *)commentModel withLimitWidth:(CGFloat)limitWidth;

@end

NS_ASSUME_NONNULL_END
