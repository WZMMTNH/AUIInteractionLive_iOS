//
//  AUIInteractionLiveManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/6.
//

#import "AUIInteractionLiveManager.h"
#import "AUIInteractionAccountManager.h"
#import "AUIInteractionLiveService.h"

#import "AUIFoundation.h"
#import "AUILiveRoomAnchorViewController.h"
#import "AUILiveRoomAudienceViewController.h"
#import "AUIInteractionLiveCreateViewController.h"

#import "AUILiveRoomBeautyManager.h"
#import "AUIInteractionLiveSDKHeader.h"

#import <objc/message.h>


@interface AUIInteractionLiveManager () <AVCIInteractionEngineDelegate, AVCIInteractionServiceDelegate>

@property (nonatomic, strong) AVCIInteractionEngine *interactionEngine;
@property (nonatomic, strong) AVCIInteractionEngineConfig *interactionEngineConfig;


@property (nonatomic, copy) void (^loginCompleted)(BOOL success);

@property (nonatomic, strong) NSHashTable<AUILiveRoomManager *> *roomManagerList;

@property (nonatomic, copy) NSString *lastLiveId;

@end

@implementation AUIInteractionLiveManager

+ (void)registerLive {
    [AlivcLiveBase registerSDK];
    
#if DEBUG
    [AlivcLiveBase setLogLevel:AlivcLivePushLogLevelDebug];
    [AlivcLiveBase setLogPath:NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject maxPartFileSizeInKB:1024*100];
#endif
    
    [AUILiveRoomBeautyManager registerBeautyEngine];
}

+ (instancetype)defaultManager {
    static AUIInteractionLiveManager *_instance = nil;
    if (!_instance) {
        _instance = [AUIInteractionLiveManager new];
    }
    return _instance;
}

- (void)login:(void(^)(BOOL))completed {
    if (self.interactionEngine.isLogin) {
        if (completed) {
            completed(YES);
        }
        return;
    }
    if (AUIInteractionAccountManager.me.userId.length == 0) {
        if (completed) {
            completed(NO);
        }
        return;
    }
    if (self.loginCompleted) {
        self.loginCompleted(NO);
    }
    self.loginCompleted = completed;
    [self.interactionEngine loginWithUserID:AUIInteractionAccountManager.me.userId];
}

- (void)logout {
    if (!self.interactionEngine.isLogin) {
        return;
    }
    [self.interactionEngine logoutOnSuccess:^{
        ;
    } onFailure:^(AVCIInteractionError * _Nonnull error) {
        NSAssert(NO, @"Logout failure");
    }];
}

- (void)createLive:(AUIInteractionLiveMode)mode title:(NSString *)title notice:(NSString *)notice currentVC:(UIViewController *)currentVC completed:(void(^)(BOOL success))completedBlock {
    __weak typeof(self) weakSelf = self;
    AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:currentVC.view animated:YES];
    loading.labelText = @"正在创建直播间，请等待";
    [self login:^(BOOL success) {
        if (!success) {
            [loading hideAnimated:YES];
            [AVAlertController show:@"登录失败" vc:currentVC];
            if (completedBlock) {
                completedBlock(NO);
            }
            return;
        }
        
        [AUIInteractionLiveService createLive:nil mode:mode title:title ?: [NSString stringWithFormat:@"%@的直播", AUIInteractionAccountManager.me.nickName] notice:notice extend:nil completed:^(AUIInteractionLiveInfoModel * _Nullable model, NSError * _Nullable error) {
            [loading hideAnimated:YES];
            if (error) {
                [AVAlertController show:@"创建直播间失败" vc:currentVC];
                if (completedBlock) {
                    completedBlock(NO);
                }
                return;
            }
            
            AUILiveRoomManager *roomManager = [[AUILiveRoomManager alloc] initWithModel:model withJoinList:nil withInteractionEngine:weakSelf.interactionEngine];
            [weakSelf.roomManagerList addObject:roomManager];
            AUILiveRoomAnchorViewController *vc = [[AUILiveRoomAnchorViewController alloc] initWithManger:roomManager];
            [currentVC.navigationController pushViewController:vc animated:YES];
            
            [weakSelf saveLastLiveData:model.live_id];
            
            if (completedBlock) {
                completedBlock(YES);
            }
        }];
    }];
}

- (void)createLive:(UIViewController *)currentVC {
    
    AUIInteractionLiveCreateViewController *vc = [AUIInteractionLiveCreateViewController new];
    
    __weak typeof(AUIInteractionLiveCreateViewController *) weakVC = vc;
    vc.onCreateLiveBlock = ^(NSString * _Nonnull title, NSString * _Nullable notice, BOOL interactionMode) {
        [AUILiveRoomBeautyManager checkResourceWithCurrentView:weakVC.view completed:^(BOOL completed) {
            if (!completed) {
                [AVAlertController showWithTitle:@"初始化美颜失败，是否继续？" message:@"继续可能导致没美颜效果" cancelTitle:@"取消" okTitle:@"继续" onCompleted:^(BOOL isCanced) {
                    if (isCanced) {
                        return;
                    }
                    [self createLive:interactionMode ? AUIInteractionLiveModeLinkMic : AUIInteractionLiveModeBase title:title notice:notice currentVC:weakVC completed:^(BOOL success) {
                        if (success) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [weakVC removeFromParentViewController];
                            });
                        }
                    }];
                }];
                return;
            }
            [self createLive:interactionMode ? AUIInteractionLiveModeLinkMic : AUIInteractionLiveModeBase title:title notice:notice currentVC:weakVC completed:^(BOOL success) {
                if (success) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakVC removeFromParentViewController];
                    });
                }
            }];
        }];
    };
    
    [currentVC.navigationController pushViewController:vc animated:YES];
}

- (void)fetchLinkMicJoinList:(AUIInteractionLiveInfoModel *)model completed:(void(^)(NSArray<AUIInteractionLiveLinkMicJoinInfoModel *> *joinList, NSError *error))completed {
    if (model.mode == AUIInteractionLiveModeLinkMic) {
        [AUIInteractionLiveService queryLinkMicJoinList:model.live_id completed:^(NSArray<AUIInteractionLiveLinkMicJoinInfoModel *> * _Nullable models, NSError * _Nullable error) {
            if (completed) {
                completed(models, error);
            }
        }];
        return;
    }
    if (completed) {
        completed(nil, nil);
    }
}

- (void)joinLiveWithLiveId:(NSString *)liveId currentVC:(UIViewController *)currentVC {
    __weak typeof(self) weakSelf = self;
    AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:currentVC.view animated:YES];
    loading.labelText = @"正在加入直播间，请等待";
    // 登录IM
    [self login:^(BOOL success) {
        if (!success) {
            [loading hideAnimated:YES];
            [AVAlertController show:@"直播间登入失败" vc:currentVC];
            return;
        }
        
        // 获取最新直播信息
        [AUIInteractionLiveService fetchLive:liveId userId:nil completed:^(AUIInteractionLiveInfoModel * _Nullable model, NSError * _Nullable error) {
            if (error) {
                [loading hideAnimated:YES];
                [AVAlertController show:@"直播间刷新失败" vc:currentVC];
                return;
            }
            
            // 获取上麦信息
            [weakSelf fetchLinkMicJoinList:model completed:^(NSArray<AUIInteractionLiveLinkMicJoinInfoModel *> *joinList, NSError *error) {
                
                [loading hideAnimated:YES];
                if (error) {
                    [AVAlertController show:@"获取上麦列表失败" vc:currentVC];
                    return;
                }
                
                // 创建room manager，进入直播间
                AUILiveRoomManager *roomManager = [[AUILiveRoomManager alloc] initWithModel:model withJoinList:joinList withInteractionEngine:weakSelf.interactionEngine];
                [weakSelf.roomManagerList addObject:roomManager];
                if ([model.anchor_id isEqualToString:AUIInteractionAccountManager.me.userId]) {
                    AUILiveRoomAnchorViewController *vc = [[AUILiveRoomAnchorViewController alloc] initWithManger:roomManager];
                    [currentVC.navigationController pushViewController:vc animated:YES];
                }
                else {
                    AUILiveRoomAudienceViewController *vc = [[AUILiveRoomAudienceViewController alloc] initWithManger:roomManager];
                    [currentVC.navigationController pushViewController:vc animated:YES];
                }
                [weakSelf saveLastLiveData:liveId];
                
            }];
        }];
    }];
}

- (void)joinLive:(AUIInteractionLiveInfoModel *)model currentVC:(UIViewController *)currentVC {
    [self joinLiveWithLiveId:model.live_id currentVC:currentVC];
}


- (void)joinLastLive:(UIViewController *)currentVC {
    if (![self hasLastLive]) {
        [AVAlertController show:@"没有上场直播数据" vc:currentVC];
        return;
    }
    
    [self joinLiveWithLiveId:self.lastLiveId currentVC:currentVC];
}

- (BOOL)hasLastLive {
    return self.lastLiveId.length > 0;
}

- (void)loadLastLiveData {
    NSString *last_live_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_live_id"];
    if (AUIInteractionAccountManager.me.userId.length > 0 && [last_live_id hasPrefix:AUIInteractionAccountManager.me.userId]) {
        self.lastLiveId = [last_live_id substringFromIndex:AUIInteractionAccountManager.me.userId.length + 1];
    }
    else {
        self.lastLiveId = nil;
    }
}

- (void)saveLastLiveData:(NSString *)lastLiveId {
    if ([self.lastLiveId isEqualToString:lastLiveId]) {
        return;
    }
    self.lastLiveId = lastLiveId;
    if (self.lastLiveId.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@_%@", AUIInteractionAccountManager.me.userId, self.lastLiveId] forKey:@"last_live_id"];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"last_live_id"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadLastLiveData];
    }
    return self;
}

#pragma -mark Properties
- (AVCIInteractionEngine *)interactionEngine {
    if (!_interactionEngine) {
        _interactionEngine = [[AVCIInteractionEngine alloc] initWithConfig:self.interactionEngineConfig];
        _interactionEngine.delegate = self;
    }
    return _interactionEngine;
}

- (AVCIInteractionEngineConfig *)interactionEngineConfig {
    if (!_interactionEngineConfig) {
        _interactionEngineConfig = [[AVCIInteractionEngineConfig alloc] init];
        _interactionEngineConfig.deviceID = AUIInteractionAccountManager.deviceId;
        _interactionEngineConfig.requestToken = ^(void (^ _Nonnull onRequestedToken)(NSString * _Nonnull, NSString * _Nonnull)) {
            [AUIInteractionLiveService fetchToken:^(NSString * _Nullable accessToken, NSString * _Nullable refreshToken, NSError * _Nullable error) {
                NSLog(@"accessToken:%@\nrefreshToken:%@", accessToken, refreshToken);
                if (onRequestedToken) {
                    onRequestedToken(accessToken ?: @"", refreshToken ?: @"");
                }
            }];
        };
    }
    return _interactionEngineConfig;
}

- (NSHashTable<AUILiveRoomManager *> *)roomManagerList {
    if (!_roomManagerList) {
        _roomManagerList = [NSHashTable weakObjectsHashTable];
    }
    return _roomManagerList;
}

#pragma -mark AVCIInteractionEngineDelegate

- (void)onKickout:(NSString *)info {
    ;
}

- (void)onError:(AVCIInteractionError *)error {
    NSLog(@"onConnectiononError:%d, message:%@", error.code, error.message);
}

- (void)onConnectionStatusChanged:(int32_t)status {
    NSLog(@"onConnectionStatusChanged:%d", status);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == 4) {
            self.interactionEngine.interactionService.delegate = self;
            if (self.loginCompleted) {
                self.loginCompleted(YES);
            }
            self.loginCompleted = nil;
        }
        else if (status == 0) {
            if (self.loginCompleted) {
                self.loginCompleted(NO);
            }
            self.loginCompleted = nil;
            [[AUIInteractionLiveManager defaultManager] logout];
        }
    });
}

- (void)onLog:(NSString *)log level:(AliInteractionLogLevel)level {
    NSLog(@"[IMSDK]:%@", log);
}

#pragma -mark AVCIInteractionServiceDelegate

- (void)onCustomMessageReceived:(AVCIInteractionGroupMessage *)message {
    [self onMessageReceived:message selector:@selector(onCustomMessageReceived:)];
}

- (void)onLikeReceived:(AVCIInteractionGroupMessage *)message {
    [self onMessageReceived:message selector:@selector(onLikeReceived:)];
}

- (void)onJoinGroup:(AVCIInteractionGroupMessage *)message {
    [self onMessageReceived:message selector:@selector(onJoinGroup:)];
}

- (void)onLeaveGroup:(AVCIInteractionGroupMessage *)message {
    [self onMessageReceived:message selector:@selector(onLeaveGroup:)];
}

- (void)onMuteGroup:(AVCIInteractionGroupMessage *)message {
    [self onMessageReceived:message selector:@selector(onMuteGroup:)];
}

- (void)onCancelMuteGroup:(AVCIInteractionGroupMessage *)message {
    [self onMessageReceived:message selector:@selector(onCancelMuteGroup:)];
}

- (void)onMuteUser:(AVCIInteractionGroupMessage *)message {
    [self onMessageReceived:message selector:@selector(onMuteUser:)];
}

- (void)onCancelMuteUser:(AVCIInteractionGroupMessage *)message {
    [self onMessageReceived:message selector:@selector(onCancelMuteUser:)];
}

- (void)onMessageReceived:(AVCIInteractionGroupMessage *)message selector:(SEL)selector {
    NSLog(@"onMessageReceived:%@, type:%d, gid:%@, uid:%@, nick_name:%@", message.data, message.type, message.groupId, message.senderInfo.userID, message.senderInfo.userNick);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSEnumerator<AUILiveRoomManager *>* enumerator = [self.roomManagerList objectEnumerator];
        AUILiveRoomManager *roomManager = nil;
        while ((roomManager = [enumerator nextObject])) {
            if ([roomManager.liveInfoModel.chat_id isEqualToString:message.groupId]) {
//                [roomManager onMessageReceived:message];
                [roomManager performSelector:selector withObject:message];
            }
        }
    });
}

@end
