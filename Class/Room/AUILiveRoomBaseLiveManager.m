//
//  AUILiveRoomBaseLiveManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/28.
//

#import "AUILiveRoomBaseLiveManager+Private.h"
#import <Masonry/Masonry.h>

@implementation AUILiveRoomBaseLiveManagerAnchor

@synthesize roomVC;

@synthesize onStartedBlock;
@synthesize onResumedBlock;
@synthesize onRestartBlock;
@synthesize onReconnectSuccessBlock;
@synthesize onReconnectStartBlock;
@synthesize onReconnectErrorBlock;
@synthesize onPausedBlock;
@synthesize onConnectionRecoveryBlock;
@synthesize onConnectionPoorBlock;
@synthesize onConnectionLostBlock;
@synthesize onConnectErrorBlock;


- (instancetype)initWithRoomManager:(AUILiveRoomManager *)roomManager displayView:(nonnull AUILiveRoomLiveDisplayLayoutView *)displayView {
    self = [super init];
    if (self) {
        self.roomManager = roomManager;
        self.displayLayoutView = displayView;
    }
    return self;
}

- (void)setupLivePusher {
    self.livePusher = [[AUILiveRoomPusher alloc] init];
    self.livePusher.liveInfoModel = self.roomManager.liveInfoModel;
    self.livePusher.onStartedBlock = self.onStartedBlock;
    self.livePusher.onPausedBlock = self.onPausedBlock;
    self.livePusher.onResumedBlock = self.onResumedBlock;
    self.livePusher.onRestartBlock = self.onRestartBlock;
    self.livePusher.onConnectionPoorBlock = self.onConnectionPoorBlock;
    self.livePusher.onConnectionLostBlock = self.onConnectionLostBlock;
    self.livePusher.onConnectionRecoveryBlock = self.onConnectionRecoveryBlock;
    self.livePusher.onConnectErrorBlock = self.onConnectErrorBlock;
    self.livePusher.onReconnectStartBlock = self.onReconnectStartBlock;
    self.livePusher.onReconnectSuccessBlock = self.onReconnectSuccessBlock;
    self.livePusher.onReconnectErrorBlock = self.onReconnectErrorBlock;
    self.isLiving = NO;
}

- (void)prepareLivePusher {
    [self.displayLayoutView addDisplayView:self.livePusher.displayView];
    [self.displayLayoutView layoutAll];
    [self.livePusher prepare];
}

- (void)startLivePusher {
    [self.livePusher start];
    self.isLiving = YES;
}

- (void)stopLivePusher {
    [self.livePusher stop];
    self.isLiving = NO;
}

- (void)destoryLivePusher {
    [self.displayLayoutView removeDisplayView:self.livePusher.displayView];
    [self.displayLayoutView layoutAll];
    [self.livePusher destory];
    self.livePusher = nil;
    self.isLiving = NO;
}

- (BOOL)openLivePusherMic:(BOOL)open {
    [self.livePusher mute:!open];
    BOOL ret = !self.livePusher.isMute;
    return ret;
}

- (BOOL)openLivePusherCamera:(BOOL)open {
    [self.livePusher pause:!open];
    BOOL ret = !self.livePusher.isPause;
    return ret;
}

@end



@implementation AUILiveRoomBaseLiveManagerAudience

@synthesize roomVC;

- (instancetype)initWithRoomManager:(AUILiveRoomManager *)roomManager displayView:(nonnull AUILiveRoomLiveDisplayLayoutView *)displayView {
    self = [super init];
    if (self) {
        self.roomManager = roomManager;
        self.displayLayoutView = displayView;
    }
    return self;
}

- (void)setupPullPlayer {
    self.cdnPull = [[AUILiveRoomCdnPull alloc] init];
    self.cdnPull.liveInfoModel = self.roomManager.liveInfoModel;
    self.isLiving = NO;
}

- (void)preparePullPlayer {
    [self.displayLayoutView addDisplayView:self.cdnPull.displayView];
    [self.displayLayoutView layoutAll];
    [self.cdnPull prepare];
}

- (void)startPullPlayer {
    [self.cdnPull start];
    self.isLiving = YES;
}

- (void)destoryPullPlayer {
    [self.displayLayoutView removeDisplayView:self.cdnPull.displayView];
    [self.displayLayoutView layoutAll];
    [self.cdnPull destory];
    self.cdnPull = nil;
    
    self.isLiving = NO;
    [self.cdnPull.displayView endLoading];
}

@end

