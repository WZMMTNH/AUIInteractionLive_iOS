//
//  AUILiveRoomLinkMicManager.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/27.
//

#import <Foundation/Foundation.h>
#import "AUILiveRoomBaseLiveManager.h"
#import "AUILiveRoomRtcPull.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomLinkMicManagerAnchor : AUILiveRoomBaseLiveManagerAnchor

// 当前申请列表
@property (copy, nonatomic, readonly) NSArray<AUIInteractionLiveUser *> *currentApplyList;
// 当前正在连麦列表
@property (copy, nonatomic, readonly) NSArray<AUIInteractionLiveUser *> *currentJoiningList;
// 当前连麦列表
@property (copy, nonatomic, readonly) NSArray<AUILiveRoomRtcPull *> *currentJoinList;

// 是否可以连麦
- (BOOL)checkCanLinkMic;

// 收到观众连麦申请
- (void)receiveApplyLinkMic:(AUIInteractionLiveUser *)sender completed:(nullable void(^)(BOOL))completed;
// 收到观众上麦
- (void)receivedJoinLinkMic:(AUIInteractionLiveLinkMicPullInfo *)linkMicUserInfo completed:(nullable void(^)(BOOL))completed;
// 收到观众下麦
- (void)receivedLeaveLinkMic:(NSString *)userId completed:(nullable void(^)(BOOL))completed;
// 响应一个观众的连麦申请
- (void)responseApplyLinkMic:(AUIInteractionLiveUser *)user agree:(BOOL)agree force:(BOOL)force completed:(nullable void(^)(BOOL))completed;
// 踢人下麦
- (void)kickoutLinkMic:(NSString *)uid completed:(nullable void(^)(BOOL))completed;

@end


@interface AUILiveRoomLinkMicManagerAudience : AUILiveRoomBaseLiveManagerAudience

@property (copy, nonatomic, readonly) NSArray<AUILiveRoomRtcPull *> *currentJoinList;
@property (assign, nonatomic, readonly) BOOL isJoinedLinkMic;
@property (strong, nonatomic, readonly) AUILiveRoomPusher *livePusher;

// 收到响应
- (void)receivedResponseLinkMic:(NSString *)userId agree:(BOOL)agree completed:(nullable void(^)(BOOL))completed;
// 收到其他观众下麦/自己被踢下麦
- (void)receivedLeaveLinkMic:(NSString *)userId completed:(nullable void(^)(BOOL))completed;
// 收到其他观众上麦
- (void)receivedJoinLinkMic:(AUIInteractionLiveLinkMicPullInfo *)linkMicUserInfo completed:(nullable void(^)(BOOL))completed;
// 申请
- (void)applyLinkMic:(nullable void(^)(BOOL))completed;
// 下麦
- (void)leaveLinkMic:(nullable void(^)(BOOL))completed;

@end

NS_ASSUME_NONNULL_END
