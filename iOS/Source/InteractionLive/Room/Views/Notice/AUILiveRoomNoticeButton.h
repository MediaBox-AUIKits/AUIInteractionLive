//
//  AUILiveRoomNoticeButton.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomNoticeButton : UIView

@property (nonatomic, copy) void(^onEditNoticeContentBlock)(void);

@property (nonatomic, copy) NSString *noticeContent;

@property (nonatomic, assign) BOOL showNoticeContent;
@property (nonatomic, assign) BOOL enableEdit;


@end

NS_ASSUME_NONNULL_END
