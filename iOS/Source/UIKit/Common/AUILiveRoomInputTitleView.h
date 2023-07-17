//
//  AUILiveRoomInputTitleView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomInputTitleView : UIView

@property (nonatomic, copy) NSString *titleName;
@property (nonatomic, copy) NSString *inputText;
@property (nonatomic, copy) NSString *placeHolder;

@property (nonatomic, strong, readonly) UITextView *inputTextView;


@property (nonatomic, copy) void(^inputTextChangedBlock)(NSString *inputText);


@end

NS_ASSUME_NONNULL_END
