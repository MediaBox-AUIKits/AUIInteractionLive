//
//  AUIRoomGiftManager.h
//  AUIInteractionLiveDemo
//
//  Created by Bingo on 2024/2/28.
//

#import <Foundation/Foundation.h>
#import "AUIRoomGiftModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomGiftManager : NSObject

+ (instancetype)sharedInstance;

- (NSArray<AUIRoomGiftModel *> *)giftList;
- (nullable AUIRoomGiftModel *)getGift:(NSString *)giftId;

// 主播需要播放礼物动效的话，可以在启动后调用api，下载所有礼物资源
- (void)downloadAllGiftResourceIfNeed;

// 观众在需要发礼物前，需要下载资源
- (void)downloadGift:(AUIRoomGiftModel *)model;

- (BOOL)isDownloading:(AUIRoomGiftModel *)model;

@end

NS_ASSUME_NONNULL_END
