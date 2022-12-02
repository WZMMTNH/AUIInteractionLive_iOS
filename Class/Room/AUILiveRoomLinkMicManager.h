//
//  AUILiveRoomLinkMicManager.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/27.
//

#import <Foundation/Foundation.h>
#import "AUILiveRoomBaseLiveManager.h"
#import "AUILiveRoomRtcPull.h"

#define MAX_LINK_MIC_COUNT 6

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomLinkMicManagerAnchor : AUILiveRoomBaseLiveManagerAnchor

// 当前申请列表
@property (copy, nonatomic, readonly) NSArray<AUIInteractionLiveUser *> *currentApplyList;
// 当前正在连麦列表
@property (copy, nonatomic, readonly) NSArray<AUIInteractionLiveUser *> *currentJoiningList;
// 当前连麦列表
@property (copy, nonatomic, readonly) NSArray<AUILiveRoomRtcPull *> *currentJoinList;

@property (copy, nonatomic) void(^applyListChangedBlock)(AUILiveRoomLinkMicManagerAnchor *sender);

- (void)reportLinkMicJoinList:(nullable void (^)(BOOL))completed;

// 是否可以连麦
- (BOOL)checkCanLinkMic;

// 收到观众连麦申请
- (void)receiveApplyLinkMic:(AUIInteractionLiveUser *)sender completed:(nullable void(^)(BOOL))completed;
// 收到观众取消连麦申请
- (void)receiveCancelApplyLinkMic:(AUIInteractionLiveUser *)sender completed:(nullable void(^)(BOOL))completed;
// 收到观众上麦
- (void)receivedJoinLinkMic:(AUIInteractionLiveLinkMicJoinInfoModel *)joinInfo completed:(nullable void(^)(BOOL))completed;
// 收到观众下麦
- (void)receivedLeaveLinkMic:(NSString *)userId completed:(nullable void(^)(BOOL))completed;
// 响应一个观众的连麦申请
- (void)responseApplyLinkMic:(AUIInteractionLiveUser *)user agree:(BOOL)agree force:(BOOL)force completed:(nullable void(^)(BOOL))completed;
// 踢人下麦
- (void)kickoutLinkMic:(NSString *)uid completed:(nullable void(^)(BOOL))completed;

// 收到开启/关闭麦克风
- (void)receivedMicOpened:(AUIInteractionLiveUser *)sender opened:(BOOL)opened completed:(nullable void(^)(BOOL))completed;
// 收到开启/关闭摄像头
- (void)receivedCameraOpened:(AUIInteractionLiveUser *)sender opened:(BOOL)opened completed:(nullable void(^)(BOOL))completed;
// 打开/关闭麦克风
- (void)openMic:(NSString *)uid needOpen:(BOOL)needOpen completed:(nullable void(^)(BOOL))completed;
// 打开/关闭摄像头
- (void)openCamera:(NSString *)uid needOpen:(BOOL)needOpen completed:(nullable void(^)(BOOL))completed;

@end


@interface AUILiveRoomLinkMicManagerAudience : AUILiveRoomBaseLiveManagerAudience

@property (copy, nonatomic, readonly) NSArray<AUILiveRoomRtcPull *> *currentJoinList;
@property (assign, nonatomic, readonly) BOOL isJoinedLinkMic;
@property (assign, nonatomic, readonly) BOOL isApplyingLinkMic;
@property (strong, nonatomic, readonly) AUILiveRoomPusher *livePusher;

@property (copy, nonatomic) void(^onNotifyApplyNotResponse)(AUILiveRoomLinkMicManagerAudience *sender);


// 收到同意上麦
- (void)receivedAgreeToLinkMic:(NSString *)userId willGiveUp:(BOOL)giveUp completed:(nullable void (^)(BOOL, BOOL, NSString *))completed;
// 收到不同意上麦
- (void)receivedDisagreeToLinkMic:(NSString *)userId completed:(nullable void (^)(BOOL))completed;
// 收到其他观众下麦/自己被踢下麦
- (void)receivedLeaveLinkMic:(NSString *)userId completed:(nullable void(^)(BOOL))completed;
// 收到其他观众上麦
- (void)receivedJoinLinkMic:(AUIInteractionLiveLinkMicJoinInfoModel *)joinInfo completed:(nullable void(^)(BOOL))completed;
// 申请
- (void)applyLinkMic:(nullable void(^)(BOOL))completed;
// 取消申请
- (void)cancelApplyLinkMic:(nullable void (^)(BOOL))completed;
// 下麦
- (void)leaveLinkMic:(nullable void(^)(BOOL))completed;

// 收到开启/关闭麦克风
- (void)receivedMicOpened:(AUIInteractionLiveUser *)sender opened:(BOOL)opened completed:(nullable void(^)(BOOL))completed;
// 收到开启/关闭摄像头
- (void)receivedCameraOpened:(AUIInteractionLiveUser *)sender opened:(BOOL)opened completed:(nullable void(^)(BOOL))completed;
// 打开/关闭麦克风
- (void)receivedNeedOpenMic:(AUIInteractionLiveUser *)sender needOpen:(BOOL)needOpen completed:(nullable void(^)(BOOL))completed;
// 打开/关闭摄像头
- (void)receivedNeedOpenCamera:(AUIInteractionLiveUser *)sender needOpen:(BOOL)needOpen completed:(nullable void(^)(BOOL))completed;

@end

NS_ASSUME_NONNULL_END
