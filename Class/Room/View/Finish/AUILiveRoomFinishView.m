//
//  AUILiveRoomFinishView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/8.
//

#import "AUILiveRoomFinishView.h"
#import "AUIFoundation.h"
#import "AUIInteractionLiveMacro.h"
#import "AUILiveRoomVodPlay.h"

@interface AUILiveRoomFinishView ()

@property (nonatomic, strong) UILabel* infoLabel;
@property (nonatomic, strong) AVBlockButton *replayBtn;

@property (nonatomic, strong) AUILiveRoomVodPlay *player;

@end

@implementation AUILiveRoomFinishView

- (void)dealloc {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.av_height - 56) / 2.0, self.av_width, 22)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"直播已结束～";
        label.font = AVGetRegularFont(16);
        label.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        [self addSubview:label];
        self.infoLabel = label;
        
        AVBlockButton *replayBtn = [[AVBlockButton alloc] initWithFrame:CGRectMake(0, label.av_bottom, self.av_width, 22 + 12 * 2)];
        replayBtn.titleLabel.font = AVGetRegularFont(16);
        [replayBtn setTitleColor:[UIColor av_colorWithHexString:@"#FCFCFD"] forState:UIControlStateNormal];
        [replayBtn setImage:AUIInteractionLiveGetCommonImage(@"ic_living_playback") forState:UIControlStateNormal];
        [replayBtn setTitle:@"回放" forState:UIControlStateNormal];
        [replayBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
        [self addSubview:replayBtn];
        _replayBtn = replayBtn;
        
        __weak typeof(self) weakSelf = self;
        replayBtn.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            [weakSelf startToPlay];
        };
    }
    return self;
}

- (void)setVodModel:(AUIInteractionLiveVodInfoModel *)vodModel {
    _vodModel = vodModel;
    self.replayBtn.hidden = !_vodModel.isValid;
}

- (void)setHiddenReplayerButtons:(BOOL)hiddenReplayerButtons {
    _hiddenReplayerButtons = hiddenReplayerButtons;
    self.player.hiddenButtons = _hiddenReplayerButtons;
}

- (void)startToPlay {
    self.infoLabel.hidden = YES;
    self.replayBtn.hidden = YES;
    self.player = [[AUILiveRoomVodPlay alloc] initWithFrame:self.bounds];
    self.player.hiddenButtons = self.hiddenReplayerButtons;
    __weak typeof(self) weakSelf = self;
    self.player.onLikeButtonClickedBlock = ^(AUILiveRoomVodPlay * _Nonnull sender) {
        if (weakSelf.onLikeButtonClickedBlock) {
            weakSelf.onLikeButtonClickedBlock(weakSelf);
        }
    };
    self.player.onShareButtonClickedBlock = ^(AUILiveRoomVodPlay * _Nonnull sender) {
        if (weakSelf.onShareButtonClickedBlock) {
            weakSelf.onShareButtonClickedBlock(weakSelf);
        }
    };
    self.player.onFullScreenBlock = ^(AUILiveRoomVodPlay * _Nonnull sender, BOOL fullScreen) {
        if (weakSelf.onFullScreenBlock) {
            weakSelf.onFullScreenBlock(weakSelf, fullScreen);
        }
    };
    [self addSubview:self.player];
    
    self.player.vodInfoModel = self.vodModel;
    [self.player start];
}

@end
