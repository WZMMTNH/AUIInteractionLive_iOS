//
//  AUILiveRoomFinishView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/8.
//

#import "AUILiveRoomFinishView.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"
#import "AUIRoomVodPlayer.h"
#import "AUILiveRoomLikeButton.h"

@interface AUILiveRoomFinishView ()

@property (nonatomic, strong) UILabel* infoLabel;
@property (nonatomic, strong) AVBlockButton *replayBtn;

@property (nonatomic, strong) AUIRoomVodPlayer *player;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) AUILiveRoomLikeButton* likeButton;

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
        [replayBtn setImage:AUIRoomGetCommonImage(@"ic_living_playback") forState:UIControlStateNormal];
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

- (void)setVodModel:(AUIRoomLiveVodInfoModel *)vodModel {
    _vodModel = vodModel;
    self.replayBtn.hidden = !_vodModel.isValid;
}

- (void)startToPlay {
    self.infoLabel.hidden = YES;
    self.replayBtn.hidden = YES;
    
    self.player = [[AUIRoomVodPlayer alloc] initWithFrame:self.bounds];
    __weak typeof(self) weakSelf = self;
    self.player.onFullScreenBlock = ^(AUIRoomVodPlayer * _Nonnull sender, BOOL fullScreen) {
        weakSelf.shareButton.hidden = fullScreen;
        weakSelf.likeButton.hidden = fullScreen;
        if (weakSelf.onFullScreenBlock) {
            weakSelf.onFullScreenBlock(weakSelf, fullScreen);
        }
    };
    [self addSubview:self.player];
    
    self.player.vodInfoModel = self.vodModel;
    [self.player start];
    
    if (!self.isAnchor) {
        AUILiveRoomLikeButton *likeButton = [[AUILiveRoomLikeButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        [likeButton setImage:AUIRoomGetCommonImage(@"ic_living_bottom_like") forState:UIControlStateNormal];
        likeButton.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
        [likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        likeButton.layer.masksToBounds = YES;
        likeButton.layer.cornerRadius = 18;
        [self addSubview:likeButton];
        self.likeButton = likeButton;
        
        UIButton* shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        [shareButton setImage:AUIRoomGetCommonImage(@"ic_living_bottom_share") forState:UIControlStateNormal];
        shareButton.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
        [shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        shareButton.layer.masksToBounds = YES;
        shareButton.layer.cornerRadius = 18;
        [self addSubview:shareButton];
        self.shareButton = shareButton;
        
        self.likeButton.frame = CGRectMake(self.av_width - 36 - 16, self.av_height - AVSafeBottom - 56 - 4 - 36, 36, 36);
        self.shareButton.frame = CGRectMake(self.likeButton.av_left - 36 - 12, self.likeButton.av_top, 36, 36);
    }
}

- (void)likeButtonAction:(UIButton *)sender {
    if (self.onLikeButtonClickedBlock) {
        self.onLikeButtonClickedBlock(self);
    }
}

- (void)shareButtonAction:(UIButton *)sender {
    if (self.onShareButtonClickedBlock) {
        self.onShareButtonClickedBlock(self);
    }
}


@end
