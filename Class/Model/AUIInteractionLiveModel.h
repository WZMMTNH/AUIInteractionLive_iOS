//
//  AUIInteractionLiveModel.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/8/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIInteractionLiveModel : NSObject

- (instancetype)initWithResponseData:(NSDictionary *)data;

@end

@interface AUIInteractionLivePushModel : AUIInteractionLiveModel

@property (nonatomic, copy, readonly) NSString *rtmp_url;
@property (nonatomic, copy, readonly) NSString *rts_url;
@property (nonatomic, copy, readonly) NSString *srt_url;

@end

@interface AUIInteractionLivePullModel : AUIInteractionLiveModel

@property (nonatomic, copy, readonly) NSString *flv_url;
@property (nonatomic, copy, readonly) NSString *hls_url;
@property (nonatomic, copy, readonly) NSString *rtmp_url;
@property (nonatomic, copy, readonly) NSString *rts_url;

@end

// 上麦信息
@interface AUIInteractionLiveLinkMicJoinInfoModel : AUIInteractionLiveModel

@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, readonly) NSString *userNick;
@property (nonatomic, copy, readonly) NSString *userAvatar;
@property (nonatomic, copy, readonly) NSString *rtcPullUrl;
@property (nonatomic, assign) BOOL cameraOpened;
@property (nonatomic, assign) BOOL micOpened;

- (instancetype)init:(NSString *)userId userNick:(NSString *)userNick userAvatar:(NSString *)userAvatar rtcPullUrl:(NSString *)rtcPullUrl;

- (NSDictionary *)toDictionary;


@end

@interface AUIInteractionLiveLinkMicModel : AUIInteractionLiveModel

@property (nonatomic, strong, readonly) AUIInteractionLivePullModel *cdn_pull_info;
@property (nonatomic, copy, readonly) NSString *rtc_pull_url;
@property (nonatomic, copy, readonly) NSString *rtc_push_url;

@end

@interface AUIInteractionLiveMetricsModel : AUIInteractionLiveModel

@property (nonatomic, assign, readonly) NSInteger pv;
@property (nonatomic, assign, readonly) NSInteger uv;
@property (nonatomic, assign, readonly) NSInteger like_count;
@property (nonatomic, assign, readonly) NSInteger online_count;
@property (nonatomic, assign, readonly) NSInteger total_count;

@end


@interface AUIInteractionLiveVodInfoModel : AUIInteractionLiveModel

@property (nonatomic, assign, readonly) BOOL isValid;
@property (nonatomic, copy, readonly) NSString *play_url;

@end

typedef NS_ENUM(NSUInteger, AUIInteractionLiveStatus) {
    AUIInteractionLiveStatusNone = 0,
    AUIInteractionLiveStatusLiving,
    AUIInteractionLiveStatusFinished,
};

typedef NS_ENUM(NSUInteger, AUIInteractionLiveMode) {
    AUIInteractionLiveModeBase = 0,
    AUIInteractionLiveModeLinkMic,
};

@interface AUIInteractionLiveInfoModel : AUIInteractionLiveModel

@property (nonatomic, copy, readonly) NSString *live_id;
@property (nonatomic, assign, readonly) AUIInteractionLiveStatus status;
@property (nonatomic, assign, readonly) AUIInteractionLiveMode mode;
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
@property (nonatomic, strong, readonly) AUIInteractionLiveMetricsModel *metrics;
@property (nonatomic, strong, readonly) AUIInteractionLivePullModel *pull_url_info;
@property (nonatomic, strong, readonly) AUIInteractionLivePushModel *push_url_info;
@property (nonatomic, strong, readonly) AUIInteractionLiveLinkMicModel *link_info;
@property (nonatomic, strong, readonly) AUIInteractionLiveVodInfoModel *vod_info;

- (void)updateStatus:(AUIInteractionLiveStatus)status;

@end

NS_ASSUME_NONNULL_END
