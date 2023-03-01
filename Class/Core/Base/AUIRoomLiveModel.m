//
//  AUIRoomLiveModel.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/8/31.
//

#import "AUIRoomLiveModel.h"

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
        _rtmp_url = [data objectForKey:@"rtmp_url"];
        _rts_url = [data objectForKey:@"rts_url"];
        _srt_url = [data objectForKey:@"srt_url"];
    }
    return self;
}

@end

@implementation AUIRoomLivePullModel

- (instancetype)initWithResponseData:(NSDictionary *)data {
    self = [super initWithResponseData:data];
    if (self) {
        _flv_url = [data objectForKey:@"flv_url"];
        _flv_oriaac_url = [data objectForKey:@"flv_oriaac_url"];
        _hls_url = [data objectForKey:@"hls_url"];
        _rtmp_url = [data objectForKey:@"rtmp_url"];
        _rts_url = [data objectForKey:@"rts_url"];
    }
    return self;
}

@end

@implementation AUIRoomLiveLinkMicJoinInfoModel

- (instancetype)initWithResponseData:(NSDictionary *)data {
    self = [super initWithResponseData:data];
    if (self) {
        _userId = [data objectForKey:@"user_id"];
        _userNick = [data objectForKey:@"user_nick"];
        _userAvatar = [data objectForKey:@"user_avatar"];
        _rtcPullUrl = [data objectForKey:@"rtc_pull_url"];
        _cameraOpened = [[data objectForKey:@"camera_opened"] boolValue];
        _micOpened = [[data objectForKey:@"mic_opened"] boolValue];
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
        NSDictionary *dict = [data objectForKey:@"cdn_pull_info"];
        if ([dict isKindOfClass:NSDictionary.class]) {
            _cdn_pull_info = [[AUIRoomLivePullModel alloc] initWithResponseData:dict];
        }
        _rtc_pull_url = [data objectForKey:@"rtc_pull_url"];
        _rtc_push_url = [data objectForKey:@"rtc_push_url"];
    }
    return self;
}

@end

@implementation AUIRoomLiveMetricsModel

- (instancetype)initWithResponseData:(NSDictionary *)data {
    self = [super initWithResponseData:data];
    if (self) {
        _like_count = [[data objectForKey:@"like_count"] integerValue];
        _online_count = [[data objectForKey:@"online_count"] integerValue];
        _total_count = [[data objectForKey:@"total_count"] integerValue];
        _pv = [[data objectForKey:@"pv"] integerValue];
        _uv = [[data objectForKey:@"uv"] integerValue];
    }
    return self;
}

@end


@implementation AUIRoomLiveVodInfoModel

- (instancetype)initWithResponseData:(NSDictionary *)data {
    self = [super initWithResponseData:data];
    if (self) {
        NSInteger status = [[data objectForKey:@"status"] integerValue];
        NSArray *playList = [data objectForKey:@"playlist"];
        if ([playList isKindOfClass:NSArray.class]) {
            NSDictionary *first = playList.firstObject;
            if ([first isKindOfClass:NSDictionary.class]) {
                _play_url = [first objectForKey:@"play_url"];
            }
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
        _live_id = [data objectForKey:@"id"];
        _mode = [[data objectForKey:@"mode"] integerValue];
        _anchor_id = [data objectForKey:@"anchor_id"];
        _chat_id = [data objectForKey:@"chat_id"];
        _created_at = [data objectForKey:@"created_at"];
        _update_at = [data objectForKey:@"update_at"];
        _title = [data objectForKey:@"title"];
        _pk_id = [data objectForKey:@"pk_id"];
        _status = [[data objectForKey:@"status"] integerValue];
        _notice = [data objectForKey:@"notice"];
        
        NSString *extendJson = [data objectForKey:@"extends"];
        _extends = [NSJSONSerialization JSONObjectWithData:[extendJson dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];

        NSDictionary *metrics_dict = [data objectForKey:@"metrics"];
        if ([metrics_dict isKindOfClass:NSDictionary.class]) {
            _metrics = [[AUIRoomLiveMetricsModel alloc] initWithResponseData:metrics_dict];
        }
        
        NSDictionary *pull_dict = [data objectForKey:@"pull_url_info"];
        if ([pull_dict isKindOfClass:NSDictionary.class]) {
            _pull_url_info = [[AUIRoomLivePullModel alloc] initWithResponseData:pull_dict];
        }
        
        NSDictionary *push_dict = [data objectForKey:@"push_url_info"];
        if ([push_dict isKindOfClass:NSDictionary.class]) {
            _push_url_info = [[AUIRoomLivePushModel alloc] initWithResponseData:push_dict];
        }
        
        NSDictionary *link_dict = [data objectForKey:@"link_info"];
        if ([link_dict isKindOfClass:NSDictionary.class]) {
            _link_info = [[AUIRoomLiveLinkMicModel alloc] initWithResponseData:link_dict];
        }
        
        NSDictionary *vod_dict = [data objectForKey:@"vod_info"];
        if ([vod_dict isKindOfClass:NSDictionary.class]) {
            _vod_info = [[AUIRoomLiveVodInfoModel alloc] initWithResponseData:vod_dict];
        }
        
        _anchor_nickName = [data objectForKey:@"anchor_nick"];
        if (_anchor_nickName.length == 0) {
            _anchor_nickName = [_extends objectForKey:@"userNick"];
        }
        _anchor_avatar = [_extends objectForKey:@"userAvatar"];
    }
    return self;
}

- (void)updateStatus:(AUIRoomLiveStatus)status {
    _status = status;
}

@end

