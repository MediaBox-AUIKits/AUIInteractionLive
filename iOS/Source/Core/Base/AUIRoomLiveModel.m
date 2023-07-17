//
//  AUIRoomLiveModel.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/8/31.
//

#import "AUIRoomLiveModel.h"
#import "AUIFoundation.h"

@implementation AUIRoomLiveModel

- (instancetype)initWithResponseData:(NSDictionary *)data {
    self = [self init];
    if (self) {
        
    }
    return self;
}

@end

@implementation AUIRoomLivePushModel

- (instancetype)initWithResponseData:(NSDictionary *)data {
    self = [super initWithResponseData:data];
    if (self) {
        _rtmp_url = [data av_stringValueForKey:@"rtmp_url"];
        _rts_url = [data av_stringValueForKey:@"rts_url"];
        _srt_url = [data av_stringValueForKey:@"srt_url"];
    }
    return self;
}

@end

@implementation AUIRoomLivePullModel

- (instancetype)initWithResponseData:(NSDictionary *)data {
    self = [super initWithResponseData:data];
    if (self) {
        _flv_url = [data av_stringValueForKey:@"flv_url"];
        _flv_oriaac_url = [data av_stringValueForKey:@"flv_oriaac_url"];
        _hls_url = [data av_stringValueForKey:@"hls_url"];
        _rtmp_url = [data av_stringValueForKey:@"rtmp_url"];
        _rts_url = [data av_stringValueForKey:@"rts_url"];
    }
    return self;
}

@end

@implementation AUIRoomLiveLinkMicJoinInfoModel

- (instancetype)initWithResponseData:(NSDictionary *)data {
    self = [super initWithResponseData:data];
    if (self) {
        _userId = [data av_stringValueForKey:@"user_id"];
        _userNick = [data av_stringValueForKey:@"user_nick"];
        _userAvatar = [data av_stringValueForKey:@"user_avatar"];
        _rtcPullUrl = [data av_stringValueForKey:@"rtc_pull_url"];
        _cameraOpened = [data av_intValueForKey:@"camera_opened"];
        _micOpened = [data av_intValueForKey:@"mic_opened"];
    }
    return self;
}

- (instancetype)init:(NSString *)userId userNick:(NSString *)userNick userAvatar:(nonnull NSString *)userAvatar rtcPullUrl:(nonnull NSString *)rtcPullUrl {
    self = [super init];
    if (self) {
        _userId = userId;
        _userNick = userNick;
        _userAvatar = userAvatar;
        _rtcPullUrl = rtcPullUrl;
        _cameraOpened = YES;
        _micOpened = YES;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    return @{
        @"user_id":_userId ?: @"",
        @"user_nick":_userNick ?: @"",
        @"user_avatar":_userAvatar ?: @"",
        @"rtc_pull_url":_rtcPullUrl ?: @"",
        @"mic_opened":@(_micOpened),
        @"camera_opened":@(_cameraOpened),
    };
}


@end

@implementation AUIRoomLiveLinkMicModel

- (instancetype)initWithResponseData:(NSDictionary *)data {
    self = [super initWithResponseData:data];
    if (self) {
        NSDictionary *dict = [data av_dictionaryValueForKey:@"cdn_pull_info"];
        if (dict) {
            _cdn_pull_info = [[AUIRoomLivePullModel alloc] initWithResponseData:dict];
        }
        _rtc_pull_url = [data av_stringValueForKey:@"rtc_pull_url"];
        _rtc_push_url = [data av_stringValueForKey:@"rtc_push_url"];
    }
    return self;
}

@end

@implementation AUIRoomLiveMetricsModel

- (instancetype)initWithResponseData:(NSDictionary *)data {
    self = [super initWithResponseData:data];
    if (self) {
        _like_count = [data av_intValueForKey:@"like_count"];
        _online_count = [data av_intValueForKey:@"online_count"];
        _total_count = [data av_intValueForKey:@"total_count"];
        _pv = [data av_intValueForKey:@"pv"];
        _uv = [data av_intValueForKey:@"uv"];
    }
    return self;
}

@end


@implementation AUIRoomLiveVodInfoModel

- (instancetype)initWithResponseData:(NSDictionary *)data {
    self = [super initWithResponseData:data];
    if (self) {
        NSInteger status = [data av_intValueForKey:@"status"];
        NSArray<NSDictionary *> *playList = [data av_dictArrayValueForKey:@"playlist"];
        NSDictionary *first = playList.firstObject;
        if (first) {
            _play_url = [first av_stringValueForKey:@"play_url"];
        }
        if (status == 1 && _play_url.length > 0) {
            _isValid = YES;
        }
    }
    return self;
}

@end


@implementation AUIRoomLiveInfoModel

- (instancetype)initWithResponseData:(NSDictionary *)data {
    self = [super initWithResponseData:data];
    if (self) {
        _live_id = [data av_stringValueForKey:@"id"];
        _mode = [data av_intValueForKey:@"mode"];
        _anchor_id = [data av_stringValueForKey:@"anchor_id"];
        _chat_id = [data av_stringValueForKey:@"chat_id"];
        _created_at = [data av_stringValueForKey:@"created_at"];
        _update_at = [data av_stringValueForKey:@"update_at"];
        _title = [data av_stringValueForKey:@"title"];
        _pk_id = [data av_stringValueForKey:@"pk_id"];
        _status = [data av_intValueForKey:@"status"];
        _notice = [data av_stringValueForKey:@"notice"];
        
        NSString *extendJson = [data av_stringValueForKey:@"extends"];
        if (extendJson.length > 0) {
            _extends = [extendJson av_jsonDict];
        }

        NSDictionary *metrics_dict = [data av_dictionaryValueForKey:@"metrics"];
        if (metrics_dict) {
            _metrics = [[AUIRoomLiveMetricsModel alloc] initWithResponseData:metrics_dict];
        }
        
        NSDictionary *pull_dict = [data av_dictionaryValueForKey:@"pull_url_info"];
        if (pull_dict) {
            _pull_url_info = [[AUIRoomLivePullModel alloc] initWithResponseData:pull_dict];
        }
        
        NSDictionary *push_dict = [data av_dictionaryValueForKey:@"push_url_info"];
        if (push_dict) {
            _push_url_info = [[AUIRoomLivePushModel alloc] initWithResponseData:push_dict];
        }
        
        NSDictionary *link_dict = [data av_dictionaryValueForKey:@"link_info"];
        if (link_dict) {
            _link_info = [[AUIRoomLiveLinkMicModel alloc] initWithResponseData:link_dict];
        }
        
        NSDictionary *vod_dict = [data av_dictionaryValueForKey:@"vod_info"];
        if (vod_dict) {
            _vod_info = [[AUIRoomLiveVodInfoModel alloc] initWithResponseData:vod_dict];
        }
        
        _anchor_nickName = [data av_stringValueForKey:@"anchor_nick"];
        if (_anchor_nickName.length == 0) {
            _anchor_nickName = [_extends av_stringValueForKey:@"userNick"];
        }
        _anchor_avatar = [_extends av_stringValueForKey:@"userAvatar"];
    }
    return self;
}

- (void)updateStatus:(AUIRoomLiveStatus)status {
    _status = status;
}

@end

