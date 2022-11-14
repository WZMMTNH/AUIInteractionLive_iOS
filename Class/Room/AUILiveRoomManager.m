//
//  AUILiveRoomManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/7.
//

#import "AUILiveRoomManager.h"
#import "AUIInteractionAccountManager.h"
#import "AUIInteractionLiveService.h"

@interface AUILiveRoomManager ()

@property (strong, nonatomic) AUIInteractionLiveInfoModel *liveInfoModel;
@property (strong, nonatomic) AVCIInteractionEngine *interactionEngine;

@property (assign, nonatomic) NSInteger pv;
@property (assign, nonatomic) BOOL isJoined;

@property (assign, nonatomic) BOOL isMuteAll;
@property (assign, nonatomic) BOOL isMuteByAuchor;

@property (nonatomic, strong) NSTimer *sendLikeTimer;
@property (assign, nonatomic) NSInteger allLikeCount;
@property (assign, nonatomic) NSInteger likeCountWillSend;
@property (assign, nonatomic) NSInteger likeCountToSend;

@end

@implementation AUILiveRoomManager

- (BOOL)isAnchor {
    return [self.liveInfoModel.anchor_id isEqualToString:AUIInteractionAccountManager.me.userId];
}

- (NSString *)jsonStringWithDict:(NSDictionary *)dict {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark - Room

- (void)enterRoom:(void(^)(BOOL))completed {
    __weak typeof(self) weakSelf = self;
    [self.interactionEngine.interactionService joinGroup:self.liveInfoModel.chat_id userNick:AUIInteractionAccountManager.me.nickName userAvatar:AUIInteractionAccountManager.me.avatar userExtension:@"{}" broadCastType:2 broadCastStatistics:YES onSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.isJoined = YES;
            if (completed) {
                completed(YES);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        NSLog(@"IM Error:joinGroup(%d,%@)", error.code, error.message);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(NO);
            }
        });
    }];
}

- (void)leaveRoom:(void(^)(BOOL))completed {
    __weak typeof(self) weakSelf = self;
    [self.interactionEngine.interactionService leaveGroup:self.liveInfoModel.chat_id broadCastType:0 onSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.isJoined = NO;
            if (completed) {
                completed(YES);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        NSLog(@"IM Error:leaveGroup(%d,%@)", error.code, error.message);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(NO);
            }
        });
    }];
}

#pragma mark - Live

- (void)startLive:(void(^)(BOOL))completed {
    if (!self.isJoined || ![self isAnchor]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    [AUIInteractionLiveService startLive:self.liveInfoModel.live_id ?: @"" completed:^(AUIInteractionLiveInfoModel * _Nullable model, NSError * _Nullable error) {
        if (error) {
            if (completed) {
                completed(NO);
            }
        }
        [self.liveInfoModel updateStatus:model.status];
        NSDictionary *msg = @{};
        [self sendMessage:msg type:AUIInteractionLiveMessageTypeStartLive uids:nil skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
            if (completed) {
                completed(success);
            }
        }];
    }];
}

- (void)finishLive:(void(^)(BOOL))completed {
    if (!self.isJoined || ![self isAnchor]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    [AUIInteractionLiveService stopLive:self.liveInfoModel.live_id ?: @"" completed:^(AUIInteractionLiveInfoModel * _Nullable model, NSError * _Nullable error) {
        if (error) {
            if (completed) {
                completed(NO);
            }
        }
        [self.liveInfoModel updateStatus:model.status];
        NSDictionary *msg = @{};
        [self sendMessage:msg type:AUIInteractionLiveMessageTypeStopLive uids:nil skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
            if (completed) {
                completed(success);
            }
        }];
    }];
}

#pragma mark - Mute

- (void)queryMuteAll:(void (^)(BOOL))completed {
    if (!self.isJoined) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.interactionEngine.interactionService getGroup:self.liveInfoModel.chat_id onSuccess:^(AVCIInteractionGroupDetail * _Nonnull groupDetail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.isMuteAll = groupDetail.isMuteAll;
            if (completed) {
                completed(YES);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(NO);
            }
        });
    }];
}

- (void)queryMuteByAnchor:(void (^)(BOOL))completed {
    if (!self.isJoined) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.interactionEngine.interactionService listMuteUsersWithGroupID:self.liveInfoModel.chat_id onSuccess:^(NSArray<AVCIInteractionMuteUser *> * _Nonnull users) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.isMuteByAuchor = NO;
            [users enumerateObjectsUsingBlock:^(AVCIInteractionMuteUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([AUIInteractionAccountManager.me.userId isEqualToString:obj.userId]) {
                    weakSelf.isMuteByAuchor = YES;
                    *stop = YES;
                }
            }];
            if (completed) {
                completed(YES);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(NO);
            }
        });
    }];
}

- (void)muteAll:(void (^)(BOOL))completed {
    if (!self.isJoined || ![self isAnchor]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.interactionEngine.interactionService muteAll:self.liveInfoModel.chat_id broadCastType:2 onSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.isMuteAll = YES;
            if (completed) {
                completed(YES);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(NO);
            }
        });
    }];
}

- (void)cancelMuteAll:(void (^)(BOOL))completed {
    if (!self.isJoined || ![self isAnchor]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.interactionEngine.interactionService cancelMuteAll:self.liveInfoModel.chat_id broadCastType:2 onSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.isMuteAll = NO;
            if (completed) {
                completed(YES);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(NO);
            }
        });
    }];
}

#pragma mark - Like

- (void)sendLike {
    self.likeCountWillSend++;
    NSLog(@"SendLike will send:%zd", self.likeCountWillSend);
    if (!self.sendLikeTimer) {
        [self startSendLikeTimer];
    }
}

- (void)sendLike:(NSInteger)count completed:(void(^)(BOOL))completed {
    if (!self.isJoined) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    [self.interactionEngine.interactionService sendLikeWithGroupID:self.liveInfoModel.chat_id count:(int32_t)count broadCastType:2 onSuccess:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(YES);
            }
        });
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                completed(NO);
            }
        });
    }];
}

- (void)startSendLikeTimer {
    if (self.isJoined) {
        self.sendLikeTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timeToSendLike) userInfo:nil repeats:NO];
    }
}

- (void)stopSendLikeTimer {
    [self.sendLikeTimer invalidate];
    self.sendLikeTimer = nil;
}

- (void)timeToSendLike {
    [self stopSendLikeTimer];
    
    if (self.likeCountWillSend > 0) {
        self.likeCountToSend = self.likeCountWillSend;
        self.likeCountWillSend = 0;
        NSLog(@"SendLike sending:%zd", self.likeCountToSend);
        __weak typeof(self) weakSelf = self;
        [self sendLike:self.likeCountToSend completed:^(BOOL success) {
            if (!success) {
                weakSelf.likeCountWillSend += weakSelf.likeCountToSend;
                NSLog(@"SendLike send failed:%zd", weakSelf.likeCountToSend);
            }
            else {
                NSLog(@"SendLike send completed:%zd", weakSelf.likeCountToSend);
            }
            if (weakSelf.likeCountWillSend > 0) {
                [weakSelf startSendLikeTimer];
                NSLog(@"SendLike next 2 second to send:%zd", weakSelf.likeCountWillSend);
            }
        }];
    }
}

#pragma mark - Comment

- (void)sendComment:(NSString *)comment completed:(void(^)(BOOL))completed {
    if (!self.isJoined) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    if (comment.length == 0) {
        if (completed) {
            completed(NO);
        }
    }
    NSDictionary *msg = @{
        @"content":comment,
    };
    [self sendMessage:msg type:AUIInteractionLiveMessageTypeComment uids:nil skipMuteCheck:NO skipAudit:NO completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

#pragma mark - Message

- (void)sendMessage:(NSDictionary *)content type:(AUIInteractionLiveMessageType)type uids:(NSArray<NSString *> *)uids skipMuteCheck:(BOOL)skipMuteCheck skipAudit:(BOOL)skipAudit completed:(void (^)(BOOL))completed {
    if (content == nil) {
        content = @{};
    }
    NSString *json = [self jsonStringWithDict:content];

    if (uids.count > 0) {
        [self.interactionEngine.interactionService sendTextMessageToGroupUsers:json groupID:self.liveInfoModel.chat_id type:(int32_t)type userIDs:uids skipMuteCheck:skipMuteCheck skipAudit:skipAudit onSuccess:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed) {
                    completed(YES);
                }
            });
        } onFailure:^(AVCIInteractionError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed) {
                    completed(NO);
                }
            });
        }];
    }
    else {
        [self.interactionEngine.interactionService sendTextMessage:json groupID:self.liveInfoModel.chat_id type:(int32_t)type skipMuteCheck:skipMuteCheck skipAudit:skipAudit onSuccess:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed) {
                    completed(YES);
                }
            });
        } onFailure:^(AVCIInteractionError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completed) {
                    completed(NO);
                }
            });
        }];
    }
}

#pragma mark - link mic

- (void)sendApplyLinkMic:(NSString *)uid completed:(void (^)(BOOL))completed {
    if (!self.isJoined || uid.length == 0 || [uid isEqualToString:AUIInteractionAccountManager.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    // 观众只能申请跟主播连麦
    if (![self isAnchor] && ![uid isEqualToString:self.liveInfoModel.anchor_id]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{
    };
    [self sendMessage:msg type:AUIInteractionLiveMessageTypeApplyLinkMic uids:@[uid] skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

- (void)sendResponseLinkMic:(NSString *)uid agree:(BOOL)agree pullUrl:(NSString *)pullUrl completed:(void (^)(BOOL))completed {
    if (!self.isJoined || uid.length == 0 || [uid isEqualToString:AUIInteractionAccountManager.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    NSMutableDictionary *msg = [NSMutableDictionary dictionary];
    [msg setObject:@(agree) forKey:@"agree"];
    if (agree) {
        [msg setObject:pullUrl?:@"" forKey:@"rtcPullUrl"];
    }
    [self sendMessage:msg type:AUIInteractionLiveMessageTypeResponseLinkMic uids:@[uid] skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

- (void)sendJoinLinkMic:(NSString *)pullUrl completed:(void (^)(BOOL))completed {
    if (!self.isJoined || pullUrl.length == 0 || [self isAnchor]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{
        @"rtcPullUrl":pullUrl?:@"",
    };
    [self sendMessage:msg type:AUIInteractionLiveMessageTypeJoinLinkMic uids:nil skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

- (void)sendLeaveLinkMic:(BOOL)byKickout completed:(void (^)(BOOL))completed {
    if (!self.isJoined || [self isAnchor]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{
        @"reason":byKickout ? @"byKickout" : @"bySelf"
    };
    [self sendMessage:msg type:AUIInteractionLiveMessageTypeLeaveLinkMic uids:nil skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

- (void)sendKickoutLinkMic:(NSString *)uid completed:(void (^)(BOOL))completed {
    if (![self isAnchor] || !self.isJoined || uid.length == 0 || [uid isEqualToString:AUIInteractionAccountManager.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{
    };
    [self sendMessage:msg type:AUIInteractionLiveMessageTypeKickoutLinkMic uids:@[uid] skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

- (void)queryLinkMicList:(void (^)(NSArray<AUIInteractionLiveLinkMicPullInfo *> *))completed {
    [AUIInteractionLiveService fetchLive:self.liveInfoModel.live_id userId:self.liveInfoModel.anchor_id completed:^(AUIInteractionLiveInfoModel * _Nullable model, NSError * _Nullable error) {
        if (error) {
            if (completed) {
                completed(nil);
            }
        }
        else {
            NSMutableArray *list = [NSMutableArray array];
            if (model.mode == AUIInteractionLiveModeBase) {
                list = nil;
            }
            else {
                AUIInteractionLiveLinkMicPullInfo *anchor = [[AUIInteractionLiveLinkMicPullInfo alloc] init:model.anchor_id userNick:@"主播" rtcPullUrl:model.link_info.rtc_pull_url];
                [list addObject:anchor];
                [model.link_info.linkMicList enumerateObjectsUsingBlock:^(AUIInteractionLiveLinkMicPullInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.userId isEqual:anchor.userId]) {
                        return;
                    }
                    [list addObject:obj];
                }];
            }
            
            if (completed) {
                completed(list);
            }
        }
    }];
}

- (void)updateLinkMicList:(NSArray<AUIInteractionLiveLinkMicPullInfo *> *)linkMicList completed:(void (^)(BOOL))completed {
    if (![self isAnchor]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    if (!linkMicList) {
        linkMicList = @[];
    }
    NSMutableDictionary *extends = [NSMutableDictionary dictionaryWithDictionary:self.liveInfoModel.extends];
    NSMutableArray *linkmicInfo = [NSMutableArray array];
    [linkMicList enumerateObjectsUsingBlock:^(AUIInteractionLiveLinkMicPullInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [linkmicInfo addObject:[obj toDictionary]];
    }];
    [extends setObject:linkmicInfo forKey:@"linkMicInfo"];
    
    [AUIInteractionLiveService updateLive:self.liveInfoModel.live_id title:self.liveInfoModel.title extend:extends completed:^(AUIInteractionLiveInfoModel * _Nullable model, NSError * _Nullable error) {
        if (completed) {
            completed(!error);
        }
    }];
}

#pragma mark - Life Cycle

- (instancetype)initWithModel:(AUIInteractionLiveInfoModel *)model withInteractionEngine:(AVCIInteractionEngine *)interactionEngine {
    self = [super init];
    if (self) {
        _liveInfoModel = model;
        _interactionEngine = interactionEngine;
        
        _allLikeCount = _liveInfoModel.metrics.like_count;
        _pv = _liveInfoModel.metrics.pv;
    }
    return self;
}

#pragma mark - AVCIInteractionServiceDelegate

- (void)onCustomMessageReceived:(AVCIInteractionGroupMessage *)message {
    
    AUIInteractionLiveUser *sender = [self senderFromMessage:message];
    NSDictionary *data = [self dictFromMessage:message];

    if (message.type == AUIInteractionLiveMessageTypeComment) {
        if (self.onReceivedComment) {
            NSString *comment = [data objectForKey:@"content"];
            self.onReceivedComment(sender, comment);
        }
        return;
    }
    if (message.type == AUIInteractionLiveMessageTypeStartLive) {
        if (self.onReceivedStartLive) {
            self.onReceivedStartLive(sender);
        }
        return;
    }
    if (message.type == AUIInteractionLiveMessageTypeStopLive) {
        if (self.onReceivedStopLive) {
            self.onReceivedStopLive(sender);
        }
        return;
    }
    
    if (message.type == AUIInteractionLiveMessageTypeJoinLinkMic) {
        AUIInteractionLiveLinkMicPullInfo *linkMicUserInfo = [[AUIInteractionLiveLinkMicPullInfo alloc] init:sender.userId userNick:sender.nickName rtcPullUrl:[data objectForKey:@"rtcPullUrl"]];
        if (self.onReceivedJoinLinkMic) {
            self.onReceivedJoinLinkMic(sender, linkMicUserInfo);
        }
        return;
    }
    if (message.type == AUIInteractionLiveMessageTypeLeaveLinkMic) {
        if (self.onReceivedLeaveLinkMic) {
            self.onReceivedLeaveLinkMic(sender, sender.userId);
        }
        return;
    }
    if (message.type == AUIInteractionLiveMessageTypeApplyLinkMic) {
        if (self.onReceivedApplyLinkMic) {
            self.onReceivedApplyLinkMic(sender);
        }
        return;
    }
    if (message.type == AUIInteractionLiveMessageTypeResponseLinkMic) {
        if (self.onReceivedResponseApplyLinkMic) {
            self.onReceivedResponseApplyLinkMic(sender, [[data objectForKey:@"agree"] boolValue], [data objectForKey:@"rtcPullUrl"]);
        }
        return;
    }
    if (message.type == AUIInteractionLiveMessageTypeKickoutLinkMic) {
        if (self.onReceivedLeaveLinkMic) {
            self.onReceivedLeaveLinkMic(sender, AUIInteractionAccountManager.me.userId);
        }
        return;
    }
    
    if (self.onReceivedCustomMessage) {
        AUIInteractionLiveMessage *liveMsg = [AUIInteractionLiveMessage new];
        liveMsg.msgId = message.messageId;
        liveMsg.msgType = message.type;
        liveMsg.data = data;
        liveMsg.sender = sender;
        self.onReceivedCustomMessage(liveMsg);
    }
}

- (void)onLikeReceived:(AVCIInteractionGroupMessage *)message {
    NSDictionary *data = [self dictFromMessage:message];
    NSInteger likeCount = [[data objectForKey:@"likeCount"] integerValue];
    if (likeCount > self.allLikeCount) {
        self.allLikeCount = likeCount;
        if (self.onReceivedLike) {
            AUIInteractionLiveUser *sender = [self senderFromMessage:message];
            self.onReceivedLike(sender, self.allLikeCount);
        }
    }
}

- (void)onJoinGroup:(AVCIInteractionGroupMessage *)message {
    AUIInteractionLiveUser *sender = [self senderFromMessage:message];
    NSDictionary *data = [self dictFromMessage:message];
    NSDictionary *stat = [data objectForKey:@"statistics"];
    
    NSInteger likeCount = [[data objectForKey:@"likeCount"] integerValue];
    if (likeCount > self.allLikeCount) {
        self.allLikeCount = likeCount;
        if (self.onReceivedLike) {
            self.onReceivedLike(sender, self.allLikeCount);
        }
    }
    
    NSInteger pv = [[stat objectForKey:@"pv"] integerValue];
    if (pv > self.pv) {
        self.pv = pv;
        if (self.onReceivedPV) {
            self.onReceivedPV(sender, self.pv);
        }
    }
    
    if (self.onReceivedJoinGroup) {
        self.onReceivedJoinGroup(sender, stat);
    }
}

- (void)onLeaveGroup:(AVCIInteractionGroupMessage *)message {
    
}

- (void)onMuteGroup:(AVCIInteractionGroupMessage *)message {
    self.isMuteAll = YES;
    if (self.onReceivedMuteAll) {
        AUIInteractionLiveUser *sender = [self senderFromMessage:message];
        self.onReceivedMuteAll(sender, self.isMuteAll);
    }
}

- (void)onCancelMuteGroup:(AVCIInteractionGroupMessage *)message {
    self.isMuteAll = NO;
    if (self.onReceivedMuteAll) {
        AUIInteractionLiveUser *sender = [self senderFromMessage:message];
        self.onReceivedMuteAll(sender, self.isMuteAll);
    }
}

- (void)onMuteUser:(AVCIInteractionGroupMessage *)message {
}

- (void)onCancelMuteUser:(AVCIInteractionGroupMessage *)message {
}

- (AUIInteractionLiveUser *)senderFromMessage:(AVCIInteractionGroupMessage *)message {
    AUIInteractionLiveUser *sender = [AUIInteractionLiveUser new];
    sender.userId = message.senderInfo.userID ?: message.senderId;
    sender.nickName = message.senderInfo.userNick;
    sender.avatar = message.senderInfo.userAvatar;
    return sender;
}

- (NSDictionary *)dictFromMessage:(AVCIInteractionGroupMessage *)message {
    NSDictionary *dict = nil;
    if ([message.data isKindOfClass:NSDictionary.class]) {
        dict = message.data;
    }
    else if ([message.data isKindOfClass:NSString.class]) {
        dict = [NSJSONSerialization JSONObjectWithData:[message.data dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    }
    return dict;
}

@end
