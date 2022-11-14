//
//  AUILiveRoomPusher.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/24.
//

#import "AUILiveRoomPusher.h"
#import "AUIInteractionLiveSDKHeader.h"
#import "AUIFoundation.h"
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

- (AUILiveRoomLiveDisplayView *)displayView {
    if (!_displayView) {
        _displayView = [[AUILiveRoomLiveDisplayView alloc] initWithFrame:CGRectZero];
        _displayView.nickName = [self.liveInfoModel.anchor_id isEqualToString:AUIInteractionAccountManager.me.userId] ? @"主播" : AUIInteractionAccountManager.me.nickName;
    }
    return _displayView;
}

+ (UIImage *)pauseImage {
    static UIImage *_image = nil;
    if (!_image) {
        _image = [UIImage av_imageWithColor:UIColor.blackColor size:CGSizeMake(720, 1280)];
    }
    return _image;
}

#pragma mark - live pusher

- (void)prepare {
    
    AlivcLivePushMode pushMode = AlivcLivePushBasicMode;
    AlivcPusherPreviewDisplayMode displayMode = ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FIT;
    if (self.liveInfoModel.mode == AUIInteractionLiveModeLinkMic) {
        pushMode = AlivcLivePushInteractiveMode;
        displayMode = ALIVC_LIVE_PUSHER_PREVIEW_ASPECT_FIT;
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
    pushConfig.pauseImg = [self.class pauseImage];
    
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
}

- (void)destory {
    [_pushEngine setLiveMixTranscodingConfig:nil];
    [_pushEngine stopPush];
    [_pushEngine stopPreview];
    [_pushEngine destory];
    _pushEngine = nil;
}

- (BOOL)start {
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
    
    [AVAlertController show:@"推流失败，缺少推流地址"];
    return NO;
}

- (void)restart {
    [_pushEngine reconnectPushAsync];
}

- (void)mute:(BOOL)mute {
    if (!_pushEngine) {
        return;
    }
    [_pushEngine setMute:mute];
    _isMute = mute;
}

- (void)pause {
    if (!_pushEngine) {
        return;
    }
    
    int ret = [_pushEngine pause];
    if (ret == 0) {
        _isPause = YES;
    }
}

- (void)resume {
    if (!_pushEngine) {
        return;
    }
    int ret = [_pushEngine resume];
    if (ret == 0) {
        _isPause = NO;
    }
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
        if (self.onConnectErrorBlock) {
            self.onConnectErrorBlock();
        }
    });
}

- (void)onSDKError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onSDKError");
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
        if (self.onConnectErrorBlock) {
            self.onConnectErrorBlock();
        }
        [AVAlertController showWithTitle:nil message:@"链接失败，请检查网络状态后重试" needCancel:YES onCompleted:^(BOOL isCancel) {
            if (!isCancel) {
                [self restart];
            }
        }];
    });
}

- (void)onReconnectStart:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onReconnectStart");
        if (self.onReconnectStartBlock) {
            self.onReconnectStartBlock();
        }
    });
}

- (void)onReconnectSuccess:(AlivcLivePusher *)pusher {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onReconnectSuccess");
        if (self.onReconnectSuccessBlock) {
            self.onReconnectSuccessBlock();
        }
    });
}

- (void)onReconnectError:(AlivcLivePusher *)pusher error:(AlivcLivePushError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"LiveEvent:onReconnectError");
        if (self.onReconnectErrorBlock) {
            self.onReconnectErrorBlock();
        }
        [AVAlertController showWithTitle:nil message:@"重连失败，请检查网络状态后重试" needCancel:YES onCompleted:^(BOOL isCancel) {
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
