//
//  AUILiveRoomManager.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/7.
//

#import <Foundation/Foundation.h>
#import "AUIInteractionLiveModel.h"
#import "AUIInteractionLiveMessage.h"
#import "AUIInteractionLiveSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomManager : NSObject<AVCIInteractionServiceDelegate>

@property (strong, nonatomic, readonly) AUIInteractionLiveInfoModel *liveInfoModel;
@property (strong, nonatomic, readonly) NSArray<AUIInteractionLiveLinkMicJoinInfoModel *> *joinList;

- (instancetype)initWithModel:(AUIInteractionLiveInfoModel *)model
                 withJoinList:(nullable NSArray<AUIInteractionLiveLinkMicJoinInfoModel *> *)joinList
        withInteractionEngine:(AVCIInteractionEngine *)interactionEngine;

@property (assign, nonatomic, readonly) BOOL isAnchor;
@property (assign, nonatomic, readonly) BOOL isJoined;

@property (assign, nonatomic, readonly) NSInteger pv;
- (void)enterRoom:(nullable void(^)(BOOL))completed;
- (void)leaveRoom:(nullable void(^)(BOOL))completed;

- (void)startLive:(nullable void(^)(BOOL))completed;
- (void)finishLive:(nullable void(^)(BOOL))completed;


@property (assign, nonatomic, readonly) BOOL isMuteAll;
- (void)queryMuteAll:(nullable void (^)(BOOL))completed;
- (void)muteAll:(nullable void(^)(BOOL))completed;
- (void)cancelMuteAll:(nullable void(^)(BOOL))completed;


@property (assign, nonatomic, readonly) BOOL isMuteByAuchor;
- (void)queryMuteByAnchor:(nullable void (^)(BOOL))completed;

@property (copy, nonatomic, readonly) NSString *notice;
- (void)updateNotice:(NSString *)notice completed:(nullable void(^)(BOOL))completed;

@property (assign, nonatomic, readonly) NSInteger allLikeCount;
- (void)sendLike;

- (void)sendCameraOpened:(BOOL)opened completed:(nullable void(^)(BOOL))completed;
- (void)sendMicOpened:(BOOL)opened completed:(nullable void(^)(BOOL))completed;
- (void)sendOpenCamera:(NSString *)userId needOpen:(BOOL)needOpen completed:(nullable void(^)(BOOL))completed;
- (void)sendOpenMic:(NSString *)userId needOpen:(BOOL)needOpen completed:(nullable void(^)(BOOL))completed;

- (void)sendComment:(NSString *)comment completed:(nullable void(^)(BOOL))completed;

- (void)sendMessage:(nullable NSDictionary *)content type:(AUIInteractionLiveMessageType)type uids:(nullable NSArray<NSString *> *)uids skipMuteCheck:(BOOL)skipMuteCheck skipAudit:(BOOL)skipAudit completed:(nullable void(^)(BOOL))completed;

// 申请/响应连麦
- (void)sendApplyLinkMic:(NSString *)uid completed:(nullable void(^)(BOOL))completed;
- (void)sendCancelApplyLinkMic:(NSString *)uid completed:(nullable void(^)(BOOL))completed;
- (void)sendResponseLinkMic:(NSString *)uid agree:(BOOL)agree pullUrl:(NSString *)pullUrl completed:(nullable void(^)(BOOL))completed;

// 广播自己要干什么：上麦/下麦/踢人下麦
- (void)sendJoinLinkMic:(NSString *)pullUrl completed:(nullable void(^)(BOOL))completed;
- (void)sendLeaveLinkMic:(BOOL)byKickout completed:(nullable void(^)(BOOL))completed;
- (void)sendKickoutLinkMic:(NSString *)uid completed:(nullable void(^)(BOOL))completed;

// 查询/更新连麦列表
- (void)queryLinkMicJoinList:(nullable void(^)(NSArray<AUIInteractionLiveLinkMicJoinInfoModel *> * _Nullable))completed;
- (void)updateLinkMicJoinList:(nullable NSArray<AUIInteractionLiveLinkMicJoinInfoModel *> *)joinList completed:(nullable void(^)(BOOL))completed;

@property (nonatomic, copy) void (^onReceivedCustomMessage)(AUIInteractionLiveMessage *message);
@property (nonatomic, copy) void (^onReceivedComment)(AUIInteractionLiveUser *sender, NSString *content);
@property (nonatomic, copy) void (^onReceivedStartLive)(AUIInteractionLiveUser *sender);
@property (nonatomic, copy) void (^onReceivedStopLive)(AUIInteractionLiveUser *sender);
@property (nonatomic, copy) void (^onReceivedLike)(AUIInteractionLiveUser *sender, NSInteger likeCount);
@property (nonatomic, copy) void (^onReceivedPV)(AUIInteractionLiveUser *sender, NSInteger pv);
@property (nonatomic, copy) void (^onReceivedJoinGroup)(AUIInteractionLiveUser *sender, NSDictionary *stat);
@property (nonatomic, copy) void (^onReceivedLeaveGroup)(AUIInteractionLiveUser *sender, NSDictionary *stat);
@property (nonatomic, copy) void (^onReceivedMuteAll)(AUIInteractionLiveUser *sender, BOOL isMuteAll);
@property (nonatomic, copy) void (^onReceivedNoticeUpdate)(AUIInteractionLiveUser *sender, NSString *notice);

@property (nonatomic, copy) void (^onReceivedCameraOpened)(AUIInteractionLiveUser *sender, BOOL opened);
@property (nonatomic, copy) void (^onReceivedMicOpened)(AUIInteractionLiveUser *sender, BOOL opened);
@property (nonatomic, copy) void (^onReceivedOpenCamera)(AUIInteractionLiveUser *sender,  BOOL needOpen);
@property (nonatomic, copy) void (^onReceivedOpenMic)(AUIInteractionLiveUser *sender, BOOL needOpen);

@property (nonatomic, copy) void (^onReceivedApplyLinkMic)(AUIInteractionLiveUser *sender);
@property (nonatomic, copy) void (^onReceivedCancelApplyLinkMic)(AUIInteractionLiveUser *sender);
@property (nonatomic, copy) void (^onReceivedResponseApplyLinkMic)(AUIInteractionLiveUser *sender, BOOL agree, NSString *pullUrl);
@property (nonatomic, copy) void (^onReceivedJoinLinkMic)(AUIInteractionLiveUser *sender, AUIInteractionLiveLinkMicJoinInfoModel *joinInfo);
@property (nonatomic, copy) void (^onReceivedLeaveLinkMic)(AUIInteractionLiveUser *sender, NSString *userId);

@end

NS_ASSUME_NONNULL_END
