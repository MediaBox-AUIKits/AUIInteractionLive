//
//  AUILIveRoomNoticePanel.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/10.
//

#import <UIKit/UIKit.h>
#import "AUIFoundation.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILIveRoomNoticePanel : AVBaseControllPanel

@property (nonatomic, copy) void (^onInputCompletedBlock)(AUILIveRoomNoticePanel *sender, NSString *input);

@property (nonatomic, copy) NSString *input;

@end

NS_ASSUME_NONNULL_END
