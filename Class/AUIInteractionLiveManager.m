//
//  AUIInteractionLiveManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/6.
//

#import "AUIInteractionLiveManager.h"
#import "AUIRoomAccount.h"
#import "AUIRoomAppServer.h"
#import "AUIRoomMessageService.h"
#import "AUIRoomBeautyManager.h"

#import "AUILiveRoomAnchorViewController.h"
#import "AUILiveRoomAudienceViewController.h"
#import "AUILiveRoomCreateViewController.h"

#import "AUIRoomSDKHeader.h"

@interface AUIInteractionLiveManager ()

@property (nonatomic, copy) void (^loginCompleted)(BOOL success);

@property (nonatomic, copy) NSString *lastLiveId;

@end

@implementation AUIInteractionLiveManager

+ (void)registerLive {
    [AlivcLiveBase registerSDK];
    
#if DEBUG
    [AlivcLiveBase setLogLevel:AlivcLivePushLogLevelDebug];
    [AlivcLiveBase setLogPath:NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject maxPartFileSizeInKB:1024*100];
#endif
    
    [AUIRoomBeautyManager registerBeautyEngine];
}

+ (instancetype)defaultManager {
    static AUIInteractionLiveManager *_instance = nil;
    if (!_instance) {
        _instance = [AUIInteractionLiveManager new];
    }
    return _instance;
}

- (void)logout {
    [AUIRoomMessage.currentService logout];
}

- (void)createLive:(AUIRoomLiveMode)mode title:(NSString *)title notice:(NSString *)notice currentVC:(UIViewController *)currentVC completed:(void(^)(BOOL success))completedBlock {
    __weak typeof(self) weakSelf = self;
    AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:currentVC.view animated:YES];
    loading.labelText = @"正在创建直播间，请等待";
    [AUIRoomMessage.currentService login:^(BOOL success) {
        if (!success) {
            [loading hideAnimated:YES];
            [AVAlertController show:@"直播间登入失败" vc:currentVC];
            if (completedBlock) {
                completedBlock(NO);
            }
            return;
        }
        
        [AUIRoomAppServer createLive:nil mode:mode title:title ?: [NSString stringWithFormat:@"%@的直播", AUIRoomAccount.me.nickName] notice:notice extend:nil completed:^(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error) {
            [loading hideAnimated:YES];
            if (error) {
                [AVAlertController show:@"创建直播间失败" vc:currentVC];
                if (completedBlock) {
                    completedBlock(NO);
                }
                return;
            }
            
            AUIRoomLiveService *liveService = [[AUIRoomLiveService alloc] initWithModel:model withJoinList:nil];
            AUILiveRoomAnchorViewController *vc = [[AUILiveRoomAnchorViewController alloc] initWithLiveService:liveService];
            [currentVC.navigationController pushViewController:vc animated:YES];
            
            [weakSelf saveLastLiveData:model.live_id];
            
            if (completedBlock) {
                completedBlock(YES);
            }
        }];
    }];
}

- (void)createLive:(UIViewController *)currentVC {
    
    AUILiveRoomCreateViewController *vc = [AUILiveRoomCreateViewController new];
    
    __weak typeof(AUILiveRoomCreateViewController *) weakVC = vc;
    vc.onCreateLiveBlock = ^(NSString * _Nonnull title, NSString * _Nullable notice, BOOL interactionMode) {
        [AUIRoomBeautyManager checkResourceWithCurrentView:weakVC.view completed:^(BOOL completed) {
            if (!completed) {
                [AVAlertController showWithTitle:@"初始化美颜失败，是否继续？" message:@"继续可能导致没美颜效果" cancelTitle:@"取消" okTitle:@"继续" onCompleted:^(BOOL isCanced) {
                    if (isCanced) {
                        return;
                    }
                    [self createLive:interactionMode ? AUIRoomLiveModeLinkMic : AUIRoomLiveModeBase title:title notice:notice currentVC:weakVC completed:^(BOOL success) {
                        if (success) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [weakVC removeFromParentViewController];
                            });
                        }
                    }];
                }];
                return;
            }
            [self createLive:interactionMode ? AUIRoomLiveModeLinkMic : AUIRoomLiveModeBase title:title notice:notice currentVC:weakVC completed:^(BOOL success) {
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

- (void)fetchLinkMicJoinList:(AUIRoomLiveInfoModel *)model completed:(void(^)(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *joinList, NSError *error))completed {
    if (model.mode == AUIRoomLiveModeLinkMic) {
        [AUIRoomAppServer queryLinkMicJoinList:model.live_id completed:^(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> * _Nullable models, NSError * _Nullable error) {
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
    [AUIRoomMessage.currentService login:^(BOOL success) {
        if (!success) {
            [loading hideAnimated:YES];
            [AVAlertController show:@"直播间登入失败" vc:currentVC];
            return;
        }
        
        // 获取最新直播信息
        [AUIRoomAppServer fetchLive:liveId userId:nil completed:^(AUIRoomLiveInfoModel * _Nullable model, NSError * _Nullable error) {
            if (error) {
                [loading hideAnimated:YES];
                [AVAlertController show:@"直播间刷新失败" vc:currentVC];
                return;
            }
            
            // 获取上麦信息
            [weakSelf fetchLinkMicJoinList:model completed:^(NSArray<AUIRoomLiveLinkMicJoinInfoModel *> *joinList, NSError *error) {
                
                [loading hideAnimated:YES];
                if (error) {
                    [AVAlertController show:@"获取上麦列表失败" vc:currentVC];
                    return;
                }
                
                // 创建room manager，进入直播间
                AUIRoomLiveService *liveService = [[AUIRoomLiveService alloc] initWithModel:model withJoinList:joinList];
                if ([model.anchor_id isEqualToString:AUIRoomAccount.me.userId]) {
                    AUILiveRoomAnchorViewController *vc = [[AUILiveRoomAnchorViewController alloc] initWithLiveService:liveService];
                    [currentVC.navigationController pushViewController:vc animated:YES];
                }
                else {
                    AUILiveRoomAudienceViewController *vc = [[AUILiveRoomAudienceViewController alloc] initWithLiveService:liveService];
                    [currentVC.navigationController pushViewController:vc animated:YES];
                }
                [weakSelf saveLastLiveData:liveId];
                
            }];
        }];
    }];
}

- (void)joinLive:(AUIRoomLiveInfoModel *)model currentVC:(UIViewController *)currentVC {
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
    if (AUIRoomAccount.me.userId.length > 0 && [last_live_id hasPrefix:AUIRoomAccount.me.userId]) {
        self.lastLiveId = [last_live_id substringFromIndex:AUIRoomAccount.me.userId.length + 1];
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
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@_%@", AUIRoomAccount.me.userId, self.lastLiveId] forKey:@"last_live_id"];
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

@end
