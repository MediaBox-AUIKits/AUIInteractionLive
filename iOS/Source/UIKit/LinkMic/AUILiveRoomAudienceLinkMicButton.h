//
//  AUILiveRoomAudienceLinkMicButton.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUILiveRoomAudienceLinkMicButtonState) {
    AUILiveRoomAudienceLinkMicButtonStateInit,
    AUILiveRoomAudienceLinkMicButtonStateApply,
    AUILiveRoomAudienceLinkMicButtonStateApplyCancel,
    AUILiveRoomAudienceLinkMicButtonStateJoin,
};

@interface AUILiveRoomAudienceLinkMicButton : UIView

@property (nonatomic, assign) AUILiveRoomAudienceLinkMicButtonState state;

@property (copy, nonatomic) void (^onApplyBlock)(AUILiveRoomAudienceLinkMicButton *sender);
@property (copy, nonatomic) void (^onApplyCancelBlock)(AUILiveRoomAudienceLinkMicButton *sender);
@property (copy, nonatomic) void (^onLeaveBlock)(AUILiveRoomAudienceLinkMicButton *sender);
@property (copy, nonatomic) void (^onSwitchCameraBlock)(AUILiveRoomAudienceLinkMicButton *sender);

@property (nonatomic, copy) void (^onSwitchAudioBlock)(AUILiveRoomAudienceLinkMicButton *sender, BOOL isOn);
@property (nonatomic, copy) void (^onSwitchVideoBlock)(AUILiveRoomAudienceLinkMicButton *sender, BOOL isOn);

@property (assign, nonatomic) BOOL audioOff;
@property (assign, nonatomic) BOOL videoOff;

@end

NS_ASSUME_NONNULL_END
