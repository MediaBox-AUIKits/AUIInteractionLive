//
//  AUIRoomGiftPanel.h
//  AUIInteractionLiveDemo
//
//  Created by Bingo on 2024/2/28.
//

#import <Foundation/Foundation.h>
#import "AUIFoundation.h"
#import "AUIRoomGiftModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomGiftPanel : AVBaseCollectionControllPanel

@property (nonatomic, copy) void(^onSendGiftBlock)(AUIRoomGiftPanel *sender, AUIRoomGiftModel *gift);

@end

NS_ASSUME_NONNULL_END
