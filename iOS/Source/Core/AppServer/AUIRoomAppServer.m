//
//  AUIRoomAppServer.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/8/31.
//

#import "AUIRoomAppServer.h"
#import "AUIRoomAccount.h"

@implementation AUIRoomAppServer

static NSString *g_serviceUrl = nil;
+ (void)setServiceUrl:(NSString *)url {
    g_serviceUrl = url;
}

+ (NSString *)serviceUrl {
    return g_serviceUrl;
}

+ (NSString *)finalServiceUrl {
    NSAssert(g_serviceUrl.length > 0, @"请先设置AppServer地址");
    return g_serviceUrl;
}

static NSArray<NSString *> *g_imServers = nil;
+ (void)setIMServers:(NSArray<NSString *> *)imServers {
    g_imServers = imServers;
}

+ (NSArray<NSString *> *)IMServers {
    return g_imServers ?: @[];
}

static BOOL g_staging = NO;
+ (void)setEnv:(BOOL)staging {
    g_staging = staging;
}
+ (BOOL)stagingEnv {
    return g_staging;
}

+ (NSString *)envString {
    return g_staging ? @"staging" : @"production";
}

+ (NSString *)jsonStringWithDict:(NSDictionary *)dict {
    if (!dict) {
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (void)requestWithPath:(NSString *)path bodyDic:(NSDictionary *)bodyDic completionHandler:(void (^)(NSURLResponse *response, id responseObject,  NSError * error))completionHandler {
        
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [self finalServiceUrl], path];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"accept"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:[self envString] forHTTPHeaderField:@"x-live-env"];  // staging/production
    [urlRequest addValue:[NSString stringWithFormat:@"Bearer %@", AUIRoomAccount.myAccount.myToken ?: @"live"] forHTTPHeaderField:@"Authorization"];
    urlRequest.HTTPMethod = @"POST";
    if (bodyDic) {
        urlRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:bodyDic options:NSJSONWritingPrettyPrinted error:nil];
    }
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
                                            completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                if (completionHandler) {
                    completionHandler(response, nil, error);
                }
                return;
            }
            
            NSError *jsonError = nil;
            id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if (jsonError || [jsonObj isKindOfClass:NSNull.class]) {
                if (completionHandler) {
                    completionHandler(response, nil, jsonError);
                }
                return;
            }
            
            if ([response isKindOfClass:NSHTTPURLResponse.class]) {
                NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
                if (http.statusCode == 200) {
                    if (completionHandler) {
                        completionHandler(response, jsonObj, nil);
                    }
                }
                else if (http.statusCode >= 400) {
                    NSError *retError = [NSError errorWithDomain:@"live.service" code:http.statusCode userInfo:jsonObj];
                    if (completionHandler) {
                        completionHandler(response, nil, retError);
                    }
                }
                return;
            }
        });
    }];
    
    [task resume];
}

+ (NSDictionary *)finalExtends:(NSDictionary *)param {
    NSMutableDictionary *extends = [NSMutableDictionary dictionaryWithDictionary:param];
    [extends setObject:AUIRoomAccount.me.nickName ?: @"" forKey:@"userNick"];
    [extends setObject:AUIRoomAccount.me.avatar ?: @"" forKey:@"userAvatar"];
    return extends;
}

+ (void)fetchToken:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completed {
    NSDictionary *body = @{
        @"device_id":AUIRoomAccount.deviceId ?: @"",
        @"device_type":@"ios",
        @"user_id":AUIRoomAccount.me.userId ?: @"",
        @"im_server":[self IMServers],
        @"role":@"user",
    };
    NSString *path = @"/api/v2/live/token";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error || ![responseObject isKindOfClass:NSDictionary.class]) {
            if (completed) {
                completed(nil, error);
            }
            return;
        }

        if (completed) {
            completed(responseObject, nil);
        }
    }];
}

+ (void)createLive:(NSInteger)mode title:(NSString *)title notice:(NSString *)notice extend:(NSDictionary * _Nullable)extend completed:(void (^)(AUIRoomLiveInfoModel * _Nullable, NSError * _Nullable))completed {
    NSDictionary *body = @{
        @"anchor":AUIRoomAccount.me.userId ?: @"",
        @"anchor_nick":AUIRoomAccount.me.nickName ?: @"",
        @"im_server":[self IMServers],
        @"mode":@(mode),
        @"title":title ?: @"",
        @"notice":notice ?: @"",
        @"extends":[self jsonStringWithDict:[self finalExtends:extend]]
    };
    NSString *path = @"/api/v2/live/create";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(nil, error);
            }
            return;
        }
        AUIRoomLiveInfoModel *model = nil;
        if (responseObject && [responseObject isKindOfClass:NSDictionary.class]) {
            model = [[AUIRoomLiveInfoModel alloc] initWithResponseData:responseObject];
        }
        if (completed) {
            completed(model, nil);
        }
    }];
}

+ (void)startLive:(NSString *)liveId completed:(void (^)(AUIRoomLiveInfoModel * _Nullable, NSError * _Nullable))completed {
    NSDictionary *body = @{
        @"id":liveId ?: @"",
        @"user_id":AUIRoomAccount.me.userId ?: @"",
    };
    NSString *path = @"/api/v1/live/start";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(nil, error);
            }
            return;
        }
        AUIRoomLiveInfoModel *model = nil;
        if (responseObject && [responseObject isKindOfClass:NSDictionary.class]) {
            model = [[AUIRoomLiveInfoModel alloc] initWithResponseData:responseObject];
        }
        if (completed) {
            completed(model, nil);
        }
    }];
}

+ (void)stopLive:(NSString *)liveId completed:(void (^)(AUIRoomLiveInfoModel * _Nullable, NSError * _Nullable))completed {
    NSDictionary *body = @{
        @"id":liveId ?: @"",
        @"user_id":AUIRoomAccount.me.userId ?: @"",
    };
    NSString *path = @"/api/v1/live/stop";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(nil, error);
            }
            return;
        }
        AUIRoomLiveInfoModel *model = nil;
        if (responseObject && [responseObject isKindOfClass:NSDictionary.class]) {
            model = [[AUIRoomLiveInfoModel alloc] initWithResponseData:responseObject];
        }
        if (completed) {
            completed(model, nil);
        }
    }];
}

+ (void)muteAll:(NSString *)liveId completed:(void (^)(NSError * _Nullable))completed {
    // 向服务端请求全体禁言接口，目前APPServer仅支持融云聊天室
    NSDictionary *body = @{
        @"chatroom_id":liveId ?: @"",
    };
    NSString *path = @"/api/v1/live/muteChatroom";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(error);
            }
            return;
        }
        
        BOOL success = NO;
        if (responseObject && [responseObject isKindOfClass:NSDictionary.class]) {
            success = [[responseObject objectForKey:@"code"] integerValue] == 200;
        }
        if (completed) {
            completed(success ? nil : [NSError errorWithDomain:@"live.service" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"操作失败"}]);
        }
    }];
}

+ (void)cancelMuteAll:(NSString *)liveId completed:(void (^)(NSError * _Nullable))completed {
    // 向服务端请求取消全体禁言接口，目前APPServer仅支持融云聊天室
    NSDictionary *body = @{
        @"chatroom_id":liveId ?: @"",
    };
    NSString *path = @"/api/v1/live/cancelMuteChatroom";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(error);
            }
            return;
        }
        
        BOOL success = NO;
        if (responseObject && [responseObject isKindOfClass:NSDictionary.class]) {
            success = [[responseObject objectForKey:@"code"] integerValue] == 200;
        }
        if (completed) {
            completed(success ? nil : [NSError errorWithDomain:@"live.service" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"操作失败"}]);
        }
    }];
}

+ (void)queryMuteAll:(NSString *)liveId completed:(void (^)(BOOL, NSError * _Nullable))completed {
    // 向服务端请求是否开启全体禁言接口，目前APPServer仅支持融云聊天室
    NSDictionary *body = @{
        @"chatroom_id":liveId ?: @"",
    };
    NSString *path = @"/api/v1/live/isMuteChatroom";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(NO, error);
            }
            return;
        }
        
        BOOL success = NO;
        BOOL mute = NO;
        if (responseObject && [responseObject isKindOfClass:NSDictionary.class]) {
            success = [[responseObject objectForKey:@"code"] integerValue] == 200;
            mute = [[responseObject objectForKey:@"mute"] boolValue];
        }
        if (completed) {
            completed(mute, success ? nil : [NSError errorWithDomain:@"live.service" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"操作失败"}]);
        }
    }];
}

+ (void)sendLike:(NSString *)liveId count:(NSUInteger)count completed:(void (^)(NSError * _Nullable))completed {
    // TODO: 向服务端请求发送点赞数据接口，APPServer当前是写死数据，需要自行开发
    NSDictionary *body = @{
        @"like_count":@(count),
        @"chatroom_id":liveId ?: @"",
        @"user_id":AUIRoomAccount.me.userId ?: @"",
    };
    NSString *path = @"/api/v1/live/sendLikeMessage";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(error);
            }
            return;
        }
        
        BOOL success = NO;
        if (responseObject && [responseObject isKindOfClass:NSDictionary.class]) {
            success = [[responseObject objectForKey:@"code"] integerValue] == 200;
        }
        if (completed) {
            completed(success ? nil : [NSError errorWithDomain:@"live.service" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"操作失败"}]);
        }
    }];
}

+ (void)fetchLiveList:(NSUInteger)pageNum pageSize:(NSUInteger)pageSize completed:(void (^)(NSArray<AUIRoomLiveInfoModel *> * _Nullable, NSError * _Nullable))completed {
    NSDictionary *body = @{
        @"page_num":@(pageNum),
        @"page_size":@(pageSize),
        @"user_id":AUIRoomAccount.me.userId ?: @"",
        @"im_server":[self IMServers],
    };
    NSString *path = @"/api/v1/live/list";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(nil, error);
            }
            return;
        }
        NSMutableArray *models = [NSMutableArray array];
        if (responseObject && [responseObject isKindOfClass:NSArray.class]) {
            NSArray *arr = responseObject;
            [arr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                AUIRoomLiveInfoModel *model = [[AUIRoomLiveInfoModel alloc] initWithResponseData:obj];
                [models addObject:model];
            }];
        }
        if (completed) {
            completed(models, nil);
        }
    }];
}

+ (void)fetchLive:(NSString *)liveId userId:(NSString *)userId completed:(void (^)(AUIRoomLiveInfoModel * _Nullable, NSError * _Nullable))completed {
    NSDictionary *body = @{
        @"id":liveId ?: @"",
        @"user_id":(userId ?: AUIRoomAccount.me.userId) ?: @"",
        @"im_server":[self IMServers],
    };
    NSString *path = @"/api/v1/live/get";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(nil, error);
            }
            return;
        }
        AUIRoomLiveInfoModel *model = nil;
        if (responseObject && [responseObject isKindOfClass:NSDictionary.class]) {
            model = [[AUIRoomLiveInfoModel alloc] initWithResponseData:responseObject];
        }
        if (completed) {
            completed(model, nil);
        }
    }];
}

+ (void)fetchStatistics:(NSString *)liveId completed:(void (^)(AUIRoomLiveMetricsModel * _Nullable, NSError * _Nullable))completed {
    // TODO: 向服务端请求直播间统计数据接口，APPServer当前是写死数据，需要自行开发
    NSDictionary *body = @{
        @"chatroom_id":liveId ?: @"",
    };
    NSString *path = @"/api/v1/live/getStatistics";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(nil, error);
            }
            return;
        }
        
        BOOL success = NO;
        AUIRoomLiveMetricsModel *model = nil;
        if (responseObject && [responseObject isKindOfClass:NSDictionary.class]) {
            success = [[responseObject objectForKey:@"code"] integerValue] == 200;
            model = [[AUIRoomLiveMetricsModel alloc] initWithResponseData:[responseObject objectForKey:@"metrics"]];
        }
        if (completed) {
            completed(model, success ? nil : [NSError errorWithDomain:@"live.service" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"操作失败"}]);
        }
    }];
}

+ (void)updateLive:(NSString *)liveId title:(NSString *)title notice:(NSString *)notice extend:(NSDictionary *)extend completed:(void (^)(AUIRoomLiveInfoModel * _Nullable, NSError * _Nullable))completed {
    
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setObject:liveId ?: @"" forKey:@"id"];
    if (title) {
        [body setObject:title forKey:@"title"];
    }
    if (notice) {
        [body setObject:notice forKey:@"notice"];
    }
    if (extend) {
        [body setObject:[self jsonStringWithDict:[self finalExtends:extend]] forKey:@"extends"];
    }
    
    NSString *path = @"/api/v1/live/update";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(nil, error);
            }
            return;
        }
        AUIRoomLiveInfoModel *model = nil;
        if (responseObject && [responseObject isKindOfClass:NSDictionary.class]) {
            model = [[AUIRoomLiveInfoModel alloc] initWithResponseData:responseObject];
        }
        if (completed) {
            completed(model, nil);
        }
    }];
}

+ (void)queryLinkMicJoinList:(NSString *)liveId completed:(void(^)(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> * _Nullable models, NSError * _Nullable error))completed {
    
    NSDictionary *body = @{
        @"id":liveId ?: @"",
    };
    NSString *path = @"/api/v1/live/getMeetingInfo";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(nil, error);
            }
            return;
        }
        NSMutableArray<AUIRoomLiveLinkMicJoinInfoModel *> *list = [NSMutableArray array];
        if (responseObject && [responseObject isKindOfClass:NSDictionary.class]) {
            NSArray *listDict = [responseObject objectForKey:@"members"];
            if ([listDict isKindOfClass:NSArray.class]) {
                [listDict enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSDictionary *dict = obj;
                    if ([dict isKindOfClass:NSDictionary.class]) {
                        AUIRoomLiveLinkMicJoinInfoModel *info = [[AUIRoomLiveLinkMicJoinInfoModel alloc] initWithResponseData:dict];
                        [list addObject:info];
                    }
                }];
            }
        }
        
        // for test
//            for (NSUInteger i=0; i<1; i++) {
//                AUIRoomLiveLinkMicJoinInfoModel *joinInfo = [[AUIRoomLiveLinkMicJoinInfoModel alloc] init:[NSString stringWithFormat:@"uid%tu", i] userNick:[NSString stringWithFormat:@"哈哈的点点滴滴哈哈%tu", i] userAvatar:@"https://img.alicdn.com/imgextra/i4/O1CN01kpUDlF1sEgEJMKHH8_!!6000000005735-2-tps-80-80.png" rtcPullUrl:@""];
//                joinInfo.cameraOpened = YES;
//                joinInfo.micOpened = NO;
//                [list addObject:joinInfo];
//            }
        
        if (completed) {
            completed(list, nil);
        }
    }];
}

+ (void)updateLinkMicJoinList:(NSString *)liveId joinList:(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)joinList completed:(void (^)(NSError * _Nullable))completed {
    
    NSMutableArray *list = [NSMutableArray array];
    [joinList enumerateObjectsUsingBlock:^(AUIRoomLiveLinkMicJoinInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [list addObject:[obj toDictionary]];
    }];
    
    NSDictionary *body = @{
        @"id":liveId ?: @"",
        @"members":list
    };
    NSString *path = @"/api/v1/live/updateMeetingInfo";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(error);
            }
            return;
        }
        if (completed) {
            completed(nil);
        }
    }];
}

@end
