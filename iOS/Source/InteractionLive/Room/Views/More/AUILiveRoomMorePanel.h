//
//  AUILiveRoomMorePanel.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>
#import "AUIFoundation.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUILiveRoomMorePanelActionType) {
    AUILiveRoomMorePanelActionTypeMute,
    AUILiveRoomMorePanelActionTypeAudioOnly,
    AUILiveRoomMorePanelActionTypeCamera,
    AUILiveRoomMorePanelActionTypeMirror,
    AUILiveRoomMorePanelActionTypeBan,
};

@interface AUILiveRoomMorePanel : AVBaseControllPanel

@property (nonatomic, copy) BOOL (^onClickedAction)(AUILiveRoomMorePanel *sender, AUILiveRoomMorePanelActionType type, BOOL selected);

- (void)updateClickedSelected:(AUILiveRoomMorePanelActionType)type selected:(BOOL)selected;

@end

NS_ASSUME_NONNULL_END
