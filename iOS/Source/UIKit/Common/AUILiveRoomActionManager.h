//
//  AUILiveRoomActionManager.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/29.
//

#import <UIKit/UIKit.h>
#import "AUIRoomUser.h"
#import "AUIRoomLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^onActionCompleted)(BOOL success);

@interface AUILiveRoomActionManager : NSObject

@property (nonatomic, strong, readonly, class) AUILiveRoomActionManager *defaultManager;

@property (nonatomic, copy) void (^followAnchorAction)(AUIRoomUser *anchor, BOOL isFollowed, UIViewController *roomVC, onActionCompleted completed);

@property (nonatomic, copy) void (^openShare)(AUIRoomLiveInfoModel *liveInfo, UIViewController *roomVC, _Nullable onActionCompleted completed);

@end

NS_ASSUME_NONNULL_END
