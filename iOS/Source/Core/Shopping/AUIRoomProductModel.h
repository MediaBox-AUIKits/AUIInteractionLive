//
//  AUIRoomProductModel.h
//  AUIInteractionLiveDemo
//
//  Created by Bingo on 2024/2/28.
//

#import <UIKit/UIKit.h>
#import "AUIMessageService.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomProductModel : NSObject<AUIMessageDataProtocol>

@property (nonatomic, copy) NSString *productId; // 商品id
@property (nonatomic, copy) NSString *title;     // 商品标题
@property (nonatomic, copy) NSString *info;      // 商品描述
@property (nonatomic, copy) NSString *coverUrl;  // 封面地址
@property (nonatomic, copy) NSString *sellUrl;   // 购买地址

@end

NS_ASSUME_NONNULL_END
