//
//  AUILiveRoomRtcPull.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/25.
//

#import "AUILiveRoomRtcPull.h"
#import "AUIInteractionLiveSDKHeader.h"
#import "AUIFoundation.h"
#import "AUILiveBlockButton.h"
#import <Masonry/Masonry.h>

@interface AUILiveRoomRtcPull () <AliLivePlayerDelegate>

@property (strong, nonatomic) AlivcLivePlayer *player;

@property (strong, nonatomic) AUILiveBlockButton *infoButton;

@end

@implementation AUILiveRoomRtcPull

@synthesize displayView = _displayView;

- (AUILiveRoomLiveDisplayView *)displayView {
    if (!_displayView) {
        _displayView = [[AUILiveRoomLiveDisplayView alloc] initWithFrame:CGRectZero];
    }
    return _displayView;
}

- (AUILiveBlockButton *)infoButton {
    if (!_infoButton) {
        _infoButton = [[AUILiveBlockButton alloc] initWithFrame:self.displayView.bounds];
        [_infoButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _infoButton.titleLabel.font = AVGetRegularFont(10);
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
    AlivcLivePlayConfig *playConfig = [[AlivcLivePlayConfig alloc] init];
    playConfig.renderMode = AlivcLivePlayRenderModeFill;
    
    _player = [[AlivcLivePlayer alloc] init];
    [_player setLivePlayerDelegate:self];
    [_player setPlayView:self.displayView.renderView  playCofig:playConfig];
    self.displayView.nickName = self.pullInfo.userNick;
}

- (BOOL)start {
    self.infoButton.hidden = NO;
    [self.infoButton setTitle:@"连接中" forState:UIControlStateNormal];
    self.infoButton.enabled = NO;
    [_player stopPlay];
    if (self.pullInfo.rtcPullUrl.length > 0) {
        [_player startPlayWithURL:self.pullInfo.rtcPullUrl];
        return YES;
    }
    [AVAlertController show:@"播放失败，缺少播放地址"];
    return NO;
}

- (void)destory {
    [_player stopPlay];
    _player = nil;
}

#pragma mark - AliLivePlayerDelegate

- (void)onError:(AlivcLivePlayer *)player code:(AlivcLivePlayerError)code message:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *title = msg ?: @"未知错误\n点击重试？";
        if (code == AlivcLivePlayErrorStreamNotFound) {
            title = [NSString stringWithFormat:@"找不到播放流\n点击重试？"];
        } else if (code == AlivcLivePlayErrorStreamStopped) {
            title = [NSString stringWithFormat:@"播放流已停止\n点击重试？"];
        }
        self.infoButton.hidden = NO;
        [self.infoButton setTitle:title forState:UIControlStateNormal];
        self.infoButton.enabled = YES;
        [self.player stopPlay];
        
        if (self.onPlayErrorBlock) {
            self.onPlayErrorBlock();
        }
    });
}

- (void)onPlayStarted:(AlivcLivePlayer *)player {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.infoButton.hidden = YES;
    });
}

- (void)onPlayStoped:(AlivcLivePlayer *)player {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.infoButton.hidden = YES;
    });
}

@end
