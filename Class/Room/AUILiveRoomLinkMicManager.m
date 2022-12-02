//
//  AUILiveRoomLinkMicManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/27.
//

#import "AUILiveRoomLinkMicManager.h"
#import "AUILiveRoomBaseLiveManager+Private.h"
#import "AUIInteractionAccountManager.h"
#import "AUIInteractionLiveService.h"


@interface AUILiveRoomLinkMicManagerAnchor ()

@property (strong, nonatomic) NSMutableArray<AUILiveRoomRtcPull *> *joinList; // 当前上麦列表
@property (strong, nonatomic) NSMutableArray<AUIInteractionLiveUser *> *joiningList; // 正在上麦列表
@property (strong, nonatomic) NSMutableArray<AUIInteractionLiveUser *> *applyList;

@end

@implementation AUILiveRoomLinkMicManagerAnchor

- (NSArray<AUIInteractionLiveUser *> *)currentApplyList {
    return [self.applyList copy];
}

- (NSArray<AUILiveRoomRtcPull *> *)currentJoinList {
    return [self.joinList copy];
}

- (NSArray<AUIInteractionLiveUser *> *)currentJoiningList {
    return [self.joiningList copy];
}

- (void)setupLivePusher {
    [super setupLivePusher];
    
    self.applyList = [NSMutableArray array];
    self.joinList = [NSMutableArray array];
    self.joiningList = [NSMutableArray array];
    [self.roomManager.joinList enumerateObjectsUsingBlock:^(AUIInteractionLiveLinkMicJoinInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:self.roomManager.liveInfoModel.anchor_id]) {
            self.livePusher.isMute = !obj.micOpened;
            self.livePusher.isPause = !obj.cameraOpened;
            return;
        }
        AUILiveRoomRtcPull *pull = [[AUILiveRoomRtcPull alloc] init];
        pull.joinInfo = obj;
        [self.joinList addObject:pull];
    }];
}

- (void)prepareLivePusher {
    [super prepareLivePusher];
    
    self.livePusher.displayView.isAudioOff = self.livePusher.isMute;
    [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull pull, NSUInteger idx, BOOL * _Nonnull stop) {
        [pull prepare];
        pull.displayView.isAnchor = [pull.joinInfo.userId isEqualToString:self.roomManager.liveInfoModel.anchor_id];
        pull.displayView.nickName = [pull.joinInfo.userId isEqualToString:AUIInteractionAccountManager.me.userId] ? @"我" : pull.joinInfo.userNick;
        pull.displayView.isAudioOff = !pull.joinInfo.micOpened;
        [self.displayLayoutView addDisplayView:pull.displayView];
    }];
    [self.displayLayoutView layoutAll];
}

- (void)startLivePusher {
    [super startLivePusher];
    
    [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj start];
    }];
    [self mixStream];
}

- (void)destoryLivePusher {
    [super destoryLivePusher];
    
    [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj destory];
        [self.displayLayoutView removeDisplayView:obj.displayView];
    }];
    [self.displayLayoutView layoutAll];
}

- (void)reportLinkMicJoinList:(nullable void (^)(BOOL))completed {
    NSMutableArray *array = [NSMutableArray array];
    AUIInteractionLiveLinkMicJoinInfoModel *anchorJoinInfo = [[AUIInteractionLiveLinkMicJoinInfoModel alloc] init:AUIInteractionAccountManager.me.userId userNick:AUIInteractionAccountManager.me.nickName userAvatar:AUIInteractionAccountManager.me.avatar rtcPullUrl:self.roomManager.liveInfoModel.link_info.rtc_pull_url];
    anchorJoinInfo.cameraOpened = !self.livePusher.isPause;
    anchorJoinInfo.micOpened = !self.livePusher.isMute;
    [array addObject:anchorJoinInfo];
    [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:obj.joinInfo];
    }];
    
    [self.roomManager updateLinkMicJoinList:array completed:completed];
}

- (BOOL)checkCanLinkMic {
    return self.joinList.count < MAX_LINK_MIC_COUNT - 1;
}

- (void)receiveApplyLinkMic:(AUIInteractionLiveUser *)sender completed:(nullable void(^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block BOOL find = NO;
    [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.joinInfo.userId isEqualToString:sender.userId]) {
            find = YES;
            *stop = YES;
        }
    }];
    if (!find) {
        [self.applyList enumerateObjectsUsingBlock:^(AUIInteractionLiveUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.userId isEqualToString:sender.userId]) {
                find = YES;
            }
        }];
        if (!find) {
            [self.applyList addObject:sender];
            if (self.applyListChangedBlock) {
                self.applyListChangedBlock(self);
            }
            __block AUIInteractionLiveUser *joiningUser = nil;
            [self.joiningList enumerateObjectsUsingBlock:^(AUIInteractionLiveUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.userId isEqualToString:sender.userId]) {
                    joiningUser = obj;
                    *stop = YES;
                }
            }];
            if (joiningUser) {
                [self.joiningList removeObject:joiningUser];
            }
            if (completed) {
                completed(YES);
            }
            return;
        }
    }
    if (completed) {
        completed(NO);
    }
}

- (void)receiveCancelApplyLinkMic:(AUIInteractionLiveUser *)sender completed:(nullable void(^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    // 从申请列表中移除
    __block AUIInteractionLiveUser *find = nil;
    [self.applyList enumerateObjectsUsingBlock:^(AUIInteractionLiveUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:sender.userId]) {
            find = obj;
            *stop = YES;
        }
    }];

    if (find) {
        [self.applyList removeObject:find];
        if (self.applyListChangedBlock) {
            self.applyListChangedBlock(self);
        }
        if (completed) {
            completed(YES);
        }
        return;
    }
    
    // 从等待上麦列表中移除
    [self.joiningList enumerateObjectsUsingBlock:^(AUIInteractionLiveUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:sender.userId]) {
            find = obj;
            *stop = YES;
        }
    }];
    if (find) {
        [self.joiningList removeObject:find];
        if (completed) {
            completed(YES);
        }
    }
    
    if (completed) {
        completed(NO);
    }
}

- (void)responseApplyLinkMic:(AUIInteractionLiveUser *)user agree:(BOOL)agree force:(BOOL)force completed:(void (^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block AUIInteractionLiveUser *find = nil;
    [self.applyList enumerateObjectsUsingBlock:^(AUIInteractionLiveUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:user.userId]) {
            find = obj;
            *stop = YES;
        }
    }];
    if (!find && force) {
        find = user;
    }
    if (find || force) {
        __weak typeof(self) weakSelf = self;
        [self.roomManager sendResponseLinkMic:find.userId agree:agree pullUrl:self.roomManager.liveInfoModel.link_info.rtc_pull_url completed:^(BOOL success) {
            if (success) {
                [weakSelf.applyList removeObject:find];
                if (weakSelf.applyListChangedBlock) {
                    weakSelf.applyListChangedBlock(weakSelf);
                }
                if (agree) {
                    __block AUIInteractionLiveUser *joiningUser = nil;
                    [weakSelf.joiningList enumerateObjectsUsingBlock:^(AUIInteractionLiveUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.userId isEqualToString:find.userId]) {
                            joiningUser = obj;
                            *stop = YES;
                        }
                    }];
                    if (!joiningUser) {
                        [weakSelf.joiningList addObject:find];
                    }
                }
            }
            if (completed) {
                completed(success);
            }
        }];
    }
    else {
        if (completed) {
            completed(NO);
        }
    }
}

- (void)kickoutLinkMic:(NSString *)uid completed:(void (^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block AUILiveRoomRtcPull *find = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.joinInfo.userId isEqualToString:uid]) {
            find = obj;
            *stop = YES;
        }
    }];
    if (find) {
        __weak typeof(self) weakSelf = self;
        [self.roomManager sendKickoutLinkMic:uid completed:^(BOOL success) {
            if (success) {
                [weakSelf onLeaveLinkMic:find];
            }
            if (completed) {
                completed(success);
            }
        }];
    }
    else {
        if (completed) {
            completed(NO);
        }
    }
}

// 收到观众上麦
- (void)receivedJoinLinkMic:(AUIInteractionLiveLinkMicJoinInfoModel *)joinInfo completed:(nullable void(^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block AUILiveRoomRtcPull *pull = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.joinInfo.userId isEqualToString:joinInfo.userId]) {
            pull = obj;
            *stop = YES;
        }
    }];
    if (!pull) {
        pull = [[AUILiveRoomRtcPull alloc] init];
        pull.joinInfo = joinInfo;
        [self onJoinLinkMic:pull];
        if (completed) {
            completed(YES);
        }
        return;
    }
    if (completed) {
        completed(NO);
    }
}

// 收到观众下麦
- (void)receivedLeaveLinkMic:(NSString *)userId completed:(nullable void(^)(BOOL))completed {
    __block AUILiveRoomRtcPull *pull = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.joinInfo.userId isEqualToString:userId]) {
            pull = obj;
            *stop = YES;
        }
    }];
    if (pull) {
        [self onLeaveLinkMic:pull];
        if (completed) {
            completed(YES);
        }
        return;
    }
    if (completed) {
        completed(NO);
    }
}

- (void)onJoinLinkMic:(AUILiveRoomRtcPull *)pull {
    [pull prepare];
    pull.displayView.isAnchor = [pull.joinInfo.userId isEqualToString:self.roomManager.liveInfoModel.anchor_id];
    pull.displayView.nickName = [pull.joinInfo.userId isEqualToString:AUIInteractionAccountManager.me.userId] ? @"我" : pull.joinInfo.userNick;
    pull.displayView.isAudioOff = !pull.joinInfo.micOpened;
    [self.displayLayoutView addDisplayView:pull.displayView];
    [self.displayLayoutView layoutAll];
    [pull start];
    
    __block AUIInteractionLiveUser *joiningUser = nil;
    [self.joiningList enumerateObjectsUsingBlock:^(AUIInteractionLiveUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:pull.joinInfo.userId]) {
            joiningUser = obj;
            *stop = YES;
        }
    }];
    if (joiningUser) {
        [self.joiningList removeObject:joiningUser];
    }
    [self.joinList addObject:pull];
    [self mixStream];
    
    [self reportLinkMicJoinList:nil];
}

- (void)onLeaveLinkMic:(AUILiveRoomRtcPull *)pull {
    [self.displayLayoutView removeDisplayView:pull.displayView];
    [self.displayLayoutView layoutAll];
    [pull destory];
    [self.joinList removeObject:pull];
    [self mixStream];
    
    [self reportLinkMicJoinList:nil];
}

- (void)mixStream {
    AlivcLiveTranscodingConfig *liveTranscodingConfig = nil;
    if (self.joinList.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        CGRect rect = [self.displayLayoutView renderRect:self.livePusher.displayView];
        AlivcLiveMixStream *anchorStream = [[AlivcLiveMixStream alloc] init];
        anchorStream.userId = self.livePusher.liveInfoModel.anchor_id;
        anchorStream.x = rect.origin.x;
        anchorStream.y = rect.origin.y;
        anchorStream.width = rect.size.width;
        anchorStream.height = rect.size.height;
        anchorStream.zOrder = (int)[self.displayLayoutView.displayViewList indexOfObject:self.livePusher.displayView] + 1;
        [array addObject:anchorStream];
        
        [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect rect = [self.displayLayoutView renderRect:obj.displayView];
            AlivcLiveMixStream *audienceStream = [[AlivcLiveMixStream alloc] init];
            audienceStream.userId = obj.joinInfo.userId;
            audienceStream.x = rect.origin.x;
            audienceStream.y = rect.origin.y;
            audienceStream.width = rect.size.width;
            audienceStream.height = rect.size.height;
            audienceStream.zOrder = (int)[self.displayLayoutView.displayViewList indexOfObject:obj.displayView] + 1;
            [array addObject:audienceStream];
        }];
        liveTranscodingConfig = [[AlivcLiveTranscodingConfig alloc] init];
        liveTranscodingConfig.mixStreams = array;
    }
    
    [self.livePusher setLiveMixTranscodingConfig:liveTranscodingConfig];
}

- (void)receivedMicOpened:(AUIInteractionLiveUser *)sender opened:(BOOL)opened completed:(void (^)(BOOL))completed {
    if (!self.isLiving || [sender.userId isEqualToString:AUIInteractionAccountManager.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block AUILiveRoomRtcPull *pull = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.joinInfo.userId isEqualToString:sender.userId]) {
            pull = obj;
            *stop = YES;
        }
    }];
    if (pull) {
        pull.joinInfo.micOpened = opened;
        pull.displayView.isAudioOff = !pull.joinInfo.micOpened;
        [self reportLinkMicJoinList:nil];
    }
    if (completed) {
        completed(pull != nil);
    }
}

- (void)receivedCameraOpened:(AUIInteractionLiveUser *)sender opened:(BOOL)opened completed:(void (^)(BOOL))completed {
    if (!self.isLiving || [sender.userId isEqualToString:AUIInteractionAccountManager.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block AUILiveRoomRtcPull *pull = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.joinInfo.userId isEqualToString:sender.userId]) {
            pull = obj;
            *stop = YES;
        }
    }];
    if (pull) {
        pull.joinInfo.cameraOpened = opened;
        [self reportLinkMicJoinList:nil];
    }
    if (completed) {
        completed(pull != nil);
    }
}

- (void)openMic:(NSString *)uid needOpen:(BOOL)needOpen completed:(void (^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    [self.roomManager sendOpenMic:uid needOpen:needOpen completed:completed];
}

- (void)openCamera:(NSString *)uid needOpen:(BOOL)needOpen completed:(void (^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    [self.roomManager sendOpenCamera:uid needOpen:needOpen completed:completed];
}

- (BOOL)openLivePusherMic:(BOOL)open {
    BOOL ret = [super openLivePusherMic:open];
    self.livePusher.displayView.isAudioOff = !ret;
    [self.roomManager sendMicOpened:ret completed:nil];
    [self reportLinkMicJoinList:nil];
    return ret;
}

- (BOOL)openLivePusherCamera:(BOOL)open {
    BOOL ret = [super openLivePusherCamera:open];
    [self.roomManager sendCameraOpened:ret completed:nil];
    [self reportLinkMicJoinList:nil];
    return ret;
}

@end


//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



@interface AUILiveRoomLinkMicManagerAudience ()

@property (strong, nonatomic) AUILiveRoomPusher *livePusher;
@property (strong, nonatomic) NSMutableArray<AUILiveRoomRtcPull *> *joinList; // 当前上麦列表
@property (assign, nonatomic) NSUInteger displayIndex;
@property (assign, nonatomic) BOOL micOpened;
@property (assign, nonatomic) BOOL cameraOpened;

@property (assign, nonatomic) BOOL isApplyingLinkMic;
@property (assign, nonatomic) BOOL needToNotifyApplyNotResponse;

@end


@implementation AUILiveRoomLinkMicManagerAudience

- (NSArray<AUILiveRoomRtcPull *> *)currentJoinList {
    return [self.joinList copy];
}

- (void)setupPullPlayer {
    [self setupPullPlayerWithRemoteJoinList:self.roomManager.joinList];
}

- (void)setupPullPlayerWithRemoteJoinList:(NSArray<AUIInteractionLiveLinkMicJoinInfoModel *> *)remoteJoinList {
    self.joinList = [NSMutableArray array];
    self.displayIndex = 0;
    self.micOpened = YES;
    self.cameraOpened = YES;
    __block BOOL find = NO;
    [remoteJoinList enumerateObjectsUsingBlock:^(AUIInteractionLiveLinkMicJoinInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:AUIInteractionAccountManager.me.userId]) {
            find = YES;
            self.displayIndex = idx;
            self.micOpened = obj.micOpened;
            self.cameraOpened = obj.cameraOpened;
            return;
        }
        AUILiveRoomRtcPull *pull = [[AUILiveRoomRtcPull alloc] init];
        pull.joinInfo = obj;
        [self.joinList addObject:pull];
    }];
    
    if (find) {
        [self setupLivePusher];
        self.isLiving = NO;
    }
    else {
        [super setupPullPlayer];  // cdn player
        [self.joinList removeAllObjects];
    }
}

- (void)setupLivePusher {
    self.livePusher = [[AUILiveRoomPusher alloc] init];
    self.livePusher.liveInfoModel = self.roomManager.liveInfoModel;
    self.livePusher.beautyController = self.roomVC ? [[AUILiveRoomBeautyController alloc] initWithPresentView:self.roomVC.view contextMode:YES] : nil;
    self.livePusher.isMute = !self.micOpened;
    self.livePusher.isPause = !self.cameraOpened;
}

- (BOOL)isJoinedLinkMic {
    return self.livePusher != nil;
}

- (void)preparePullPlayer {
    if ([self isJoinedLinkMic]) {
        
        [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull pull, NSUInteger idx, BOOL * _Nonnull stop) {
            [pull prepare];
            pull.displayView.isAnchor = [pull.joinInfo.userId isEqualToString:self.roomManager.liveInfoModel.anchor_id];
            pull.displayView.nickName = [pull.joinInfo.userId isEqualToString:AUIInteractionAccountManager.me.userId] ? @"我" : pull.joinInfo.userNick;
            pull.displayView.isAudioOff = !pull.joinInfo.micOpened;
            [self.displayLayoutView addDisplayView:pull.displayView];
        }];
        
        self.livePusher.displayView.showLoadingIndicator = NO;
        self.livePusher.displayView.isAudioOff = self.livePusher.isMute;
        [self.displayLayoutView insertDisplayView:self.livePusher.displayView atIndex:self.displayIndex];
        [self.livePusher prepare];
        
        [self.displayLayoutView layoutAll];
    }
    else {
        [super preparePullPlayer];
    }
}

- (void)startPullPlayer {
    if ([self isJoinedLinkMic]) {
        [self.livePusher start];
        [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj start];
        }];
        self.isLiving = YES;
    }
    else {
        [super startPullPlayer];
    }
}

- (void)destoryPullPlayer {
    [self destoryPullPlayerByKick:NO];
}


- (void)destoryPullPlayerByKick:(BOOL)byKickout{
    if ([self isJoinedLinkMic]) {
        [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.displayLayoutView removeDisplayView:obj.displayView];
            [obj destory];
        }];
        [self.displayLayoutView removeDisplayView:self.livePusher.displayView];
        [self.livePusher destory];
        self.livePusher = nil;
        [self.displayLayoutView layoutAll];
        self.isLiving = NO;
        [self.roomManager sendLeaveLinkMic:byKickout completed:nil];
    }
    else {
        [super destoryPullPlayer];
    }
}

- (void)applyLinkMic:(void (^)(BOOL))completed {
    if ([self isJoinedLinkMic] || !self.isLiving || self.isApplyingLinkMic) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.roomManager sendApplyLinkMic:self.roomManager.liveInfoModel.anchor_id completed:^(BOOL success) {
        if (success) {
            weakSelf.isApplyingLinkMic = YES;
            [weakSelf startNotifyApplyNotResponse];
        }
        if (completed) {
            completed(success);
        }
    }];
}

- (void)cancelApplyLinkMic:(void (^)(BOOL))completed {
    if ([self isJoinedLinkMic] || !self.isLiving || !self.isApplyingLinkMic) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    self.isApplyingLinkMic = NO;
    [self cancelNotifyApplyNotResponse];
    
    [self.roomManager sendCancelApplyLinkMic:self.roomManager.liveInfoModel.anchor_id completed:nil];
    if (completed) {
        completed(YES);
    }
}

// 收到同意上麦
- (void)receivedAgreeToLinkMic:(NSString *)userId willGiveUp:(BOOL)giveUp completed:(nullable void (^)(BOOL success, BOOL giveUp, NSString *message))completed {
    if (!self.isLiving || ![userId isEqualToString:self.roomManager.liveInfoModel.anchor_id]) {
        if (completed) {
            completed(NO, NO, @"当前状态不对");
        }
        return;
    }
    
    self.isApplyingLinkMic = NO;
    [self cancelNotifyApplyNotResponse];
    
    if (giveUp) {
        [self.roomManager sendCancelApplyLinkMic:self.roomManager.liveInfoModel.anchor_id completed:nil];
        if (completed) {
            completed(YES, YES, nil);
        }
        return;
    }
    
    [self joinLinkMic:^(BOOL success, NSString *message) {
        if (completed) {
            completed(success, NO, message);
        }
    }];
}

// 收到不同意上麦
- (void)receivedDisagreeToLinkMic:(NSString *)userId completed:(nullable void (^)(BOOL))completed {
    if (!self.isLiving || ![userId isEqualToString:self.roomManager.liveInfoModel.anchor_id]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    self.isApplyingLinkMic = NO;
    [self cancelNotifyApplyNotResponse];
    
    if (completed) {
        completed(YES);
    }
}

// 收到其他观众上麦
- (void)receivedJoinLinkMic:(AUIInteractionLiveLinkMicJoinInfoModel *)joinInfo completed:(nullable void (^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    if ([self isJoinedLinkMic]) {
        if ([joinInfo.userId isEqual:AUIInteractionAccountManager.me.userId]) {
            if (completed) {
                completed(YES);
            }
            return;
        }
        __block AUILiveRoomRtcPull *pull = nil;
        [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.joinInfo.userId isEqualToString:joinInfo.userId]) {
                pull = obj;
                *stop = YES;
            }
        }];
        if (!pull) {
            pull = [[AUILiveRoomRtcPull alloc] init];
            pull.joinInfo = joinInfo;
            [self.joinList addObject:pull];
            
            [pull prepare];
            pull.displayView.isAnchor = [pull.joinInfo.userId isEqualToString:self.roomManager.liveInfoModel.anchor_id];
            pull.displayView.nickName = [pull.joinInfo.userId isEqualToString:AUIInteractionAccountManager.me.userId] ? @"我" : pull.joinInfo.userNick;
            pull.displayView.isAudioOff = !pull.joinInfo.micOpened;
            [self.displayLayoutView addDisplayView:pull.displayView];
            [self.displayLayoutView layoutAll];
            [pull start];
        }
        
        if (completed) {
            completed(YES);
        }
    }
    else {
        if (completed) {
            completed(NO);
        }
    }
}

// 收到其他观众下麦/自己被踢下麦
- (void)receivedLeaveLinkMic:(NSString *)userId completed:(nullable void (^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    if ([self isJoinedLinkMic]) {
        if ([userId isEqualToString:AUIInteractionAccountManager.me.userId]) {
            [self leaveLinkMic:YES completed:completed];
            return;
        }
        
        __block AUILiveRoomRtcPull *pull = nil;
        [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.joinInfo.userId isEqualToString:userId]) {
                pull = obj;
                *stop = YES;
            }
        }];
        if (pull) {
            [self.displayLayoutView removeDisplayView:pull.displayView];
            [self.displayLayoutView layoutAll];
                    
            [pull destory];
            [self.joinList removeObject:pull];
        }
        if (completed) {
            completed(YES);
        }
    }
    else {
        if (completed) {
            completed(NO);
        }
    }
}

// 上麦
- (void)joinLinkMic:(void(^)(BOOL, NSString *))completed; {
    if (!self.isLiving || [self isJoinedLinkMic]) {
        if (completed) {
            completed(NO, @"当前状态不对");
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.roomManager queryLinkMicJoinList:^(NSArray<AUIInteractionLiveLinkMicJoinInfoModel *> * _Nullable remoteJoinList) {
        if (!remoteJoinList) {
            if (completed) {
                completed(NO, @"无法获取当前上麦列表，上麦失败");
            }
            return;
        }
        
        if (remoteJoinList.count >= MAX_LINK_MIC_COUNT) {
            if (completed) {
                completed(NO, @"当前连麦人数已经超过最大限制，连麦失败");
            }
            return;
        }
        
        AUIInteractionLiveLinkMicJoinInfoModel *my = [[AUIInteractionLiveLinkMicJoinInfoModel alloc] init:AUIInteractionAccountManager.me.userId userNick:AUIInteractionAccountManager.me.nickName userAvatar:AUIInteractionAccountManager.me.avatar rtcPullUrl:weakSelf.roomManager.liveInfoModel.link_info.rtc_pull_url];
        NSMutableArray<AUIInteractionLiveLinkMicJoinInfoModel *> *list = [NSMutableArray arrayWithArray:remoteJoinList];
        [list addObject:my];
        [weakSelf destoryPullPlayer];
        [weakSelf setupPullPlayerWithRemoteJoinList:list];
        [weakSelf preparePullPlayer];
        [weakSelf startPullPlayer];
        
        [weakSelf.roomManager sendJoinLinkMic:my.rtcPullUrl completed:nil];
        if (completed) {
            completed(YES, nil);
        }
    }];
}

// 下麦
- (void)leaveLinkMic:(void(^)(BOOL))completed; {
    [self leaveLinkMic:NO completed:completed];
}

- (void)leaveLinkMic:(BOOL)byKickout completed:(void(^)(BOOL))completed; {
    if (!self.isLiving || ![self isJoinedLinkMic]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    [self destoryPullPlayerByKick:byKickout];
    [self setupPullPlayerWithRemoteJoinList:nil];
    [self preparePullPlayer];
    [self startPullPlayer];
    if (completed) {
        completed(YES);
    }
}

- (void)receivedMicOpened:(AUIInteractionLiveUser *)sender opened:(BOOL)opened completed:(void (^)(BOOL))completed {
    if (!self.isLiving || !self.isJoinedLinkMic || [sender.userId isEqualToString:AUIInteractionAccountManager.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    __block AUILiveRoomRtcPull *pull = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.joinInfo.userId isEqualToString:sender.userId]) {
            pull = obj;
            *stop = YES;
        }
    }];
    if (pull) {
        pull.joinInfo.micOpened = opened;
        pull.displayView.isAudioOff = !pull.joinInfo.micOpened;
    }
    if (completed) {
        completed(pull != nil);
    }
}

- (void)receivedCameraOpened:(AUIInteractionLiveUser *)sender opened:(BOOL)opened completed:(void (^)(BOOL))completed {
    if (!self.isLiving || !self.isJoinedLinkMic || [sender.userId isEqualToString:AUIInteractionAccountManager.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block AUILiveRoomRtcPull *pull = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.joinInfo.userId isEqualToString:sender.userId]) {
            pull = obj;
            *stop = YES;
        }
    }];
    if (pull) {
        pull.joinInfo.cameraOpened = opened;
    }
    if (completed) {
        completed(pull != nil);
    }
}

- (void)receivedNeedOpenMic:(AUIInteractionLiveUser *)sender needOpen:(BOOL)needOpen completed:(void (^)(BOOL))completed {
    if (!self.isLiving || !self.isJoinedLinkMic || ![sender.userId isEqualToString:self.roomManager.liveInfoModel.anchor_id]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    [self.livePusher mute:!needOpen];
    [self.roomManager sendMicOpened:!self.livePusher.isMute completed:completed];
}

- (void)receivedNeedOpenCamera:(AUIInteractionLiveUser *)sender needOpen:(BOOL)needOpen completed:(void (^)(BOOL))completed {
    if (!self.isLiving || !self.isJoinedLinkMic || ![sender.userId isEqualToString:self.roomManager.liveInfoModel.anchor_id]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    [self.livePusher pause:!needOpen];
    [self.roomManager sendMicOpened:!self.livePusher.isPause completed:completed];
}

// 定时任务

- (void)startNotifyApplyNotResponse {
    [self cancelNotifyApplyNotResponse];
    [self performSelector:@selector(timeToNotifyApplyNotResponse) withObject:nil afterDelay:30];
    self.needToNotifyApplyNotResponse = YES;
}

- (void)cancelNotifyApplyNotResponse {
    self.needToNotifyApplyNotResponse = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeToNotifyApplyNotResponse) object:nil];
}

- (void)timeToNotifyApplyNotResponse {
    if (self.needToNotifyApplyNotResponse) {
        if (self.onNotifyApplyNotResponse) {
            self.onNotifyApplyNotResponse(self);
        }
    }
}

@end
