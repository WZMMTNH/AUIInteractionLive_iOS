//
//  AUILiveRoomBaseLiveManager.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/28.
//

#import <Foundation/Foundation.h>
#import "AUILiveRoomManager.h"
#import "AUILiveRoomPusher.h"
#import "AUILiveRoomCdnPull.h"
#import "AUILiveRoomBeautyController.h"
#import "AUILiveRoomLiveDisplayLayoutView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AUILiveRoomLiveManagerAnchorProtocol <NSObject>

@property (strong, nonatomic, readonly) AUILiveRoomManager *roomManager;
@property (nonatomic, strong, readonly) AUILiveRoomLiveDisplayLayoutView *displayLayoutView;
@property (strong, nonatomic, readonly) AUILiveRoomPusher *livePusher;
@property (assign, nonatomic, readonly) BOOL isLiving;
@property (nonatomic, weak) UIViewController *roomVC;

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

@interface AUILiveRoomBaseLiveManagerAnchor : NSObject<AUILiveRoomLiveManagerAnchorProtocol>

- (instancetype)initWithRoomManager:(AUILiveRoomManager *)roomManager displayView:(AUILiveRoomLiveDisplayLayoutView *)displayView;

@end






@protocol AUILiveRoomLiveManagerAudienceProtocol <NSObject>

@property (strong, nonatomic, readonly) AUILiveRoomManager *roomManager;
@property (nonatomic, strong, readonly) AUILiveRoomLiveDisplayLayoutView *displayLayoutView;
@property (assign, nonatomic, readonly) BOOL isLiving;
@property (nonatomic, weak) UIViewController *roomVC;

- (void)setupPullPlayer;
- (void)preparePullPlayer;
- (void)startPullPlayer;
- (void)destoryPullPlayer;

@end


@interface AUILiveRoomBaseLiveManagerAudience : NSObject<AUILiveRoomLiveManagerAudienceProtocol>

- (instancetype)initWithRoomManager:(AUILiveRoomManager *)roomManager displayView:(AUILiveRoomLiveDisplayLayoutView *)displayView;

@end

NS_ASSUME_NONNULL_END
