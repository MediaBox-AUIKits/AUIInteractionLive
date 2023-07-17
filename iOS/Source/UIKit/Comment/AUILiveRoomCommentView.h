//
//  AUILiveRoomCommentView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>
#import "AUILiveRoomCommentModel.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUILiveRoomCommentViewMode) {
    AUILiveRoomCommentViewModeBottom,
    AUILiveRoomCommentViewModeTop,
};

@interface AUILiveRoomCommentView : UIView

@property (nonatomic, copy, readonly) NSArray<AUILiveRoomCommentModel *> *commentList;
@property (nonatomic, strong) UIColor *commentBackgroundColor;
@property (nonatomic, strong, readonly) UIButton *showNewCommentTipsButton;

- (instancetype)initWithFrame:(CGRect)frame mode:(AUILiveRoomCommentViewMode)mode  needShowNewCommentTips:(BOOL)needShowNewCommentTips;

/**
 * 插入普通直播弹幕
 * @param comment 弹幕model
 */
- (void)insertLiveComment:(AUILiveRoomCommentModel *)comment;

/**
 * 插入普通直播弹幕
 * @param content 弹幕内容
 * @param nick 弹幕发送者昵称
 */
- (void)insertLiveComment:(NSString *)content
         commentSenderNick:(NSString *)nick
           commentSenderID:(NSString *)userID;


@end

NS_ASSUME_NONNULL_END
