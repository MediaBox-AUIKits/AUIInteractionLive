//
//  AUILiveRoomLinkMicListPanel.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/28.
//

#import "AUIFoundation.h"
#import "AUIRoomInteractionLiveManagerAnchor.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUILiveRoomLinkMicItemType) {
    AUILiveRoomLinkMicItemTypeJoined,
    AUILiveRoomLinkMicItemTypeApply,
};

@interface AUILiveRoomLinkMicListPanel : AVBaseCollectionControllPanel

@property (nonatomic, assign) AUILiveRoomLinkMicItemType tabType;

- (instancetype)initWithFrame:(CGRect)frame withManager:(AUIRoomInteractionLiveManagerAnchor *)manager;

- (void)reload;

@end

NS_ASSUME_NONNULL_END
