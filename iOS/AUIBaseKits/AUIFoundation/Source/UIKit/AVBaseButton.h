//
//  AVBaseButton.h
//  AUIFoundation
//
//  Created by coder.pi on 2022/6/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AVBaseButtonTitlePos) {
    AVBaseButtonTitlePosTop,
    AVBaseButtonTitlePosBottom,
    AVBaseButtonTitlePosLeft,
    AVBaseButtonTitlePosRight,
};

typedef NS_ENUM(NSUInteger, AVBaseButtonType) {
    AVBaseButtonTypeOnlyText,
    AVBaseButtonTypeOnlyImage,
    AVBaseButtonTypeImageText
};

typedef NS_ENUM(NSUInteger, AVBaseButtonState) {
    AVBaseButtonStateNormal,
    AVBaseButtonStateSelected,
    AVBaseButtonStateDisabled
};

@class AVBaseButton;
typedef void(^AVBaseButtonAction)(AVBaseButton *btn);

@interface AVBaseButton : UIView
@property (nonatomic, readonly) AVBaseButtonType type;
@property (nonatomic, readonly) AVBaseButtonTitlePos titlePos;
@property (nonatomic, assign) CGFloat spacing;

@property (nonatomic, assign) AVBaseButtonState state;
@property (nonatomic, assign) BOOL disabled;
@property (nonatomic, assign) BOOL selected;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *disabledTitle;
@property (nonatomic, copy) NSString *selectedTitle;
@property (nonatomic, strong) UIFont *font;

@property (nonatomic, copy) UIColor *color;
@property (nonatomic, copy) UIColor *disabledColor;
@property (nonatomic, copy) UIColor *selectedColor;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *disabledImage;
@property (nonatomic, strong) UIImage *selectedImage;

@property (nonatomic, assign) UIEdgeInsets insets;

@property (nonatomic, copy) AVBaseButtonAction action;
- (instancetype) initWithType:(AVBaseButtonType)type titlePos:(AVBaseButtonTitlePos)titlePos;
+ (AVBaseButton *) ImageTextWithTitlePos:(AVBaseButtonTitlePos)titlePos;
+ (AVBaseButton *) ImageButton;
+ (AVBaseButton *) TextButton;
@end

NS_ASSUME_NONNULL_END
