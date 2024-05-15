//
//  AUILiveRoomProductCard.h
//  AUIInteractionLiveDemo
//
//  Created by Bingo on 2024/2/8.
//

#import <UIKit/UIKit.h>
#import "AUIRoomProductModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomProductCard : UIView

@property (nonatomic, strong) AUIRoomProductModel *product;

@property (copy, nonatomic) void (^onCloseButtonClickedBlock)(AUILiveRoomProductCard *sender);

@end

NS_ASSUME_NONNULL_END
