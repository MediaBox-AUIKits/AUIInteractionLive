//
//  AUIRoomAppServer.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/8/31.
//

#import <Foundation/Foundation.h>
#import "AUIRoomLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomAppServer : NSObject

+ (void)setServiceUrl:(NSString *)url;
+ (NSString *)serviceUrl;

+ (void)setEnv:(BOOL)staging;  // 是否预发环境，默认为NO
+ (BOOL)stagingEnv;

+ (void)requestWithPath:(NSString *)path bodyDic:(NSDictionary *)bodyDic completionHandler:(void (^)(NSURLResponse *response, id responseObject,  NSError * error))completionHandler;

+ (void)fetchToken:(void(^)(NSString * _Nullable accessToken, NSString * _Nullable refreshToken, NSError * _Nullable error))completed;

+ (void)createLive:(NSString * _Nullable)groupId mode:(NSInteger)mode title:(NSString *)title notice:(NSString * _Nullable)notice extend:(NSDictionary * _Nullable)extend completed:(void(^)(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error))completed;

+ (void)startLive:(NSString *)liveId completed:(void(^)(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error))completed;

+ (void)stopLive:(NSString *)liveId completed:(void(^)(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error))completed;


+ (void)muteAll:(NSString *)liveId completed:(void(^)(NSError * _Nullable error))completed;
+ (void)cancelMuteAll:(NSString *)liveId completed:(void(^)(NSError * _Nullable error))completed;
+ (void)queryMuteAll:(NSString *)liveId completed:(void(^)(BOOL isMuteAll, NSError * _Nullable error))completed;

+ (void)sendLike:(NSString *)liveId count:(NSUInteger)count completed:(void(^)(NSError * _Nullable error))completed;

+ (void)fetchLiveList:(NSUInteger)pageNum pageSize:(NSUInteger)pageSize completed:(void(^)(NSArray<AUIRoomLiveInfoModel *> * _Nullable models, NSError * _Nullable error))completed;

+ (void)fetchLive:(NSString *)liveId userId:(NSString * _Nullable)userId completed:(void(^)(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error))completed;

+ (void)fetchStatistics:(NSString *)liveId completed:(void(^)(AUIRoomLiveMetricsModel * _Nullable model, NSError * _Nullable error))completed;

+ (void)updateLive:(NSString *)liveId title:(NSString * _Nullable)title notice:(NSString * _Nullable)notice extend:(NSDictionary * _Nullable)extend completed:(void(^)(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error))completed;

+ (void)queryLinkMicJoinList:(NSString *)liveId completed:(void(^)(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> * _Nullable models, NSError * _Nullable error))completed;
+ (void)updateLinkMicJoinList:(NSString *)liveId joinList:(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)joinList  completed:(void(^)(NSError * _Nullable error))completed;

@end

NS_ASSUME_NONNULL_END
