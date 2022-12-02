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

@property (copy, nonatomic) NSString *notice;

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
    if (!self.isJoined || !self.isAnchor) {
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
    if (!self.isJoined || !self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    if (self.liveInfoModel.status == AUIInteractionLiveStatusFinished) {
        if (completed) {
            completed(YES);
        }
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
    if (!self.isJoined || !self.isAnchor) {
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
    if (!self.isJoined || !self.isAnchor) {
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

#pragma mark - Notice

- (void)updateNotice:(NSString *)notice completed:(void (^)(BOOL))completed {
    if (!self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    [AUIInteractionLiveService updateLive:self.liveInfoModel.live_id title:nil notice:notice extend:nil completed:^(AUIInteractionLiveInfoModel * _Nullable model, NSError * _Nullable error) {
        if (!error) {
            self.notice = notice;
            NSDictionary *msg = @{@"notice":notice?:@""};
            [self sendMessage:msg type:AUIInteractionLiveMessageTypeNotice uids:nil skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
                if (completed) {
                    completed(success);
                }
            }];
        }
        if (completed) {
            completed(!error);
        }
    }];
}


#pragma mark - Like

- (void)sendLike {
    self.likeCountWillSend++;
    NSLog(@"like_button:will send:%zd", self.likeCountWillSend);
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
        NSLog(@"like_button:sending:%zd", self.likeCountToSend);
        __weak typeof(self) weakSelf = self;
        [self sendLike:self.likeCountToSend completed:^(BOOL success) {
            if (!success) {
                weakSelf.likeCountWillSend += weakSelf.likeCountToSend;
                NSLog(@"like_button:send failed:%zd", weakSelf.likeCountToSend);
            }
            else {
                NSLog(@"like_button:send completed:%zd", weakSelf.likeCountToSend);
            }
            if (weakSelf.likeCountWillSend > 0) {
                [weakSelf startSendLikeTimer];
                NSLog(@"like_button:next 2 second to send:%zd", weakSelf.likeCountWillSend);
            }
        }];
    }
}

#pragma mark - Pusher state

- (void)sendCameraOpened:(BOOL)opened completed:(void (^)(BOOL))completed {
    if (!self.isJoined) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{@"cameraOpened":@(opened)};
    [self sendMessage:msg type:AUIInteractionLiveMessageTypeCameraOpened uids:nil skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

- (void)sendMicOpened:(BOOL)opened completed:(void (^)(BOOL))completed {
    if (!self.isJoined) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{@"micOpened":@(opened)};
    [self sendMessage:msg type:AUIInteractionLiveMessageTypeMicOpened uids:nil skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

- (void)sendOpenCamera:(NSString *)userId needOpen:(BOOL)needOpen completed:(void (^)(BOOL))completed {
    if (!self.isJoined || !self.isAnchor || userId.length == 0 || [userId isEqualToString:AUIInteractionAccountManager.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    NSDictionary *msg = @{@"needOpenCamera":@(needOpen)};
    [self sendMessage:msg type:AUIInteractionLiveMessageTypeNeedOpenCamera uids:@[userId] skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

- (void)sendOpenMic:(NSString *)userId needOpen:(BOOL)needOpen completed:(void (^)(BOOL))completed {
    if (!self.isJoined || !self.isAnchor || userId.length == 0 || [userId isEqualToString:AUIInteractionAccountManager.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    NSDictionary *msg = @{@"needOpenMic":@(needOpen)};
    [self sendMessage:msg type:AUIInteractionLiveMessageTypeNeedOpenMic uids:@[userId] skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
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
    if (self.isAnchor || ![uid isEqualToString:self.liveInfoModel.anchor_id]) {
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

- (void)sendCancelApplyLinkMic:(NSString *)uid completed:(void (^)(BOOL))completed {
    if (!self.isJoined || uid.length == 0 || [uid isEqualToString:AUIInteractionAccountManager.me.userId]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    // 观众只能跟主播取消申请连麦
    if (self.isAnchor || ![uid isEqualToString:self.liveInfoModel.anchor_id]) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    NSDictionary *msg = @{
    };
    [self sendMessage:msg type:AUIInteractionLiveMessageTypeCancelApplyLinkMic uids:@[uid] skipMuteCheck:YES skipAudit:YES completed:^(BOOL success) {
        if (completed) {
            completed(success);
        }
    }];
}

- (void)sendResponseLinkMic:(NSString *)uid agree:(BOOL)agree pullUrl:(NSString *)pullUrl completed:(void (^)(BOOL))completed {
    if (!self.isJoined || !self.isAnchor || uid.length == 0 || [uid isEqualToString:AUIInteractionAccountManager.me.userId]) {
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
    if (!self.isJoined || pullUrl.length == 0 || self.isAnchor) {
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
    if (!self.isJoined || self.isAnchor) {
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
    if (!self.isAnchor || !self.isJoined || uid.length == 0 || [uid isEqualToString:AUIInteractionAccountManager.me.userId]) {
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

- (void)queryLinkMicJoinList:(void (^)(NSArray<AUIInteractionLiveLinkMicJoinInfoModel *> *))completed {
    
    if (self.liveInfoModel.mode == AUIInteractionLiveModeBase) {
        if (completed) {
            completed(nil);
        }
        return;
    }
    
    [AUIInteractionLiveService queryLinkMicJoinList:self.liveInfoModel.live_id completed:^(NSArray<AUIInteractionLiveLinkMicJoinInfoModel *> * _Nullable models, NSError * _Nullable error) {
        if (completed) {
            completed(models);
        }
    }];
}

- (void)updateLinkMicJoinList:(NSArray<AUIInteractionLiveLinkMicJoinInfoModel *> *)joinList completed:(nullable void (^)(BOOL))completed {
    if (!self.isAnchor) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    [AUIInteractionLiveService updateLinkMicJoinList:self.liveInfoModel.live_id joinList:joinList completed:^(NSError * _Nullable error) {
        if (completed) {
            completed(error == nil);
        }
    }];
}

#pragma mark - Life Cycle

- (instancetype)initWithModel:(AUIInteractionLiveInfoModel *)model
                 withJoinList:(NSArray<AUIInteractionLiveLinkMicJoinInfoModel *> *)joinList
        withInteractionEngine:(AVCIInteractionEngine *)interactionEngine {
    self = [super init];
    if (self) {
        _liveInfoModel = model;
        _joinList = joinList;
        _interactionEngine = interactionEngine;
        
        _allLikeCount = _liveInfoModel.metrics.like_count;
        _pv = _liveInfoModel.metrics.pv;
        _notice = _liveInfoModel.notice;
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
    if (message.type == AUIInteractionLiveMessageTypeNotice) {
        NSString *notice = [data objectForKey:@"notice"];
        self.notice = notice;
        if (self.onReceivedNoticeUpdate) {
            self.onReceivedNoticeUpdate(sender, notice);
        }
        return;
    }
    
    if (message.type == AUIInteractionLiveMessageTypeJoinLinkMic) {
        AUIInteractionLiveLinkMicJoinInfoModel *joinInfo = [[AUIInteractionLiveLinkMicJoinInfoModel alloc] init:sender.userId userNick:sender.nickName userAvatar:sender.avatar rtcPullUrl:[data objectForKey:@"rtcPullUrl"]];
        if (self.onReceivedJoinLinkMic) {
            self.onReceivedJoinLinkMic(sender, joinInfo);
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
    if (message.type == AUIInteractionLiveMessageTypeCancelApplyLinkMic) {
        if (self.onReceivedCancelApplyLinkMic) {
            self.onReceivedCancelApplyLinkMic(sender);
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
    
    if (message.type == AUIInteractionLiveMessageTypeMicOpened) {
        if (self.onReceivedMicOpened) {
            self.onReceivedMicOpened(sender, [[data objectForKey:@"micOpened"] boolValue]);
        }
        return;
    }
    
    if (message.type == AUIInteractionLiveMessageTypeCameraOpened) {
        if (self.onReceivedCameraOpened) {
            self.onReceivedCameraOpened(sender, [[data objectForKey:@"cameraOpened"] boolValue]);
        }
        return;
    }
    
    if (message.type == AUIInteractionLiveMessageTypeNeedOpenMic) {
        if (self.onReceivedOpenMic) {
            self.onReceivedOpenMic(sender, [[data objectForKey:@"needOpenMic"] boolValue]);
        }
        return;
    }
    
    if (message.type == AUIInteractionLiveMessageTypeNeedOpenCamera) {
        if (self.onReceivedOpenCamera) {
            self.onReceivedOpenCamera(sender, [[data objectForKey:@"needOpenCamera"] boolValue]);
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
