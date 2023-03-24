//
//  AUILiveRoomAudienceViewController.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/2.
//

#import "AUILiveRoomAudienceViewController.h"
#import "AUIFoundation.h"
#import "AUIRoomMacro.h"

#import "AUILiveRoomNoticeButton.h"
#import "AUILiveRoomMemberButton.h"
#import "AUILiveRoomInfoView.h"
#import "AUILiveRoomCommentView.h"
#import "AUILiveRoomAudienceBottomView.h"
#import "AUILiveRoomAudiencePrestartView.h"
#import "AUILiveRoomFinishView.h"
#import "AUIRoomDisplayView.h"
#import "AUILiveRoomLivingContainerView.h"
#import "AUILiveRoomAudienceLinkMicButton.h"

#import "AUIRoomBaseLiveManager.h"
#import "AUIRoomInteractionLiveManager.h"
#import "AUIRoomAccount.h"
#import "AUIRoomDeviceAuth.h"
#import "AUILiveRoomActionManager.h"

@interface AUILiveRoomAudienceViewController () <AVUIViewControllerInteractivePodGesture>

@property (strong, nonatomic) AVBlockButton* exitButton;

@property (strong, nonatomic) AUIRoomDisplayLayoutView *liveDisplayView;

@property (strong, nonatomic) AUILiveRoomLivingContainerView *livingContainerView;
@property (strong, nonatomic) AUILiveRoomInfoView *liveInfoView;
@property (strong, nonatomic) AUILiveRoomNoticeButton *noticeButton;
@property (strong, nonatomic) AUILiveRoomMemberButton *membersButton;
@property (strong, nonatomic) AUILiveRoomCommentView *liveCommentView;
@property (strong, nonatomic) AUILiveRoomAudienceBottomView *bottomView;

@property (strong, nonatomic) AUILiveRoomAudiencePrestartView *livePrestartView;
@property (strong, nonatomic) AUILiveRoomFinishView *liveFinishView;

@property (strong, nonatomic) AUIRoomLiveService *liveService;
@property (strong, nonatomic) id<AUIRoomLiveManagerAudienceProtocol> liveManager;

@property (strong, nonatomic) AUILiveRoomAudienceLinkMicButton* linkMicButton;

@end

@implementation AUILiveRoomAudienceViewController

#pragma mark -- UI控件加载

- (AUIRoomDisplayLayoutView *)liveDisplayView {
    if (!_liveDisplayView) {
        _liveDisplayView = [[AUIRoomDisplayLayoutView alloc] initWithFrame:self.view.bounds];
        _liveDisplayView.resolution = CGSizeMake(720, 1280);
        [self.view addSubview:_liveDisplayView];
    }
    return _liveDisplayView;
}

- (AVBlockButton *)exitButton {
    if (!_exitButton) {
        AVBlockButton* button = [[AVBlockButton alloc] initWithFrame:CGRectMake(self.view.av_right - 16 - 24, AVSafeTop + 10, 24, 24)];
        button.layer.cornerRadius = 12;
        button.layer.masksToBounds = YES;
        [button setImage:AUIRoomGetCommonImage(@"ic_living_close") forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4] forState:UIControlStateNormal];
        [self.view addSubview:button];
        
        __weak typeof(self) weakSelf = self;
        button.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            
            void (^destroyBlock)(void) = ^{
                if ([weakSelf linkMicManager].isApplyingLinkMic) {
                    [[weakSelf linkMicManager] cancelApplyLinkMic:nil];
                }
                [weakSelf.liveManager destoryPullPlayer];
                [weakSelf.liveService leaveRoom:nil];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            };
            
            if (weakSelf.liveService.liveInfoModel.status == AUIRoomLiveStatusLiving && [weakSelf linkMicManager] && [weakSelf linkMicManager].isJoinedLinkMic) {
                [AVAlertController showWithTitle:@"是否结束与主播连麦，并退出直播间？" message:@"" needCancel:YES onCompleted:^(BOOL isCanced) {
                    if (!isCanced) {
                        destroyBlock();
                    }
                }];
            }
            else {
                destroyBlock();
            }
        };
        _exitButton = button;
    }
    return _exitButton;
}

- (AUILiveRoomMemberButton *)membersButton {
    if (!_membersButton) {
        _membersButton = [[AUILiveRoomMemberButton alloc] initWithFrame:CGRectMake(self.view.av_right - 48 - 55, AVSafeTop + 10, 55, 24)];
        _membersButton.layer.cornerRadius = 12;
        _membersButton.layer.masksToBounds = YES;
        [_membersButton updateMemberCount:self.liveService.pv];
        [self.view addSubview:_membersButton];
    }
    return _membersButton;
}

- (AUILiveRoomInfoView *)liveInfoView {
    if(!_liveInfoView) {
        AUILiveRoomInfoView* view = [[AUILiveRoomInfoView alloc] initWithFrame:CGRectMake(16, AVSafeTop + 2, 190, 40) withModel:self.liveService.liveInfoModel];
        [self.view addSubview:view];
        view.layer.cornerRadius = 20;
        view.layer.masksToBounds = YES;
        _liveInfoView = view;
        
        __weak typeof(self) weakSelf = self;
        _liveInfoView.onFollowButtonClickedBlock = ^(AUILiveRoomInfoView * _Nonnull sender, AVBlockButton * _Nonnull followButton) {
            if (AUILiveRoomActionManager.defaultManager.followAnchorAction) {
                AUIRoomUser *anchor = [AUIRoomUser new];
                anchor.userId = weakSelf.liveService.liveInfoModel.anchor_id;
                anchor.nickName = weakSelf.liveService.liveInfoModel.anchor_nickName;
                anchor.avatar = weakSelf.liveService.liveInfoModel.anchor_avatar;
                AUILiveRoomActionManager.defaultManager.followAnchorAction(anchor, followButton.selected, weakSelf, ^(BOOL success) {
                    if (success) {
                        followButton.selected = !followButton.selected;
                    }
                });
            }
        };
    }
    return _liveInfoView;
}

- (AUILiveRoomNoticeButton *)noticeButton {
    if (!_noticeButton) {
        AUILiveRoomNoticeButton* button = [[AUILiveRoomNoticeButton alloc] initWithFrame:CGRectMake(16, AVSafeTop + 52, 0, 0)];
        [self.view addSubview:button];
        button.noticeContent = self.liveService.notice;

        _noticeButton = button;
    }
    return _noticeButton;
}

- (AUILiveRoomLivingContainerView *)livingContainerView {
    if (!_livingContainerView) {
        _livingContainerView = [[AUILiveRoomLivingContainerView alloc] initWithFrame:self.view.bounds];
        _livingContainerView.hidden = YES;
        [self.view addSubview:_livingContainerView];
    }
    return _livingContainerView;
}

- (AUILiveRoomCommentView *)liveCommentView {
    if(!_liveCommentView){
        _liveCommentView = [[AUILiveRoomCommentView alloc] initWithFrame:CGRectMake(16, self.livingContainerView.av_height - AVSafeBottom - 44 - 214 - 8, 240, 214)];
        [self.livingContainerView addSubview:_liveCommentView];
    }
    return _liveCommentView;
}

- (AUILiveRoomAudienceLinkMicButton *)linkMicButton {
    if (self.liveService.liveInfoModel.mode != AUIRoomLiveModeLinkMic) {
        return nil;
    }
    if (!_linkMicButton) {
        _linkMicButton = [[AUILiveRoomAudienceLinkMicButton alloc] initWithFrame:CGRectMake(self.livingContainerView.av_right - 16, self.livingContainerView.av_height - AVSafeBottom - 44 - 32 - 20, 0, 32)];
        [self.livingContainerView addSubview:_linkMicButton];
        
        __weak typeof(self) weakSelf = self;
        _linkMicButton.onApplyBlock = ^(AUILiveRoomAudienceLinkMicButton * _Nonnull sender) {
            [weakSelf applyLinkMic];
        };
        _linkMicButton.onApplyCancelBlock = ^(AUILiveRoomAudienceLinkMicButton * _Nonnull sender) {
            [weakSelf cancelApplyLinkMic];
        };
        _linkMicButton.onLeaveBlock = ^(AUILiveRoomAudienceLinkMicButton * _Nonnull sender) {
            [weakSelf leaveLinkMic];
        };
        _linkMicButton.onSwitchAudioBlock = ^(AUILiveRoomAudienceLinkMicButton * _Nonnull sender, BOOL isOn) {
            [weakSelf switchAudio:isOn];
        };
        _linkMicButton.onSwitchVideoBlock = ^(AUILiveRoomAudienceLinkMicButton * _Nonnull sender, BOOL isOn) {
            [weakSelf switchVideo:isOn];
        };
        _linkMicButton.onSwitchCameraBlock = ^(AUILiveRoomAudienceLinkMicButton * _Nonnull sender) {
            [weakSelf switchCamera];
        };
    }
    return _linkMicButton;
}

- (AUILiveRoomAudienceBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[AUILiveRoomAudienceBottomView alloc] initWithFrame:CGRectMake(0, self.livingContainerView.av_height - AVSafeBottom - 50, self.livingContainerView.av_width, AVSafeBottom + 50) linkMic:NO];
        [self.livingContainerView addSubview:_bottomView];
        
        __weak typeof(self) weakSelf = self;
        _bottomView.onLikeButtonClickedBlock = ^(AUILiveRoomAudienceBottomView * _Nonnull sender) {
            [weakSelf.liveService sendLike];
        };
        _bottomView.onShareButtonClickedBlock = ^(AUILiveRoomAudienceBottomView * _Nonnull sender) {
            if (AUILiveRoomActionManager.defaultManager.openShare) {
                AUILiveRoomActionManager.defaultManager.openShare(weakSelf.liveService.liveInfoModel, weakSelf, nil);
            }
        };
        _bottomView.sendCommentBlock = ^(AUILiveRoomAudienceBottomView * _Nonnull sender, NSString * _Nonnull comment) {
            [weakSelf.liveService sendComment:comment completed:nil];
        };
    }
    return _bottomView;
}

- (AUILiveRoomAudiencePrestartView *)livePrestartView {
    if (!_livePrestartView) {
        _livePrestartView = [[AUILiveRoomAudiencePrestartView alloc] initWithFrame:self.view.bounds];
        _livePrestartView.hidden = YES;
        [self.view insertSubview:_livePrestartView belowSubview:self.liveDisplayView];
    }
    return _livePrestartView;
}

- (AUILiveRoomFinishView *)liveFinishView {
    if (!_liveFinishView) {
        _liveFinishView = [[AUILiveRoomFinishView alloc] initWithFrame:self.view.bounds];
        _liveFinishView.hidden = YES;
        [self.view insertSubview:_liveFinishView aboveSubview:self.liveDisplayView];
        
        __weak typeof(self) weakSelf = self;
        _liveFinishView.onShareButtonClickedBlock = ^(AUILiveRoomFinishView * _Nonnull sender) {
            if (AUILiveRoomActionManager.defaultManager.openShare) {
                AUILiveRoomActionManager.defaultManager.openShare(weakSelf.liveService.liveInfoModel, weakSelf, nil);
            }
        };
        _liveFinishView.onLikeButtonClickedBlock = ^(AUILiveRoomFinishView * _Nonnull sender) {
            [weakSelf.liveService sendLike];
        };
        _liveFinishView.onFullScreenBlock = ^(AUILiveRoomFinishView * _Nonnull sender, BOOL fullScreen) {
            weakSelf.liveInfoView.hidden = fullScreen;
            weakSelf.membersButton.hidden = fullScreen;
            weakSelf.noticeButton.hidden = fullScreen;
            weakSelf.exitButton.hidden = fullScreen;
        };
    }
    return _liveFinishView;
}

#pragma mark - AVUIViewControllerInteractivePodGesture

- (BOOL)disableInteractivePodGesture {
    return YES;
}

#pragma mark - LifeCycle

- (void)dealloc {
    NSLog(@"dealloc:AUILiveRoomAudienceViewController");
}

- (instancetype)initWithLiveService:(AUIRoomLiveService *)liveService {
    self = [super init];
    if (self) {
        _liveService = liveService;
        
        __weak typeof(self) weakSelf = self;
        _liveService.onReceivedComment = ^(AUIRoomUser * _Nonnull sender, NSString * _Nonnull content) {
            if (content.length == 0) {
                return;
            }
            NSString *senderNick = sender.nickName;
            NSString *senderId = sender.userId;
            [weakSelf.liveCommentView insertLiveComment:content commentSenderNick:senderNick commentSenderID:senderId presentedCompulsorily:NO];
        };
        _liveService.onReceivedStartLive = ^(AUIRoomUser * _Nonnull sender) {
            [weakSelf.liveService.liveInfoModel updateStatus:AUIRoomLiveStatusLiving];
            weakSelf.livePrestartView.hidden = YES;
            weakSelf.livingContainerView.hidden = NO;
            [weakSelf.liveManager preparePullPlayer];
            [weakSelf.liveManager startPullPlayer];
        };
        _liveService.onReceivedStopLive = ^(AUIRoomUser * _Nonnull sender) {
            [weakSelf.liveService.liveInfoModel updateStatus:AUIRoomLiveStatusFinished];
            [weakSelf.liveManager destoryPullPlayer];
            weakSelf.livePrestartView.hidden = YES;
            weakSelf.livingContainerView.hidden = YES;
            weakSelf.liveFinishView.hidden = NO;
            weakSelf.liveFinishView.vodModel = weakSelf.liveService.liveInfoModel.vod_info;
        };
        _liveService.onReceivedMuteAll = ^(AUIRoomUser * _Nonnull sender, BOOL isMuteAll) {
            weakSelf.bottomView.commentTextField.commentState = isMuteAll ?  AUILiveRoomCommentStateMute : AUILiveRoomCommentStateDefault;
        };
        _liveService.onReceivedLike = ^(AUIRoomUser * _Nonnull sender, NSInteger likeCount) {
        };
        _liveService.onReceivedNoticeUpdate = ^(AUIRoomUser * _Nonnull sender, NSString * _Nonnull notice) {
            weakSelf.noticeButton.noticeContent = notice;
            [AVToastView show:@"公告已更新" view:weakSelf.view position:AVToastViewPositionMid];
        };
        _liveService.onReceivedPV = ^(AUIRoomUser * _Nonnull sender, NSInteger pv) {
            [weakSelf.membersButton updateMemberCount:pv];
        };
        _liveService.onReceivedJoinLinkMic = ^(AUIRoomUser * _Nonnull sender, AUIRoomLiveLinkMicJoinInfoModel * _Nonnull joinInfo) {
            [weakSelf receivedJoinLinkMic:joinInfo];
        };
        _liveService.onReceivedLeaveLinkMic = ^(AUIRoomUser * _Nonnull sender, NSString * _Nonnull userId) {
            [weakSelf receivedLeaveLinkMic:userId];
        };
        _liveService.onReceivedResponseApplyLinkMic = ^(AUIRoomUser * _Nonnull sender, BOOL agree, NSString *pullUrl) {
            [weakSelf receivedApplyResult:sender.userId agree:agree];
        };
        _liveService.onReceivedMicOpened = ^(AUIRoomUser * _Nonnull sender, BOOL opened) {
            [weakSelf receivedMicOpened:sender opened:opened];
        };
        _liveService.onReceivedCameraOpened = ^(AUIRoomUser * _Nonnull sender, BOOL opened) {
            [weakSelf receivedCameraOpened:sender opened:opened];
        };
        _liveService.onReceivedOpenMic = ^(AUIRoomUser * _Nonnull sender, BOOL needOpen) {
            [weakSelf switchAudio:needOpen];
        };
        _liveService.onReceivedOpenCamera = ^(AUIRoomUser * _Nonnull sender, BOOL needOpen) {
            [weakSelf switchVideo:needOpen];
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    
    [self setupLiveManager];
    
    __weak typeof(self) weakSelf = self;
    [self.liveService enterRoom:^(BOOL success) {
        if (!weakSelf) {
            return;
        }
        if (!success) {
            [AVAlertController showWithTitle:nil message:@"进入直播间失败，请稍后重试~" needCancel:NO onCompleted:^(BOOL isCanced) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }
        else {
            [weakSelf.liveService queryMuteAll:^(BOOL success) {
                weakSelf.bottomView.commentTextField.commentState = weakSelf.liveService.isMuteAll ? AUILiveRoomCommentStateMute : AUILiveRoomCommentStateDefault;
            }];
                        
            [weakSelf.membersButton updateMemberCount:weakSelf.liveService.pv];
            if (weakSelf.liveService.liveInfoModel.status == AUIRoomLiveStatusNone) {
                weakSelf.livePrestartView.hidden = NO;
                weakSelf.livingContainerView.hidden = YES;
            }
            else if (weakSelf.liveService.liveInfoModel.status == AUIRoomLiveStatusLiving) {
                weakSelf.livePrestartView.hidden = YES;
                weakSelf.livingContainerView.hidden = NO;
                [weakSelf.liveManager preparePullPlayer];
                [weakSelf.liveManager startPullPlayer];
            }
            else if (weakSelf.liveService.liveInfoModel.status == AUIRoomLiveStatusFinished) {
                weakSelf.livePrestartView.hidden = YES;
                weakSelf.liveFinishView.hidden = NO;
                weakSelf.liveFinishView.vodModel = weakSelf.liveService.liveInfoModel.vod_info;
                weakSelf.livingContainerView.hidden = YES;
            }
            else {
                // 状态出错
            }
        }
    }];
}

- (void)setupUI {
    self.view.backgroundColor = AUIFoundationColor(@"bg_weak");
    CAGradientLayer *bgLayer = [CAGradientLayer layer];
    bgLayer.frame = self.view.bounds;
    bgLayer.colors = @[(id)[UIColor colorWithRed:0x39 / 255.0 green:0x1a / 255.0 blue:0x0f / 255.0 alpha:1.0].CGColor,(id)[UIColor colorWithRed:0x1e / 255.0 green:0x23 / 255.0 blue:0x26 / 255.0 alpha:1.0].CGColor];
    bgLayer.startPoint = CGPointMake(0, 0.5);
    bgLayer.endPoint = CGPointMake(1, 0.5);
    [self.view.layer addSublayer:bgLayer];
        
    [self liveDisplayView];
    
    [self exitButton];
    [self liveInfoView];
    [self noticeButton];
    [self membersButton];
    
    [self livingContainerView];
    [self liveCommentView];
    [self bottomView];
    [self linkMicButton];
}

#pragma mark - orientation

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - live manager

- (void)setupLiveManager {
    
    __weak typeof(self) weakSelf = self;
    
    if (self.liveService.liveInfoModel.mode == AUIRoomLiveModeLinkMic) {
        self.liveManager = [[AUIRoomInteractionLiveManagerAudience alloc] initWithLiveService:self.liveService displayView:self.liveDisplayView];
    }
    else {
        self.liveManager = [[AUIRoomBaseLiveManagerAudience alloc] initWithLiveService:self.liveService displayView:self.liveDisplayView];
    }
    self.liveManager.roomVC = self;
    [self.liveManager setupPullPlayer];
    
    
    AUIRoomInteractionLiveManagerAudience *linkMicManager = [self linkMicManager];
    if (linkMicManager) {
        linkMicManager.onNotifyApplyNotResponse = ^(AUIRoomInteractionLiveManagerAudience * _Nonnull sender) {
            [AVToastView show:@"主播未响应" view:weakSelf.view position:AVToastViewPositionMid];
        };
        if (linkMicManager.isJoinedLinkMic) {
            self.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateJoin;
            self.linkMicButton.audioOff = linkMicManager.livePusher.isMute;
            self.linkMicButton.videoOff = linkMicManager.livePusher.isPause;
        }
    }
}

#pragma mark - link mic

- (AUIRoomInteractionLiveManagerAudience *)linkMicManager {
    if ([self.liveManager isKindOfClass:AUIRoomInteractionLiveManagerAudience.class]) {
        return self.liveManager;
    }
    return nil;
}

- (void)receivedApplyResult:(NSString *)uid agree:(BOOL)agree {
    __weak typeof(self) weakSelf = self;
    
    if (![self linkMicManager].isApplyingLinkMic) {
        return;
    }
    
    if (!agree) {
        [[self linkMicManager] receivedDisagreeToLinkMic:uid completed:^(BOOL success) {
            if (success) {
                weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateInit;
                [AVToastView show:@"主播拒绝了您的连麦申请" view:weakSelf.view position:AVToastViewPositionMid];
            }
        }];
        return;
    }
    
    [AVAlertController showWithTitle:nil message:@"连麦申请通过，是否开始连麦？" needCancel:YES onCompleted:^(BOOL isCanced) {
        [[weakSelf linkMicManager] receivedAgreeToLinkMic:uid willGiveUp:isCanced completed:^(BOOL success, BOOL giveUp, NSString *message) {
            if (giveUp) {
                weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateInit;
                return;
            }
            if (success) {
                weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateJoin;
                weakSelf.linkMicButton.audioOff = [weakSelf linkMicManager].livePusher.isMute;
                weakSelf.linkMicButton.videoOff = [weakSelf linkMicManager].livePusher.isPause;
                [AVToastView show:@"连麦成功" view:weakSelf.view position:AVToastViewPositionMid];
            }
            else {
                weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateInit;
                [AVToastView show:message ?: @"连麦失败" view:weakSelf.view position:AVToastViewPositionMid];
            }
        }];
    }];
}

- (void)receivedJoinLinkMic:(AUIRoomLiveLinkMicJoinInfoModel *)joinInfo {
//    __weak typeof(self) weakSelf = self;
    [[self linkMicManager] receivedJoinLinkMic:joinInfo completed:^(BOOL success) {
        if (success) {
        }
    }];
}

- (void)receivedLeaveLinkMic:(NSString *)userId {
    __weak typeof(self) weakSelf = self;
    [[self linkMicManager] receivedLeaveLinkMic:userId completed:^(BOOL success) {
        if (success) {
            if ([userId isEqualToString:AUIRoomAccount.me.userId]) {
                weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateInit;
                [AVToastView show:@"您已被主播下麦" view:weakSelf.view position:AVToastViewPositionMid];
            }
        }
    }];
}

- (void)receivedMicOpened:(AUIRoomUser *)sender opened:(BOOL)opened {
    [[self linkMicManager] receivedMicOpened:sender opened:opened completed:nil];
}

- (void)receivedCameraOpened:(AUIRoomUser *)sender opened:(BOOL)opened {
    [[self linkMicManager] receivedCameraOpened:sender opened:opened completed:nil];
}

- (void)applyLinkMic {
    __weak typeof(self) weakSelf = self;
    
    BOOL ret = NO;
    ret = [AUIRoomDeviceAuth checkCameraAuth:^(BOOL auth) {
        if (auth) {
            [weakSelf applyLinkMic];
        }
    }];
    if (!ret) {
        return;
    }
    
    ret = [AUIRoomDeviceAuth checkMicAuth:^(BOOL auth) {
        if (auth) {
            [weakSelf applyLinkMic];
        }
    }];
    if (!ret) {
        return;
    }
    
    [AVAlertController showWithTitle:nil message:@"您确定要向主播申请连麦吗？" needCancel:YES onCompleted:^(BOOL isCanced) {
        if (isCanced) {
            return;
        }
        [[weakSelf linkMicManager] applyLinkMic:^(BOOL success) {
            if (success) {
                weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateApplyCancel;
                [AVToastView show:@"已发送连麦申请，等待主播操作" view:weakSelf.view position:AVToastViewPositionMid];
            }
            else {
                [AVToastView show:@"申请连麦失败！" view:weakSelf.view position:AVToastViewPositionMid];
            }
        }];
    }];
}

- (void)cancelApplyLinkMic {
    __weak typeof(self) weakSelf = self;
    [AVAlertController showWithTitle:nil message:@"是否取消连麦？" needCancel:YES onCompleted:^(BOOL isCanced) {
        if (isCanced) {
            return;
        }
        [[weakSelf linkMicManager] cancelApplyLinkMic:^(BOOL success) {
            if (success) {
                weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateInit;
                [AVToastView show:@"取消连麦成功" view:weakSelf.view position:AVToastViewPositionMid];
            }
        }];
    }];
}

- (void)leaveLinkMic {
    __weak typeof(self) weakSelf = self;
    [AVAlertController showWithTitle:nil message:@"是否结束与主播连麦？" needCancel:YES onCompleted:^(BOOL isCanced) {
        if (isCanced) {
            return;
        }
        [[weakSelf linkMicManager] leaveLinkMic:^(BOOL success) {
            if (success) {
                weakSelf.linkMicButton.state = AUILiveRoomAudienceLinkMicButtonStateInit;
                [AVToastView show:@"连麦已结束" view:weakSelf.view position:AVToastViewPositionMid];
            }
        }];
    }];
}

- (void)switchCamera {
    if (![self linkMicManager].isLiving) {
        return;
    }
    [[self linkMicManager].livePusher switchCamera];
}

- (void)switchVideo:(BOOL)isOn {
    if (![self linkMicManager].isLiving) {
        return;
    }

    [[self linkMicManager].livePusher pause:!isOn];
    BOOL cameraOpened = ![self linkMicManager].livePusher.isPause;
    self.linkMicButton.videoOff = !cameraOpened;
    [self.liveService sendCameraOpened:cameraOpened completed:nil];
}

- (void)switchAudio:(BOOL)isOn {
    if (![self linkMicManager].isLiving) {
        return;
    }
    
    [[self linkMicManager].livePusher mute:!isOn];
    BOOL micOpened = ![self linkMicManager].livePusher.isMute;
    [self linkMicManager].livePusher.displayView.isAudioOff = !micOpened;
    self.linkMicButton.audioOff = !micOpened;
    [self.liveService sendMicOpened:micOpened completed:nil];
}

@end
