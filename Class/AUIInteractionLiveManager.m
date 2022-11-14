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

#import "AUILiveRoomBeautyManager.h"
#import "AUIInteractionLiveSDKHeader.h"

#import <objc/message.h>


@interface AUIInteractionLiveManager () <AVCIInteractionEngineDelegate, AVCIInteractionServiceDelegate>

@property (nonatomic, strong) AVCIInteractionEngine *interactionEngine;
@property (nonatomic, strong) AVCIInteractionEngineConfig *interactionEngineConfig;


@property (nonatomic, copy) void (^loginCompleted)(BOOL success);

@property (nonatomic, strong) NSHashTable<AUILiveRoomManager *> *roomManagerList;

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

- (void)createLive:(AUIInteractionLiveMode)mode title:(NSString *)title currentVC:(UIViewController *)currentVC {
    __weak typeof(self) weakSelf = self;
    AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:currentVC.view animated:YES];
    loading.labelText = @"正在创建直播间，请等待";
    [self login:^(BOOL success) {
        if (!success) {
            [loading hideAnimated:YES];
            [AVAlertController show:@"登录失败" vc:currentVC];
            return;
        }
        
        [AUIInteractionLiveService createLive:nil mode:mode title:title ?: [NSString stringWithFormat:@"%@的直播", AUIInteractionAccountManager.me.nickName]  extend:nil completed:^(AUIInteractionLiveInfoModel * _Nullable model, NSError * _Nullable error) {
            [loading hideAnimated:YES];
            if (error) {
                [AVAlertController show:@"创建直播间失败" vc:currentVC];
                return;
            }
            
            AUILiveRoomManager *roomManager = [[AUILiveRoomManager alloc] initWithModel:model withInteractionEngine:weakSelf.interactionEngine];
            [weakSelf.roomManagerList addObject:roomManager];
            AUILiveRoomAnchorViewController *vc = [[AUILiveRoomAnchorViewController alloc] initWithManger:roomManager];
            [currentVC.navigationController pushViewController:vc animated:YES];
        }];
    }];
}

- (void)joinLive:(AUIInteractionLiveInfoModel *)model currentVC:(UIViewController *)currentVC {
    __weak typeof(self) weakSelf = self;
    AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:currentVC.view animated:YES];
    loading.labelText = @"正在加入直播间，请等待";
    [self login:^(BOOL success) {
        if (!success) {
            [loading hideAnimated:YES];
            [AVAlertController show:@"登录失败" vc:currentVC];
            return;
        }
        
        [AUIInteractionLiveService fetchLive:model.live_id userId:nil completed:^(AUIInteractionLiveInfoModel * _Nullable model, NSError * _Nullable error) {
            [loading hideAnimated:YES];
            if (error) {
                [AVAlertController show:@"登入直播间失败" vc:currentVC];
                return;
            }
            
            AUILiveRoomManager *roomManager = [[AUILiveRoomManager alloc] initWithModel:model withInteractionEngine:weakSelf.interactionEngine];
            [weakSelf.roomManagerList addObject:roomManager];
            if ([model.anchor_id isEqualToString:AUIInteractionAccountManager.me.userId]) {
                AUILiveRoomAnchorViewController *vc = [[AUILiveRoomAnchorViewController alloc] initWithManger:roomManager];
                [currentVC.navigationController pushViewController:vc animated:YES];
            }
            else {
                AUILiveRoomAudienceViewController *vc = [[AUILiveRoomAudienceViewController alloc] initWithManger:roomManager];
                [currentVC.navigationController pushViewController:vc animated:YES];
            }
            
        }];
    }];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
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
