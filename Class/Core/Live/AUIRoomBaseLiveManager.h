//
//  AUIRoomBaseLiveManager.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/28.
//

#import <Foundation/Foundation.h>
#import "AUIRoomLiveService.h"
#import "AUIRoomLivePusher.h"
#import "AUIRoomLiveCdnPlayer.h"
#import "AUIRoomBeautyController.h"
#import "AUIRoomDisplayView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AUIRoomLiveManagerAnchorProtocol <NSObject>

@property (strong, nonatomic, readonly) AUIRoomLiveService *liveService;
@property (strong, nonatomic, readonly) AUIRoomDisplayLayoutView *displayLayoutView;
@property (strong, nonatomic, readonly) AUIRoomLivePusher *livePusher;
@property (assign, nonatomic, readonly) BOOL isLiving;
@property (weak, nonatomic) UIViewController *roomVC;

@property (copy, nonatomic) void(^onStartedBlock)(void);
@property (copy, nonatomic) void(^onPausedBlock)(void);
@property (copy, nonatomic) void(^onResumedBlock)(void);
@property (copy, nonatomic) void(^onRestartBlock)(void);
@property (copy, nonatomic) void(^onConnectionPoorBlock)(void);
@property (copy, nonatomic) void(^onConnectionLostBlock)(void);
@property (copy, nonatomic) void(^onConnectionRecoveryBlock)(void);
@property (copy, nonatomic) void(^onConnectErrorBlock)(void);
@property (copy, nonatomic) void(^onReconnectStartBlock)(void);
@property (copy, nonatomic) void(^onReconnectSuccessBlock)(void);
@property (copy, nonatomic) void(^onReconnectErrorBlock)(void);
- (void)setupLivePusher;
- (void)prepareLivePusher;
- (void)startLivePusher;
- (void)stopLivePusher;
- (void)destoryLivePusher;

- (BOOL)openLivePusherMic:(BOOL)open;
- (BOOL)openLivePusherCamera:(BOOL)open;

@end

@interface AUIRoomBaseLiveManagerAnchor : NSObject<AUIRoomLiveManagerAnchorProtocol>

- (instancetype)initWithLiveService:(AUIRoomLiveService *)liveService displayView:(AUIRoomDisplayLayoutView *)displayView;

@end






@protocol AUIRoomLiveManagerAudienceProtocol <NSObject>

@property (strong, nonatomic, readonly) AUIRoomLiveService *liveService;
@property (strong, nonatomic, readonly) AUIRoomDisplayLayoutView *displayLayoutView;
@property (assign, nonatomic, readonly) BOOL isLiving;
@property (weak, nonatomic) UIViewController *roomVC;

- (void)setupPullPlayer;
- (void)preparePullPlayer;
- (void)startPullPlayer;
- (void)destoryPullPlayer;

@end


@interface AUIRoomBaseLiveManagerAudience : NSObject<AUIRoomLiveManagerAudienceProtocol>

- (instancetype)initWithLiveService:(AUIRoomLiveService *)liveService displayView:(AUIRoomDisplayLayoutView *)displayView;

@end

NS_ASSUME_NONNULL_END
