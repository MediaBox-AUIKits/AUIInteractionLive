//
//  AUILiveRoomAudienceViewController.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/2.
//

#import <UIKit/UIKit.h>
#import "AUIRoomLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomAudienceViewController : UIViewController

- (instancetype)initWithModel:(AUIRoomLiveInfoModel *)model withJoinList:(nullable NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)joinList;

@end

NS_ASSUME_NONNULL_END
