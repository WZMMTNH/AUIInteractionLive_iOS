//
//  AUILiveRoomPusher.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/24.
//

#import <UIKit/UIKit.h>
#import "AUILiveRoomLiveDisplayLayoutView.h"
#import "AUILiveRoomBeautyController.h"
#import "AUIInteractionLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomPusher : NSObject

@property (strong, nonatomic) AUIInteractionLiveInfoModel *liveInfoModel;

@property (strong, nonatomic, readonly) AUILiveRoomLiveDisplayView *displayView;
@property (strong, nonatomic) AUILiveRoomBeautyController *beautyController;

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

@property (assign, nonatomic, readonly) BOOL isMute;
@property (assign, nonatomic, readonly) BOOL isPause;
@property (assign, nonatomic, readonly) BOOL isBackCamera;
@property (assign, nonatomic, readonly) BOOL isMirror;


- (void)prepare;
- (BOOL)start;
- (void)destory;

- (void)pause;
- (void)resume;
- (void)mute:(BOOL)mute;
- (void)switchCamera;
- (void)mirror:(BOOL)mirror;
- (void)setLiveMixTranscodingConfig:(AlivcLiveTranscodingConfig * _Nullable )liveTranscodingConfig;

@end

NS_ASSUME_NONNULL_END
