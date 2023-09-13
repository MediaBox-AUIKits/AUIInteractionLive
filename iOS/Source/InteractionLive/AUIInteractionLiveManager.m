//
//  AUIInteractionLiveManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/6.
//

#import "AUIInteractionLiveManager.h"
#import "AUIRoomAccount.h"
#import "AUIRoomAppServer.h"
#import "AUIRoomMessageService.h"
#import "AUIRoomBeautyManager.h"

#import "AUILiveRoomAnchorViewController.h"
#import "AUILiveRoomAudienceViewController.h"

#import "AUIRoomTheme.h"
#import "AUIFoundation.h"
#import "AUIRoomSDKHeader.h"

static NSString * const kLiveServiceDomainString = @"https://appserver.h5video.vip";

@interface AUIInteractionLiveManager ()

@property (nonatomic, copy) void (^loginCompleted)(BOOL success);

@end

@implementation AUIInteractionLiveManager

+ (instancetype)defaultManager {
    static AUIInteractionLiveManager *_instance = nil;
    if (!_instance) {
        _instance = [AUIInteractionLiveManager new];
    }
    return _instance;
}

- (void)setup {
    // 设置bundle资源名称
    AUIRoomTheme.resourceName = @"AUIInteractionLive";
    
    // 设置AppServer地址
    [AUIRoomAppServer setServiceUrl:kLiveServiceDomainString];
    
    // 初始化SDK
    [AlivcBase setIntegrationWay:@"aui-live-interaction"];
    [AlivcLiveBase registerSDK];
    
    // 初始化美颜
    [AUIRoomBeautyManager registerBeautyEngine];
    
    [AliPlayer setEnableLog:NO];
    [AliPlayer setLogCallbackInfo:LOG_LEVEL_NONE callbackBlock:nil];
    
#if DEBUG
    [AlivcLiveBase setLogLevel:AlivcLivePushLogLevelDebug];
    [AlivcLiveBase setLogPath:NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject maxPartFileSizeInKB:1024*100];
#endif
}

- (void)setCurrentUser:(AUIRoomUser *)user {
    AUIRoomAccount.me.userId = user.userId ?: @"";
    AUIRoomAccount.me.avatar = user.avatar ?: @"";
    AUIRoomAccount.me.nickName = user.nickName ?: @"";
    AUIRoomAccount.me.token = user.token ?: @"";
}

- (AUIRoomUser *)currentUser {
    return AUIRoomAccount.me;
}

- (void)login:(void(^)(BOOL success))completedBlock {
    [AUIRoomMessage.currentService login:completedBlock];
}

- (void)logout {
    [AUIRoomMessage.currentService logout];
}

- (void)createLiveCore:(AUIRoomLiveMode)mode title:(NSString *)title notice:(NSString *)notice currentVC:(UIViewController *)currentVC completed:(void(^)(BOOL success, AUIRoomLiveInfoModel *model))completedBlock {
    [self login:^(BOOL success) {
        if (!success) {
            [AVAlertController show:@"直播间登入失败" vc:currentVC];
            if (completedBlock) {
                completedBlock(NO, nil);
            }
            return;
        }
        
        [AUIRoomAppServer createLive:nil mode:mode title:title ?: [NSString stringWithFormat:@"%@的直播", AUIRoomAccount.me.nickName] notice:notice extend:nil completed:^(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error) {
            if (error) {
                [AVAlertController show:@"创建直播间失败" vc:currentVC];
                if (completedBlock) {
                    completedBlock(NO, nil);
                }
                return;
            }
            
            AUILiveRoomAnchorViewController *vc = [[AUILiveRoomAnchorViewController alloc] initWithModel:model withJoinList:nil];
            [currentVC.navigationController pushViewController:vc animated:YES];
            
            if (completedBlock) {
                completedBlock(YES, model);
            }
        }];
    }];
}

- (void)createLive:(AUIRoomLiveMode)mode title:(NSString *)title notice:(NSString *)notice currentVC:(UIViewController *)currentVC completed:(void(^)(BOOL success, AUIRoomLiveInfoModel *model))completedBlock {
    __weak typeof(self) weakSelf = self;
    AVProgressHUD *loading1 = [AVProgressHUD ShowHUDAddedTo:currentVC.view animated:YES];
    loading1.labelText = @"正在创建直播间，请等待";
    
    [AUIRoomBeautyManager checkResourceWithCurrentView:currentVC.view completed:^(BOOL completed) {
        if (!completed) {
            [loading1 hideAnimated:YES];
            [AVAlertController showWithTitle:@"初始化美颜失败，是否继续？" message:@"继续可能导致没美颜效果" cancelTitle:@"取消" okTitle:@"继续" onCompleted:^(BOOL isCanced) {
                if (isCanced) {
                    return;
                }
                
                AVProgressHUD *loading2 = [AVProgressHUD ShowHUDAddedTo:currentVC.view animated:YES];
                loading2.labelText = @"正在创建直播间，请等待";
                [weakSelf createLiveCore:mode title:title notice:notice currentVC:currentVC completed:^(BOOL success, AUIRoomLiveInfoModel * _Nullable model) {
                    [loading2 hideAnimated:YES];
                    if (completedBlock) {
                        completedBlock(success, model);
                    }
                }];
            }];
            return;
        }
        [weakSelf createLiveCore:mode title:title notice:notice currentVC:currentVC completed:^(BOOL success, AUIRoomLiveInfoModel * _Nullable model) {
            [loading1 hideAnimated:YES];
            if (completedBlock) {
                completedBlock(success, model);
            }
        }];
    }];
}

- (void)fetchLinkMicJoinList:(AUIRoomLiveInfoModel *)model completed:(void(^)(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *joinList, NSError *error))completed {
    if (model.mode == AUIRoomLiveModeLinkMic) {
        [AUIRoomAppServer queryLinkMicJoinList:model.live_id completed:^(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> * _Nullable models, NSError * _Nullable error) {
            if (completed) {
                completed(models, error);
            }
        }];
        return;
    }
    if (completed) {
        completed(nil, nil);
    }
}

- (void)joinLiveWithLiveId:(NSString *)liveId currentVC:(UIViewController *)currentVC completed:(void(^)(BOOL success))completedBlock {
    __weak typeof(self) weakSelf = self;
    AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:currentVC.view animated:YES];
    loading.labelText = @"正在加入直播间，请等待";
    // 登录IM
    [AUIRoomMessage.currentService login:^(BOOL success) {
        if (!success) {
            [loading hideAnimated:YES];
            [AVAlertController show:@"直播间登入失败" vc:currentVC];
            if (completedBlock) {
                completedBlock(NO);
            }
            return;
        }
        
        // 获取最新直播信息
        [AUIRoomAppServer fetchLive:liveId userId:nil completed:^(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error) {
            if (error) {
                [loading hideAnimated:YES];
                [AVAlertController show:@"直播间刷新失败" vc:currentVC];
                if (completedBlock) {
                    completedBlock(NO);
                }
                return;
            }
            
            // 获取上麦信息
            [weakSelf fetchLinkMicJoinList:model completed:^(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *joinList, NSError *error) {
                
                [loading hideAnimated:YES];
                if (error) {
                    [AVAlertController show:@"获取上麦列表失败" vc:currentVC];
                    if (completedBlock) {
                        completedBlock(NO);
                    }
                    return;
                }
                
                if ([model.anchor_id isEqualToString:AUIRoomAccount.me.userId]) {
                    AUILiveRoomAnchorViewController *vc = [[AUILiveRoomAnchorViewController alloc] initWithModel:model withJoinList:joinList];
                    [currentVC.navigationController pushViewController:vc animated:YES];
                }
                else {
                    AUILiveRoomAudienceViewController *vc = [[AUILiveRoomAudienceViewController alloc] initWithModel:model withJoinList:joinList];
                    [currentVC.navigationController pushViewController:vc animated:YES];
                }
                if (completedBlock) {
                    completedBlock(YES);
                }
            }];
        }];
    }];
}

- (void)joinLive:(AUIRoomLiveInfoModel *)model currentVC:(UIViewController *)currentVC completed:(void(^)(BOOL success))completedBlock {
    [self joinLiveWithLiveId:model.live_id currentVC:currentVC completed:completedBlock];
}

@end
