//
//  AUIRoomLiveModel.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/8/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomLiveModel : NSObject

- (instancetype)initWithResponseData:(NSDictionary *)data;

@end

@interface AUIRoomLivePushModel : AUIRoomLiveModel

@property (nonatomic, copy, readonly) NSString *rtmp_url;
@property (nonatomic, copy, readonly) NSString *rts_url;
@property (nonatomic, copy, readonly) NSString *srt_url;

@end

@interface AUIRoomLivePullModel : AUIRoomLiveModel

@property (nonatomic, copy, readonly) NSString *flv_url;
@property (nonatomic, copy, readonly) NSString *flv_oriaac_url;
@property (nonatomic, copy, readonly) NSString *hls_url;
@property (nonatomic, copy, readonly) NSString *rtmp_url;
@property (nonatomic, copy, readonly) NSString *rts_url;


@end

// 上麦信息
@interface AUIRoomLiveLinkMicJoinInfoModel : AUIRoomLiveModel

@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, readonly) NSString *userNick;
@property (nonatomic, copy, readonly) NSString *userAvatar;
@property (nonatomic, copy, readonly) NSString *rtcPullUrl;
@property (nonatomic, assign) BOOL cameraOpened;
@property (nonatomic, assign) BOOL micOpened;

- (instancetype)init:(NSString *)userId userNick:(NSString *)userNick userAvatar:(NSString *)userAvatar rtcPullUrl:(NSString *)rtcPullUrl;

- (NSDictionary *)toDictionary;


@end

@interface AUIRoomLiveLinkMicModel : AUIRoomLiveModel

@property (nonatomic, strong, readonly) AUIRoomLivePullModel *cdn_pull_info;
@property (nonatomic, copy, readonly) NSString *rtc_pull_url;
@property (nonatomic, copy, readonly) NSString *rtc_push_url;

@end

@interface AUIRoomLiveMetricsModel : AUIRoomLiveModel

@property (nonatomic, assign, readonly) NSInteger pv;
@property (nonatomic, assign, readonly) NSInteger uv;
@property (nonatomic, assign, readonly) NSInteger like_count;
@property (nonatomic, assign, readonly) NSInteger online_count;
@property (nonatomic, assign, readonly) NSInteger total_count;

@end


@interface AUIRoomLiveVodInfoModel : AUIRoomLiveModel

@property (nonatomic, assign, readonly) BOOL isValid;
@property (nonatomic, copy, readonly) NSString *play_url;

@end

typedef NS_ENUM(NSUInteger, AUIRoomLiveStatus) {
    AUIRoomLiveStatusNone = 0,
    AUIRoomLiveStatusLiving,
    AUIRoomLiveStatusFinished,
};

typedef NS_ENUM(NSUInteger, AUIRoomLiveMode) {
    AUIRoomLiveModeBase = 0,
    AUIRoomLiveModeLinkMic,
};

@interface AUIRoomLiveInfoModel : AUIRoomLiveModel

@property (nonatomic, copy, readonly) NSString *live_id;
@property (nonatomic, assign, readonly) AUIRoomLiveStatus status;
@property (nonatomic, assign, readonly) AUIRoomLiveMode mode;
@property (nonatomic, copy, readonly) NSString *anchor_id;
@property (nonatomic, copy, readonly) NSString *anchor_nickName;
@property (nonatomic, copy, readonly) NSString *anchor_avatar;
@property (nonatomic, copy, readonly) NSString *chat_id;
@property (nonatomic, copy, readonly) NSString *created_at;
@property (nonatomic, copy, readonly) NSString *update_at;
@property (nonatomic, copy, readonly) NSDictionary *extends;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *notice;
@property (nonatomic, copy, readonly) NSString *cover;
@property (nonatomic, copy, readonly) NSString *pk_id;
@property (nonatomic, strong, readonly) AUIRoomLiveMetricsModel *metrics;
@property (nonatomic, strong, readonly) AUIRoomLivePullModel *pull_url_info;
@property (nonatomic, strong, readonly) AUIRoomLivePushModel *push_url_info;
@property (nonatomic, strong, readonly) AUIRoomLiveLinkMicModel *link_info;
@property (nonatomic, strong, readonly) AUIRoomLiveVodInfoModel *vod_info;

- (void)updateStatus:(AUIRoomLiveStatus)status;

@end

NS_ASSUME_NONNULL_END
