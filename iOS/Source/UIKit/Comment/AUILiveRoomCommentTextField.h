//
//  AUILiveRoomCommentTextField.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUILiveRoomCommentState) {
    AUILiveRoomCommentStateDefault,
    AUILiveRoomCommentStateMute,
};

@interface AUILiveRoomCommentTextField : UITextField

@property (assign, nonatomic) AUILiveRoomCommentState commentState;

@property (copy, nonatomic) void (^sendCommentBlock)(AUILiveRoomCommentTextField *sender, NSString *comment);

@property (copy, nonatomic) void (^willEditBlock)(AUILiveRoomCommentTextField *sender, CGRect keyboardFrame);
@property (copy, nonatomic) void (^endEditBlock)(AUILiveRoomCommentTextField *sender);

@property(strong, nonatomic) UIColor *backgroundColorForNormal;
@property(strong, nonatomic) UIColor *backgroundColorForEdit;
@property(strong, nonatomic) UIColor *textColorForNormal;
@property(strong, nonatomic) UIColor *textColorForEdit;
@property(strong, nonatomic) UIColor *placeHolderColorForNormal;
@property(strong, nonatomic) UIColor *placeHolderColorForDisable;

- (void)refreshCommentPlaceHolder;
- (void)refreshDisplayColor;

@end

NS_ASSUME_NONNULL_END
