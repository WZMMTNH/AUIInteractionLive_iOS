//
//  AUILiveRoomCdnPull.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/25.
//

#import "AUILiveRoomCdnPull.h"
#import "AUIInteractionLiveSDKHeader.h"
#import "AUIFoundation.h"
#import "AUILiveBlockButton.h"
#import <Masonry/Masonry.h>

@interface AUILiveRoomCdnPull () <AVPDelegate>

@property (strong, nonatomic) AliPlayer *player;

@property (strong, nonatomic) AUILiveBlockButton *infoButton;

@property (assign, nonatomic) NSUInteger retryCount;

@end

@implementation AUILiveRoomCdnPull

@synthesize displayView = _displayView;

- (AUILiveRoomLiveDisplayView *)displayView {
    if (!_displayView) {
        _displayView = [[AUILiveRoomLiveDisplayView alloc] initWithFrame:CGRectZero];
        _displayView.nickName = @"主播";
    }
    return _displayView;
}

- (AUILiveBlockButton *)infoButton {
    if (!_infoButton) {
        _infoButton = [[AUILiveBlockButton alloc] initWithFrame:self.displayView.bounds];
        [_infoButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _infoButton.titleLabel.font = AVGetRegularFont(14);
        _infoButton.titleLabel.numberOfLines = 0;
        _infoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.displayView addSubview:_infoButton];
        [_infoButton mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.edges.equalTo(self.displayView);
        }];
        
        __weak typeof(self) weakSelf = self;
        _infoButton.clickBlock = ^(AUILiveBlockButton * _Nonnull sender) {
            [weakSelf start];
        };
    }
    return _infoButton;
}

#pragma mark - live play

- (void)prepare {
    AVPConfig *config = [[AVPConfig alloc] init];
    config.networkTimeout = 5000;
    config.networkRetryCount = 5;
    
    _player = [[AliPlayer alloc] init];
    [_player setConfig:config];
    _player.delegate = self;
    _player.autoPlay = YES;
    [_player setPlayerView:self.displayView.renderView];
}

- (BOOL)start {
    self.infoButton.hidden = YES;
    [_player stop];
    if (self.liveInfoModel.mode == AUIInteractionLiveModeBase) {
        if (self.liveInfoModel.pull_url_info.rtmp_url.length > 0) {
            [_player setUrlSource:[[AVPUrlSource alloc] urlWithString:self.liveInfoModel.pull_url_info.rtmp_url]];
            if (self.onPrepareStartBlock) {
                self.onPrepareStartBlock();
            }
            [_player prepare];
            return YES;
        }
    }
    if (self.liveInfoModel.mode == AUIInteractionLiveModeLinkMic) {
        if (self.liveInfoModel.link_info.cdn_pull_info.rtmp_url.length > 0) {
            [_player setUrlSource:[[AVPUrlSource alloc] urlWithString:self.liveInfoModel.link_info.cdn_pull_info.rtmp_url]];
            if (self.onPrepareStartBlock) {
                self.onPrepareStartBlock();
            }
            [_player prepare];
            return YES;
        }
    }
    [AVAlertController show:@"播放失败，缺少播放地址"];
    return NO;
}

- (void)destory {
    [_player stop];
    [_player clearScreen];
    _player.playerView = nil;
    [_player destroy];
    _player = nil;
}

#pragma mark - AVPDelegate
-(void)onPlayerEvent:(AliPlayer*)player eventType:(AVPEventType)eventType {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (eventType) {
            case AVPEventPrepareDone: {
                if (self.onPrepareDoneBlock) {
                    self.onPrepareDoneBlock();
                }
                self.retryCount = 0;
            }
                break;
            case AVPEventLoadingStart: {
                if (self.onLoadingStartBlock) {
                    self.onLoadingStartBlock();
                }
            }
                break;
            case AVPEventLoadingEnd: {
                if (self.onLoadingEndBlock) {
                    self.onLoadingEndBlock();
                }
            }
                break;
            case AVPEventFirstRenderedStart: {
            }
                break;
                
            default:
                break;
        }
        
    });
}

- (void)onError:(AliPlayer *)player errorModel:(AVPErrorModel *)errorModel {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.retryCount < 10) {
            if (self.onPlayErrorBlock) {
                self.onPlayErrorBlock(YES);
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self start];
            });
            self.retryCount++;
            return;
        }
        
        NSString *title = @"播放失败，可能是播放流已停止\n点击重试？";
        self.infoButton.hidden = NO;
        [self.infoButton setTitle:title forState:UIControlStateNormal];
        [self.player stop];
        
        if (self.onPlayErrorBlock) {
            self.onPlayErrorBlock(NO);
        }
//        [AVAlertController showWithTitle:nil message:@"播放失败，是否重试？" needCancel:YES onCompleted:^(BOOL isCancel) {
//            if (!isCancel) {
//                [self start];
//            }
//            else {
//                [self destory];
//            }
//        }];
    });
}

@end
