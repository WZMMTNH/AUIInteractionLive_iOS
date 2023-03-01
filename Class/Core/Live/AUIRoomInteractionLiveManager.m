//
//  AUIRoomInteractionLiveManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/27.
//

#import "AUIRoomInteractionLiveManager.h"
#import "AUIRoomBaseLiveManager+Private.h"
#import "AUIRoomAccount.h"
#import "AUIRoomAppServer.h"

@interface AUIRoomInteractionLiveManagerAnchor ()

@property (strong, nonatomic) NSMutableArray<AUIRoomLiveRtcPlayer *> *joinList; // 当前上麦列表
@property (strong, nonatomic) NSMutableArray<AUIRoomUser *> *joiningList; // 正在上麦列表
@property (strong, nonatomic) NSMutableArray<AUIRoomUser *> *applyList;

@end

@implementation AUIRoomInteractionLiveManagerAnchor

- (NSArray<AUIRoomUser *> *)currentApplyList {
    return [self.applyList copy];
}

- (NSArray<AUIRoomLiveRtcPlayer *> *)currentJoinList {
    return [self.joinList copy];
}

- (NSArray<AUIRoomUser *> *)currentJoiningList {
    return [self.joiningList copy];
}

- (void)setupLivePusher {
    [super setupLivePusher];
    
    self.applyList = [NSMutableArray array];
    self.joinList = [NSMutableArray array];
    self.joiningList = [NSMutableArray array];
    [self.liveService.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveLinkMicJoinInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:self.liveService.liveInfoModel.anchor_id]) {
            self.livePusher.isMute = !obj.micOpened;
            self.livePusher.isPause = !obj.cameraOpened;
            return;
        }
        AUIRoomLiveRtcPlayer *pull = [[AUIRoomLiveRtcPlayer alloc] init];
        pull.joinInfo = obj;
        [self.joinList addObject:pull];
    }];
}

- (void)prepareLivePusher {
    [super prepareLivePusher];
    
    self.livePusher.displayView.isAudioOff = self.livePusher.isMute;
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull pull, NSUInteger idx, BOOL * _Nonnull stop) {
        [pull prepare];
        pull.displayView.isAnchor = [pull.joinInfo.userId isEqualToString:self.liveService.liveInfoModel.anchor_id];
        pull.displayView.nickName = [pull.joinInfo.userId isEqualToString:AUIRoomAccount.me.userId] ? @"我" : pull.joinInfo.userNick;
        pull.displayView.isAudioOff = !pull.joinInfo.micOpened;
        [self.displayLayoutView addDisplayView:pull.displayView];
    }];
    [self.displayLayoutView layoutAll];
}

- (void)startLivePusher {
    [super startLivePusher];
    
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj start];
    }];
    [self mixStream];
}

- (void)destoryLivePusher {
    [super destoryLivePusher];
    
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj destory];
        [self.displayLayoutView removeDisplayView:obj.displayView];
    }];
    [self.displayLayoutView layoutAll];
}

- (void)reportLinkMicJoinList:(nullable void (^)(BOOL))completed {
    NSMutableArray *array = [NSMutableArray array];
    AUIRoomLiveLinkMicJoinInfoModel *anchorJoinInfo = [[AUIRoomLiveLinkMicJoinInfoModel alloc] init:AUIRoomAccount.me.userId userNick:AUIRoomAccount.me.nickName userAvatar:AUIRoomAccount.me.avatar rtcPullUrl:self.liveService.liveInfoModel.link_info.rtc_pull_url];
    anchorJoinInfo.cameraOpened = !self.livePusher.isPause;
    anchorJoinInfo.micOpened = !self.livePusher.isMute;
    [array addObject:anchorJoinInfo];
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:obj.joinInfo];
    }];
    
    [self.liveService updateLinkMicJoinList:array completed:completed];
}

- (BOOL)checkCanLinkMic {
    NSUInteger max = AUIRoomLiveService.maxLinkMicCount;
    return self.joinList.count < max - 1;
}

- (void)receiveApplyLinkMic:(AUIRoomUser *)sender completed:(nullable void(^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block BOOL find = NO;
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.joinInfo.userId isEqualToString:sender.userId]) {
            find = YES;
            *stop = YES;
        }
    }];
    if (!find) {
        [self.applyList enumerateObjectsUsingBlock:^(AUIRoomUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.userId isEqualToString:sender.userId]) {
                find = YES;
            }
        }];
        if (!find) {
            [self.applyList addObject:sender];
            if (self.applyListChangedBlock) {
                self.applyListChangedBlock(self);
            }
            __block AUIRoomUser *joiningUser = nil;
            [self.joiningList enumerateObjectsUsingBlock:^(AUIRoomUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)receiveCancelApplyLinkMic:(AUIRoomUser *)sender completed:(nullable void(^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    // 从申请列表中移除
    __block AUIRoomUser *find = nil;
    [self.applyList enumerateObjectsUsingBlock:^(AUIRoomUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    [self.joiningList enumerateObjectsUsingBlock:^(AUIRoomUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)responseApplyLinkMic:(AUIRoomUser *)user agree:(BOOL)agree force:(BOOL)force completed:(void (^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block AUIRoomUser *find = nil;
    [self.applyList enumerateObjectsUsingBlock:^(AUIRoomUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
        [self.liveService sendResponseLinkMic:find.userId agree:agree pullUrl:self.liveService.liveInfoModel.link_info.rtc_pull_url completed:^(BOOL success) {
            if (success) {
                [weakSelf.applyList removeObject:find];
                if (weakSelf.applyListChangedBlock) {
                    weakSelf.applyListChangedBlock(weakSelf);
                }
                if (agree) {
                    __block AUIRoomUser *joiningUser = nil;
                    [weakSelf.joiningList enumerateObjectsUsingBlock:^(AUIRoomUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    __block AUIRoomLiveRtcPlayer *find = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.joinInfo.userId isEqualToString:uid]) {
            find = obj;
            *stop = YES;
        }
    }];
    if (find) {
        __weak typeof(self) weakSelf = self;
        [self.liveService sendKickoutLinkMic:uid completed:^(BOOL success) {
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
- (void)receivedJoinLinkMic:(AUIRoomLiveLinkMicJoinInfoModel *)joinInfo completed:(nullable void(^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block AUIRoomLiveRtcPlayer *pull = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.joinInfo.userId isEqualToString:joinInfo.userId]) {
            pull = obj;
            *stop = YES;
        }
    }];
    if (!pull) {
        pull = [[AUIRoomLiveRtcPlayer alloc] init];
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
    __block AUIRoomLiveRtcPlayer *pull = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)onJoinLinkMic:(AUIRoomLiveRtcPlayer *)pull {
    [pull prepare];
    pull.displayView.isAnchor = [pull.joinInfo.userId isEqualToString:self.liveService.liveInfoModel.anchor_id];
    pull.displayView.nickName = [pull.joinInfo.userId isEqualToString:AUIRoomAccount.me.userId] ? @"我" : pull.joinInfo.userNick;
    pull.displayView.isAudioOff = !pull.joinInfo.micOpened;
    [self.displayLayoutView addDisplayView:pull.displayView];
    [self.displayLayoutView layoutAll];
    [pull start];
    
    __block AUIRoomUser *joiningUser = nil;
    [self.joiningList enumerateObjectsUsingBlock:^(AUIRoomUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)onLeaveLinkMic:(AUIRoomLiveRtcPlayer *)pull {
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
        
        [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)receivedMicOpened:(AUIRoomUser *)sender opened:(BOOL)opened completed:(void (^)(BOOL))completed {
    if (!self.isLiving || [sender.userId isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block AUIRoomLiveRtcPlayer *pull = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)receivedCameraOpened:(AUIRoomUser *)sender opened:(BOOL)opened completed:(void (^)(BOOL))completed {
    if (!self.isLiving || [sender.userId isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block AUIRoomLiveRtcPlayer *pull = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    [self.liveService sendOpenMic:uid needOpen:needOpen completed:completed];
}

- (void)openCamera:(NSString *)uid needOpen:(BOOL)needOpen completed:(void (^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    [self.liveService sendOpenCamera:uid needOpen:needOpen completed:completed];
}

- (BOOL)openLivePusherMic:(BOOL)open {
    BOOL ret = [super openLivePusherMic:open];
    self.livePusher.displayView.isAudioOff = !ret;
    [self.liveService sendMicOpened:ret completed:nil];
    [self reportLinkMicJoinList:nil];
    return ret;
}

- (BOOL)openLivePusherCamera:(BOOL)open {
    BOOL ret = [super openLivePusherCamera:open];
    [self.liveService sendCameraOpened:ret completed:nil];
    [self reportLinkMicJoinList:nil];
    return ret;
}

@end


//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



@interface AUIRoomInteractionLiveManagerAudience ()

@property (strong, nonatomic) AUIRoomLivePusher *livePusher;
@property (strong, nonatomic) NSMutableArray<AUIRoomLiveRtcPlayer *> *joinList; // 当前上麦列表
@property (assign, nonatomic) NSUInteger displayIndex;
@property (assign, nonatomic) BOOL micOpened;
@property (assign, nonatomic) BOOL cameraOpened;

@property (assign, nonatomic) BOOL isApplyingLinkMic;
@property (assign, nonatomic) BOOL needToNotifyApplyNotResponse;

@end


@implementation AUIRoomInteractionLiveManagerAudience

- (NSArray<AUIRoomLiveRtcPlayer *> *)currentJoinList {
    return [self.joinList copy];
}

- (void)setupPullPlayer {
    [self setupPullPlayerWithRemoteJoinList:self.liveService.joinList];
}

- (void)setupPullPlayerWithRemoteJoinList:(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *)remoteJoinList {
    self.joinList = [NSMutableArray array];
    self.displayIndex = 0;
    self.micOpened = YES;
    self.cameraOpened = YES;
    __block BOOL find = NO;
    [remoteJoinList enumerateObjectsUsingBlock:^(AUIRoomLiveLinkMicJoinInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:AUIRoomAccount.me.userId]) {
            find = YES;
            self.displayIndex = idx;
            self.micOpened = obj.micOpened;
            self.cameraOpened = obj.cameraOpened;
            return;
        }
        AUIRoomLiveRtcPlayer *pull = [[AUIRoomLiveRtcPlayer alloc] init];
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
    self.livePusher = [[AUIRoomLivePusher alloc] init];
    self.livePusher.liveInfoModel = self.liveService.liveInfoModel;
    self.livePusher.beautyController = self.roomVC ? [[AUIRoomBeautyController alloc] initWithPresentView:self.roomVC.view contextMode:YES] : nil;
    self.livePusher.isMute = !self.micOpened;
    self.livePusher.isPause = !self.cameraOpened;
}

- (BOOL)isJoinedLinkMic {
    return self.livePusher != nil;
}

- (void)preparePullPlayer {
    if ([self isJoinedLinkMic]) {
        
        [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull pull, NSUInteger idx, BOOL * _Nonnull stop) {
            [pull prepare];
            pull.displayView.isAnchor = [pull.joinInfo.userId isEqualToString:self.liveService.liveInfoModel.anchor_id];
            pull.displayView.nickName = [pull.joinInfo.userId isEqualToString:AUIRoomAccount.me.userId] ? @"我" : pull.joinInfo.userNick;
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
        [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
        [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.displayLayoutView removeDisplayView:obj.displayView];
            [obj destory];
        }];
        [self.displayLayoutView removeDisplayView:self.livePusher.displayView];
        [self.livePusher destory];
        self.livePusher = nil;
        [self.displayLayoutView layoutAll];
        self.isLiving = NO;
        [self.liveService sendLeaveLinkMic:byKickout completed:nil];
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
    [self.liveService sendApplyLinkMic:self.liveService.liveInfoModel.anchor_id completed:^(BOOL success) {
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
    
    [self.liveService sendCancelApplyLinkMic:self.liveService.liveInfoModel.anchor_id completed:nil];
    if (completed) {
        completed(YES);
    }
}

// 收到同意上麦
- (void)receivedAgreeToLinkMic:(NSString *)userId willGiveUp:(BOOL)giveUp completed:(nullable void (^)(BOOL success, BOOL giveUp, NSString *message))completed {
    if (!self.isLiving || ![userId isEqualToString:self.liveService.liveInfoModel.anchor_id]) {
        if (completed) {
            completed(NO, NO, @"当前状态不对");
        }
        return;
    }
    
    self.isApplyingLinkMic = NO;
    [self cancelNotifyApplyNotResponse];
    
    if (giveUp) {
        [self.liveService sendCancelApplyLinkMic:self.liveService.liveInfoModel.anchor_id completed:nil];
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
    if (!self.isLiving || ![userId isEqualToString:self.liveService.liveInfoModel.anchor_id]) {
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
- (void)receivedJoinLinkMic:(AUIRoomLiveLinkMicJoinInfoModel *)joinInfo completed:(nullable void (^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    if ([self isJoinedLinkMic]) {
        if ([joinInfo.userId isEqual:AUIRoomAccount.me.userId]) {
            if (completed) {
                completed(YES);
            }
            return;
        }
        __block AUIRoomLiveRtcPlayer *pull = nil;
        [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.joinInfo.userId isEqualToString:joinInfo.userId]) {
                pull = obj;
                *stop = YES;
            }
        }];
        if (!pull) {
            pull = [[AUIRoomLiveRtcPlayer alloc] init];
            pull.joinInfo = joinInfo;
            [self.joinList addObject:pull];
            
            [pull prepare];
            pull.displayView.isAnchor = [pull.joinInfo.userId isEqualToString:self.liveService.liveInfoModel.anchor_id];
            pull.displayView.nickName = [pull.joinInfo.userId isEqualToString:AUIRoomAccount.me.userId] ? @"我" : pull.joinInfo.userNick;
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
        if ([userId isEqualToString:AUIRoomAccount.me.userId]) {
            [self leaveLinkMic:YES completed:completed];
            return;
        }
        
        __block AUIRoomLiveRtcPlayer *pull = nil;
        [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    [self.liveService queryLinkMicJoinList:^(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> * _Nullable remoteJoinList) {
        if (!remoteJoinList) {
            if (completed) {
                completed(NO, @"无法获取当前上麦列表，上麦失败");
            }
            return;
        }
        
        if (remoteJoinList.count >= AUIRoomLiveService.maxLinkMicCount) {
            if (completed) {
                completed(NO, @"当前连麦人数已经超过最大限制，连麦失败");
            }
            return;
        }
        
        AUIRoomLiveLinkMicJoinInfoModel *my = [[AUIRoomLiveLinkMicJoinInfoModel alloc] init:AUIRoomAccount.me.userId userNick:AUIRoomAccount.me.nickName userAvatar:AUIRoomAccount.me.avatar rtcPullUrl:weakSelf.liveService.liveInfoModel.link_info.rtc_pull_url];
        NSMutableArray<AUIRoomLiveLinkMicJoinInfoModel *> *list = [NSMutableArray arrayWithArray:remoteJoinList];
        [list addObject:my];
        [weakSelf destoryPullPlayer];
        [weakSelf setupPullPlayerWithRemoteJoinList:list];
        [weakSelf preparePullPlayer];
        [weakSelf startPullPlayer];
        
        [weakSelf.liveService sendJoinLinkMic:my.rtcPullUrl completed:nil];
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

- (void)receivedMicOpened:(AUIRoomUser *)sender opened:(BOOL)opened completed:(void (^)(BOOL))completed {
    if (!self.isLiving || !self.isJoinedLinkMic || [sender.userId isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    __block AUIRoomLiveRtcPlayer *pull = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)receivedCameraOpened:(AUIRoomUser *)sender opened:(BOOL)opened completed:(void (^)(BOOL))completed {
    if (!self.isLiving || !self.isJoinedLinkMic || [sender.userId isEqualToString:AUIRoomAccount.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block AUIRoomLiveRtcPlayer *pull = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUIRoomLiveRtcPlayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)receivedNeedOpenMic:(AUIRoomUser *)sender needOpen:(BOOL)needOpen completed:(void (^)(BOOL))completed {
    if (!self.isLiving || !self.isJoinedLinkMic || ![sender.userId isEqualToString:self.liveService.liveInfoModel.anchor_id]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    [self.livePusher mute:!needOpen];
    [self.liveService sendMicOpened:!self.livePusher.isMute completed:completed];
}

- (void)receivedNeedOpenCamera:(AUIRoomUser *)sender needOpen:(BOOL)needOpen completed:(void (^)(BOOL))completed {
    if (!self.isLiving || !self.isJoinedLinkMic || ![sender.userId isEqualToString:self.liveService.liveInfoModel.anchor_id]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    [self.livePusher pause:!needOpen];
    [self.liveService sendMicOpened:!self.livePusher.isPause completed:completed];
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
