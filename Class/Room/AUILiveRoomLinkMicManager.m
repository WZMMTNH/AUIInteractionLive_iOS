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
    [self.roomManager.liveInfoModel.link_info.linkMicList enumerateObjectsUsingBlock:^(AUIInteractionLiveLinkMicPullInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:self.roomManager.liveInfoModel.anchor_id]) {
            return;
        }
        AUILiveRoomRtcPull *pull = [[AUILiveRoomRtcPull alloc] init];
        pull.pullInfo = obj;
        [self.joinList addObject:pull];
    }];
}

- (void)prepareLivePusher {
    [super prepareLivePusher];
    
    [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj prepare];
        [self.displayView addDisplayView:obj.displayView];
    }];
    [self.displayView layoutAll];
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
        [self.displayView removeDisplayView:obj.displayView];
    }];
    [self.displayView layoutAll];
}

- (BOOL)checkCanLinkMic {
    return self.joinList.count + self.joiningList.count < 4;
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
        if ([obj.pullInfo.userId isEqualToString:sender.userId]) {
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
        if ([obj.pullInfo.userId isEqualToString:uid]) {
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
- (void)receivedJoinLinkMic:(AUIInteractionLiveLinkMicPullInfo *)linkMicUserInfo completed:(nullable void(^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __block AUILiveRoomRtcPull *pull = nil;
    [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.pullInfo.userId isEqualToString:linkMicUserInfo.userId]) {
            pull = obj;
            *stop = YES;
        }
    }];
    if (!pull) {
        pull = [[AUILiveRoomRtcPull alloc] init];
        pull.pullInfo = linkMicUserInfo;
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
        if ([obj.pullInfo.userId isEqualToString:userId]) {
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
    [self.displayView addDisplayView:pull.displayView];
    [self.displayView layoutAll];
    [pull start];
    
    __block AUIInteractionLiveUser *joiningUser = nil;
    [self.joiningList enumerateObjectsUsingBlock:^(AUIInteractionLiveUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:pull.pullInfo.userId]) {
            joiningUser = obj;
            *stop = YES;
        }
    }];
    if (joiningUser) {
        [self.joiningList removeObject:joiningUser];
    }
    [self.joinList addObject:pull];
    [self mixStream];
    
    NSMutableArray *array = [NSMutableArray array];
    [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:obj.pullInfo];
    }];
    AUIInteractionLiveLinkMicPullInfo *pullInfo = [[AUIInteractionLiveLinkMicPullInfo alloc] init:AUIInteractionAccountManager.me.userId userNick:AUIInteractionAccountManager.me.nickName rtcPullUrl:self.roomManager.liveInfoModel.link_info.rtc_pull_url];
    [array insertObject:pullInfo atIndex:0];
    [self.roomManager updateLinkMicList:array completed:nil];
}

- (void)onLeaveLinkMic:(AUILiveRoomRtcPull *)pull {
    [self.displayView removeDisplayView:pull.displayView];
    [self.displayView layoutAll];
    [pull destory];
    [self.joinList removeObject:pull];
    [self mixStream];
    
    NSMutableArray *array = [NSMutableArray array];
    [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:obj.pullInfo];
    }];
    AUIInteractionLiveLinkMicPullInfo *pullInfo = [[AUIInteractionLiveLinkMicPullInfo alloc] init:AUIInteractionAccountManager.me.userId userNick:AUIInteractionAccountManager.me.nickName rtcPullUrl:self.roomManager.liveInfoModel.link_info.rtc_pull_url];
    [array insertObject:pullInfo atIndex:0];
    [self.roomManager updateLinkMicList:array completed:nil];
}

- (void)mixStream {
    AlivcLiveTranscodingConfig *liveTranscodingConfig = nil;
    if (self.joinList.count > 0) {
        NSMutableArray *array = [NSMutableArray array];
        CGRect rect = [self.displayView renderRect:self.livePusher.displayView];
        AlivcLiveMixStream *anchorStream = [[AlivcLiveMixStream alloc] init];
        anchorStream.userId = self.livePusher.liveInfoModel.anchor_id;
        anchorStream.x = rect.origin.x;
        anchorStream.y = rect.origin.y;
        anchorStream.width = rect.size.width;
        anchorStream.height = rect.size.height;
        anchorStream.zOrder = 1;
        [array addObject:anchorStream];
        
        [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect rect = [self.displayView renderRect:obj.displayView];
            AlivcLiveMixStream *audienceStream = [[AlivcLiveMixStream alloc] init];
            audienceStream.userId = obj.pullInfo.userId;
            audienceStream.x = rect.origin.x;
            audienceStream.y = rect.origin.y;
            audienceStream.width = rect.size.width;
            audienceStream.height = rect.size.height;
            audienceStream.zOrder = (int)idx + 2;
            [array addObject:audienceStream];
        }];
        liveTranscodingConfig = [[AlivcLiveTranscodingConfig alloc] init];
        liveTranscodingConfig.mixStreams = array;
    }
    
    [self.livePusher setLiveMixTranscodingConfig:liveTranscodingConfig];
}

@end


//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx



@interface AUILiveRoomLinkMicManagerAudience ()

@property (strong, nonatomic) AUILiveRoomPusher *livePusher;
@property (strong, nonatomic) NSMutableArray<AUILiveRoomRtcPull *> *joinList; // 当前上麦列表

@end


@implementation AUILiveRoomLinkMicManagerAudience

- (void)setupPullPlayer {
    [self setupPullPlayerWithLinkMicList:self.roomManager.liveInfoModel.link_info.linkMicList];
}

- (void)setupPullPlayerWithLinkMicList:(NSArray<AUIInteractionLiveLinkMicPullInfo *> *)linkMicList {
    self.joinList = [NSMutableArray array];
    __block BOOL find = NO;
    [linkMicList enumerateObjectsUsingBlock:^(AUIInteractionLiveLinkMicPullInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:AUIInteractionAccountManager.me.userId]) {
            find = YES;
            return;
        }
        AUILiveRoomRtcPull *pull = [[AUILiveRoomRtcPull alloc] init];
        pull.pullInfo = obj;
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
//    self.livePusher.onStartedBlock = self.onStartedBlock;
//    self.livePusher.onPausedBlock = self.onPausedBlock;
//    self.livePusher.onResumedBlock = self.onResumedBlock;
//    self.livePusher.onRestartBlock = self.onRestartBlock;
//    self.livePusher.onConnectionPoorBlock = self.onConnectionPoorBlock;
//    self.livePusher.onConnectionLostBlock = self.onConnectionLostBlock;
//    self.livePusher.onConnectionRecoveryBlock = self.onConnectionRecoveryBlock;
//    self.livePusher.onConnectErrorBlock = self.onConnectErrorBlock;
//    self.livePusher.onReconnectStartBlock = self.onReconnectStartBlock;
//    self.livePusher.onReconnectSuccessBlock = self.onReconnectSuccessBlock;
//    self.livePusher.onReconnectErrorBlock = self.onReconnectErrorBlock;
//
}

- (BOOL)isJoinedLinkMic {
    return self.livePusher != nil;
}

- (void)preparePullPlayer {
    if ([self isJoinedLinkMic]) {
        
        [self.displayView addDisplayView:self.livePusher.displayView];
        [self.livePusher prepare];
        [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj prepare];
            [self.displayView addDisplayView:obj.displayView];
        }];
        [self.displayView layoutAll];
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
            [self.displayView removeDisplayView:obj.displayView];
            [obj destory];
        }];
        [self.displayView removeDisplayView:self.livePusher.displayView];
        [self.livePusher destory];
        self.livePusher = nil;
        [self.displayView layoutAll];
        self.isLiving = NO;
        [self.roomManager sendLeaveLinkMic:byKickout completed:nil];
    }
    else {
        [super destoryPullPlayer];
    }
}

- (void)applyLinkMic:(void (^)(BOOL))completed {
    if ([self isJoinedLinkMic] || !self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    [self.roomManager sendApplyLinkMic:self.roomManager.liveInfoModel.anchor_id completed:completed];
}

- (void)receivedResponseLinkMic:(NSString *)userId agree:(BOOL)agree completed:(nullable void (^)(BOOL))completed {
    if (!self.isLiving || ![userId isEqualToString:self.roomManager.liveInfoModel.anchor_id]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    if (agree) {
        [self joinLinkMic:^(BOOL success) {
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


// 收到其他观众上麦
- (void)receivedJoinLinkMic:(AUIInteractionLiveLinkMicPullInfo *)linkMicUserInfo completed:(nullable void (^)(BOOL))completed {
    if (!self.isLiving) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    if ([self isJoinedLinkMic]) {
        if ([linkMicUserInfo.userId isEqual:AUIInteractionAccountManager.me.userId]) {
            if (completed) {
                completed(YES);
            }
            return;
        }
        __block AUILiveRoomRtcPull *pull = nil;
        [self.joinList enumerateObjectsUsingBlock:^(AUILiveRoomRtcPull * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.pullInfo.userId isEqualToString:linkMicUserInfo.userId]) {
                pull = obj;
                *stop = YES;
            }
        }];
        if (!pull) {
            pull = [[AUILiveRoomRtcPull alloc] init];
            pull.pullInfo = linkMicUserInfo;
            [self.joinList addObject:pull];
            
            [pull prepare];
            [self.displayView addDisplayView:pull.displayView];
            [self.displayView layoutAll];
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

// 收到其他观众下麦
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
            if ([obj.pullInfo.userId isEqualToString:userId]) {
                pull = obj;
                *stop = YES;
            }
        }];
        if (pull) {
            [self.displayView removeDisplayView:pull.displayView];
            [self.displayView layoutAll];
                    
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
- (void)joinLinkMic:(void(^)(BOOL))completed; {
    if (!self.isLiving || [self isJoinedLinkMic]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.roomManager queryLinkMicList:^(NSArray<AUIInteractionLiveLinkMicPullInfo *> * _Nullable linkMicList) {
        if (!linkMicList) {
            if (completed) {
                completed(NO);
            }
            return;
        }
        AUIInteractionLiveLinkMicPullInfo *my = [[AUIInteractionLiveLinkMicPullInfo alloc] init:AUIInteractionAccountManager.me.userId userNick:@"我" rtcPullUrl:weakSelf.roomManager.liveInfoModel.link_info.rtc_pull_url];
        NSMutableArray<AUIInteractionLiveLinkMicPullInfo *> *list = [NSMutableArray arrayWithArray:linkMicList];
        [list addObject:my];
        [weakSelf destoryPullPlayer];
        [weakSelf setupPullPlayerWithLinkMicList:list];
        [weakSelf preparePullPlayer];
        [weakSelf startPullPlayer];
        
        [weakSelf.roomManager sendJoinLinkMic:my.rtcPullUrl completed:nil];
        if (completed) {
            completed(YES);
        }
    }];
}

// 下麦
- (void)leaveLinkMic:(BOOL)byKickout completed:(void(^)(BOOL))completed; {
    if (!self.isLiving || ![self isJoinedLinkMic]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    [self destoryPullPlayerByKick:byKickout];
    [self setupPullPlayerWithLinkMicList:nil];
    [self preparePullPlayer];
    [self startPullPlayer];
    if (completed) {
        completed(YES);
    }
}

// 下麦
- (void)leaveLinkMic:(void(^)(BOOL))completed; {
    [self leaveLinkMic:NO completed:completed];
}

- (NSArray<AUILiveRoomRtcPull *> *)currentJoinList {
    return [self.joinList copy];
}

@end
