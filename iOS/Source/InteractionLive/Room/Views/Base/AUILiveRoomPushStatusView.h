//
//  AUILiveRoomPushStatusView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AUILiveRoomPushStatus)
{
    AUILiveRoomPushStatusFluent = 0,
    AUILiveRoomPushStatusStuttering,
    AUILiveRoomPushStatusBrokenOff,
};

@interface AUILiveRoomPushStatusView : UIView

@property (assign, nonatomic) AUILiveRoomPushStatus pushStatus;


@end

NS_ASSUME_NONNULL_END
