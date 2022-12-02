//
//  AUILiveRoomPusher.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/24.
//

#import "AUILiveRoomPusher.h"
#import "AUIInteractionLiveSDKHeader.h"
#import "AUIFoundation.h"
#import "AUIInteractionLiveMacro.h"
#import "AUIInteractionAccountManager.h"

@interface AUILiveRoomPusher () <
AlivcLivePusherErrorDelegate,
AlivcLivePusherInfoDelegate,
AlivcLivePusherNetworkDelegate,
AlivcLivePusherCustomFilterDelegate,
AlivcLivePusherCustomDetectorDelegate
>

@property (strong, nonatomic) AlivcLivePushConfig *pushConfig;
@property (strong, nonatomic) AlivcLivePusher *pushEngine;

@end

@implementation AUILiveRoomPusher

@synthesize displayView = _displayView;

- (void)dealloc {
    NSLog(@"dealloc:AUILiveRoomPusher");
}

- (AUILiveRoomLiveDisplayView *)displayView {
    if (!_displayView) {
        _displayView = [[AUILiveRoomLiveDisplayView alloc] initWithFrame:CGRectZero];
        _displayView.nickName = @"我";
        _displayView.isAnchor = [self.liveInfoModel.anchor_id isEqualToString:AUIInteractionAccountManager.me.userId];
    }
    return _displayView;
}

+ (UIImage *)pushBlackImage {
    return [UIImage av_imageWithColor:UIColor.blackColor size:CGSizeMake(720, 1280)];
}

+ (UIImage *)pushPauseImage {
    return AUIInteractionLiveGetCommonImage(@"ic_push_default.jpg");
}

#pragma mark - live pusher

- (void)prepare {
    
    AlivcLivePushMode pushMode = AlivcLivePushBasicMode;
    AlivcPusherPreviewDisplayMode displayMode = ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FILL;
    if (self.liveInfoModel.mode == AUIInteractionLiveModeLinkMic) {
        pushMode = AlivcLivePushInteractiveMode;
    }
    
    AlivcLivePushConfig *pushConfig = [[AlivcLivePushConfig alloc] init];
    pushConfig.resolution = AlivcLivePushResolution720P;
    pushConfig.previewDisplayMode = displayMode;
    pushConfig.livePushMode = pushMode;
    pushConfig.fps = AlivcLivePushFPS20;
    pushConfig.enableAutoBitrate = true;
    pushConfig.videoEncodeGop = AlivcLivePushVideoEncodeGOP_2;
    pushConfig.connectRetryInterval = 2000;
    pushConfig.orientation = AlivcLivePushOrientationPortrait;
    pushConfig.enableAutoResolution = YES;
    pushConfig.pauseImg = [self.class pushPauseImage];
    
    self.pushConfig = pushConfig;
    
    _pushEngine = [[AlivcLivePusher alloc] initWithConfig:pushConfig];
    [_pushEngine setErrorDelegate:self];
    [_pushEngine setInfoDelegate:self];
    [_pushEngine setNetworkDelegate:self];
    [_pushEngine setCustomFilterDelegate:self];
    [_pushEngine setCustomDetectorDelegate:self];
    [_pushEngine startPreview:self.displayView.renderView];
#if DEBUG
//    [self switchCamera];
//    [self mute:YES];
#endif
    
    [self mute:_isMute];
    [self pause:_isPause];
}

- (void)destory {
    [_pushEngine setLiveMixTranscodingConfig:nil];
    [_pushEngine stopPush];
    [_pushEngine stopPreview];
    [_pushEngine destory];
    _pushEngine = nil;
}

- (BOOL)start {
    if (!_pushEngine) {
        return NO;
    }
    if (self.liveInfoModel.mode == AUIInteractionLiveModeBase) {
        if (self.liveInfoModel.push_url_info.rtmp_url.length > 0) {
            [_pushEngine startPushWithURL:self.liveInfoModel.push_url_info.rtmp_url];
            return YES;
        }
    }
    else {
        if (self.liveInfoModel.link_info.rtc_push_url.length > 0) {
            [_pushEngine startPushWithURL:self.liveInfoModel.link_info.rtc_push_url];
            return YES;
        }
    }    
    return NO;
}

- (BOOL)stop {
    if (!_pushEngine) {
        return NO;
    }
    return [_pushEngine stopPush];
}

- (void)restart {
    if (!_pushEngine) {
        return;
    }
    [_pushEngine reconnectPushAsync];
    [self.displayView startLoading];
}

- (void)pause:(BOOL)pause {
    if (!_pushEngine) {
        return;
    }
    if (pause) {
        int ret = [_pushEngine pause];
        if (ret == 0) {
            _isPause = YES;
        }
    }
    else {
        int ret = [_pushEngine resume];
        if (ret == 0) {
            _isPause = NO;
        }
    }
}

- (void)mute:(BOOL)mute {
    if (!_pushEngine) {
        return;
    }
    [_pushEngine setMute:mute];
    _isMute = mute;
}

- (void)switchCamera {
    if (!_pushEngine) {
        return;
    }
    int ret = [_pushEngine switchCamera];
    if (ret == 0) {
        _isBackCamera = !_isBackCamera;
    }
}

- (void)mirror:(BOOL)mirror {
    if (!_pushEngine) {
        return;
    }
    if (self.liveInfoModel.mode == AUIInteractionLiveModeLinkMic) {
        [_pushEngine setPreviewMirror:!mirror];
        [_pushEngine setPushMirror:mirror];
    }
    else {
        [_pushEngine setPreviewMirror:mirror];
        [_pushEngine setPushMirror:mirror];
    }
    
    _isMirror = mirror;
}

- (void)setLiveMixTranscodingConfig:(AlivcLiveTranscodingConfig *)liveTranscodingConfig {
    [_pushEngine setLiveMixTranscodingConfig:liveTranscodingConfig];
}

#pragma mark - AlivcLivePusherInfoDelegate
- (void)onPreviewStarted:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onPreviewStarted");
    });
    [self.beautyController setupBeautyController];
}

- (void)onPreviewStoped:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onPreviewStoped");
    });
}

- (void)onFirstFramePreviewed:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onFirstFramePreviewed");
    });
}

- (void)onPushStarted:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onPushStarted");
        if (self.onStartedBlock) {
            self.onStartedBlock();
        }
    });
}

- (void)onPushPaused:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onPushPaused");
        if (self.onPausedBlock) {
            self.onPausedBlock();
        }
    });
}

- (void)onPushResumed:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onPushResumed");
        if (self.onResumedBlock) {
            self.onResumedBlock();
        }
    });
}

- (void)onPushRestart:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onPushRestart");
        if (self.onRestartBlock) {
            self.onRestartBlock();
        }
    });
}

- (void)onPushStoped:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onPushStoped");
    });
}

- (void)onPushStatistics:(AlivcLivePusher *)pusher statsInfo:(AlivcLivePushStatsInfo*)statistics {
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"LiveEvent:onPushStatistics");
    });
}

#pragma mark - AlivcLivePusherErrorDelegate

- (void)onSystemError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onSystemError");
        [self.displayView endLoading];
        if (self.onConnectErrorBlock) {
            self.onConnectErrorBlock();
        }
    });
}

- (void)onSDKError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onSDKError");
        [self.displayView endLoading];
        if (self.onConnectErrorBlock) {
            self.onConnectErrorBlock();
        }
    });
}

#pragma mark - AlivcLivePusherNetworkDelegate
- (void)onNetworkPoor:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onNetworkPoor");
        if (self.onConnectionPoorBlock) {
            self.onConnectionPoorBlock();
        }
    });
}


- (void)onConnectionLost:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onConnectionLost");
        if (self.onConnectionLostBlock) {
            self.onConnectionLostBlock();
        }
    });
}

- (void)onConnectRecovery:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onConnectRecovery");
        if (self.onConnectionRecoveryBlock) {
            self.onConnectionRecoveryBlock();
        }
    });
}


- (void)onConnectFail:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onConnectFail");
        [self.displayView endLoading];
        if (self.onConnectErrorBlock) {
            self.onConnectErrorBlock();
        }
        [AVAlertController showWithTitle:nil message:@"直播中断，您可以检查网络连接后再次直播" cancelTitle:@"取消" okTitle:@"重试" onCompleted:^(BOOL isCancel) {
            if (!isCancel) {
                [self restart];
            }
        }];
    });
}

- (void)onReconnectStart:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onReconnectStart");
        [self.displayView startLoading];
        if (self.onReconnectStartBlock) {
            self.onReconnectStartBlock();
        }
    });
}

- (void)onReconnectSuccess:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onReconnectSuccess");
        [self.displayView endLoading];
        if (self.onReconnectSuccessBlock) {
            self.onReconnectSuccessBlock();
        }
    });
}

- (void)onReconnectError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onReconnectError");
        [self.displayView endLoading];
        if (self.onReconnectErrorBlock) {
            self.onReconnectErrorBlock();
        }
        [AVAlertController showWithTitle:nil message:@"直播中断，您可以检查网络连接后再次直播" cancelTitle:@"取消" okTitle:@"重试" onCompleted:^(BOOL isCancel) {
            if (!isCancel) {
                [self restart];
            }
        }];
    });
}

- (void)onSendDataTimeout:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onSendDataTimeout");
    });
}

- (NSString *)onPushURLAuthenticationOverdue:(AlivcLivePusher *)pusher {
    return @"";
}

- (void)onSendSeiMessage:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onSendSeiMessage");
    });
}

#pragma mark - AlivcLivePusherCustomFilterDelegate

- (void)onCreate:(AlivcLivePusher *)pusher context:(void*)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onCreate");
    });
}

- (int)onProcess:(AlivcLivePusher *)pusher texture:(int)texture textureWidth:(int)width textureHeight:(int)height extra:(long)extra {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"LiveEvent:onProcess");
//    });
    if (self.beautyController) {
        return [self.beautyController processGLTextureWithTextureID:texture withWidth:width withHeight:height];
    }
    return texture;
}

- (BOOL)onProcessVideoSampleBuffer:(AlivcLivePusher *)pusher sampleBuffer:(AlivcLiveVideoDataSample *)sampleBuffer {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"LiveEvent:onProcessVideoSampleBuffer");
//    });
    if (self.beautyController) {
        return [self.beautyController processPixelBuffer:sampleBuffer.pixelBuffer withPushOrientation:self.pushConfig.orientation];
    }
    
    return NO;
}

- (void)onDestory:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onDestory");
    });
    [self.beautyController destroyBeautyController];
}

#pragma mark - AlivcLivePusherCustomDetectorDelegate

- (void)onCreateDetector:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onCreateDetector");
    });
}

- (long)onDetectorProcess:(AlivcLivePusher *)pusher data:(long)data w:(int)w h:(int)h rotation:(int)rotation format:(int)format extra:(long)extra {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"LiveEvent:onDetectorProcess");
//    });
    [self.beautyController detectVideoBuffer:data
                                   withWidth:w
                                  withHeight:h
                             withVideoFormat:self.pushConfig.externVideoFormat
                         withPushOrientation:self.pushConfig.orientation];
    return data;
}

- (void)onDestoryDetector:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onDestoryDetector");
    });
}


@end
