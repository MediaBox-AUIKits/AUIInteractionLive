//
//  AUIRoomGiftModel.h
//  AUIInteractionLiveDemo
//
//  Created by Bingo on 2024/2/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomGiftModel : NSObject

@property (nonatomic, copy) NSString *giftId;    // id
@property (nonatomic, copy) NSString *name;      // 名称
@property (nonatomic, copy) NSString *info;      // 描述
@property (nonatomic, copy) NSString *imageUrl;  // 缩略图
@property (nonatomic, assign) CGSize size;       // 播放大小
@property (nonatomic, copy) NSString *sourceUrl; // 礼物特效文件（mp4）的服务端地址
@property (nonatomic, copy) NSString *filePath;  // 礼物特效下载到本地后的文件路径，一般情况下，使用本地文件进行播放

- (instancetype)initWithData:(NSDictionary *)data;

@end

NS_ASSUME_NONNULL_END
