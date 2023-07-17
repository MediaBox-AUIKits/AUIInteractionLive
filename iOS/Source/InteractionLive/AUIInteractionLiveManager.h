//
//  AUIInteractionLiveManager.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/6.
//

#import <UIKit/UIKit.h>
#import "AUIRoomLiveModel.h"
#import "AUIRoomUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIInteractionLiveManager : NSObject



+ (instancetype)defaultManager;

- (void)setup;

- (void)setCurrentUser:(AUIRoomUser * _Nullable)user;
- (AUIRoomUser *)currentUser;
- (void)login:(void(^)(BOOL success))completedBlock;
- (void)logout;

// 创建直播间
- (void)createLive:(AUIRoomLiveMode)mode title:(NSString *)title notice:(NSString  * _Nullable)notice currentVC:(UIViewController *)currentVC completed:(nullable void(^)(BOOL success, AUIRoomLiveInfoModel * _Nullable model))completedBlock;

// 加入直播间
- (void)joinLiveWithLiveId:(NSString *)liveId currentVC:(UIViewController *)currentVC completed:(nullable void(^)(BOOL success))completedBlock;
- (void)joinLive:(AUIRoomLiveInfoModel *)model currentVC:(UIViewController *)currentVC completed:(nullable void(^)(BOOL success))completedBlock;



@end

NS_ASSUME_NONNULL_END

