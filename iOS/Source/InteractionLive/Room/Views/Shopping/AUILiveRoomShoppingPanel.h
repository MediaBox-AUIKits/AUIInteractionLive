//
//  AUILiveRoomShoppingPanel.h
//  AUIInteractionLiveDemo
//
//  Created by Bingo on 2024/2/8.
//

#import <Foundation/Foundation.h>
#import "AUIFoundation.h"
#import "AUIRoomProductModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomShoppingPanel : AVBaseCollectionControllPanel

@property (nonatomic, copy) void(^onSelectProductBlock)(AUILiveRoomShoppingPanel *sender, AUIRoomProductModel *product);


@end

NS_ASSUME_NONNULL_END
