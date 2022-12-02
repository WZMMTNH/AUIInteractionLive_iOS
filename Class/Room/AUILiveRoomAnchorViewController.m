//
//  AUILiveRoomAnchorViewController.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/2.
//

#import "AUILiveRoomAnchorViewController.h"
#import "AUIFoundation.h"
#import "AUIInteractionLiveMacro.h"
#import <Masonry/Masonry.h>

#import "AUILiveRoomInfoView.h"
#import "AUILiveRoomPushStatusView.h"
#import "AUILiveRoomMemberButton.h"
#import "AUILiveRoomAnchorBottomView.h"
#import "AUILiveRoomMorePanel.h"
#import "AUILiveRoomCommentView.h"
#import "AUILiveRoomAnchorPrestartView.h"
#import "AUILiveRoomFinishView.h"
#import "AUILiveRoomLiveDisplayLayoutView.h"
#import "AUILiveRoomLivingContainerView.h"
#import "AUILiveRoomNoticeButton.h"
#import "AUILIveRoomNoticePanel.h"

#import "AUIInteractionAccountManager.h"
#import "AUILiveRoomBaseLiveManager.h"
#import "AUILiveRoomLinkMicManager.h"
#import "AUILiveRoomLinkMicListPanel.h"


@interface AUILiveRoomAnchorViewController () <
AVUIViewControllerInteractivePodGesture
>

@property (strong, nonatomic) AVBlockButton* exitButton;

@property (strong, nonatomic) AUILiveRoomLiveDisplayLayoutView *liveDisplayView;

@property (strong, nonatomic) AUILiveRoomLivingContainerView *livingContainerView;
@property (strong, nonatomic) AUILiveRoomInfoView *liveInfoView;
@property (strong, nonatomic) AUILiveRoomNoticeButton *noticeButton;
@property (strong, nonatomic) AUILiveRoomMemberButton *membersButton;
@property (strong, nonatomic) AUILiveRoomPushStatusView *pushStatusView;
@property (strong, nonatomic) AUILiveRoomCommentView *liveCommentView;
@property (strong, nonatomic) AUILiveRoomAnchorBottomView *bottomView;

@property (strong, nonatomic) AUILiveRoomAnchorPrestartView *livePrestartView;
@property (strong, nonatomic) AUILiveRoomFinishView *liveFinishView;


@property (strong, nonatomic) AUILiveRoomManager *roomManager;
@property (strong, nonatomic) id<AUILiveRoomLiveManagerAnchorProtocol> liveManager;

@property (strong, nonatomic) AUILiveRoomLinkMicListPanel* linkMicPanel;

@end



@implementation AUILiveRoomAnchorViewController

#pragma mark -- UI控件懒加载

- (AVBlockButton *)exitButton {
    if (!_exitButton) {
        AVBlockButton* button = [[AVBlockButton alloc] initWithFrame:CGRectMake(self.view.av_right - 16 - 24, AVSafeTop + 10, 24, 24)];
        button.layer.cornerRadius = 12;
        button.layer.masksToBounds = YES;
        [button setImage:AUIInteractionLiveGetCommonImage(@"ic_living_close") forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4] forState:UIControlStateNormal];
        [self.view addSubview:button];
        
        __weak typeof(self) weakSelf = self;
        button.clickBlock = ^(AVBlockButton * _Nonnull sender) {
            NSString *tips = @"还有观众正在路上，确定要结束直播吗？";
            if (weakSelf.roomManager.liveInfoModel.status == AUIInteractionLiveStatusFinished) {
                tips = @"确定要离开吗？";
            }
            [AVAlertController showWithTitle:tips message:@"" needCancel:YES onCompleted:^(BOOL isCanced) {
                if (!isCanced) {
                    [weakSelf.liveManager destoryLivePusher];
                    [weakSelf.roomManager finishLive:nil];
                    [weakSelf.roomManager leaveRoom:nil];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }];
        };
        _exitButton = button;
    }
    return _exitButton;
}

- (AUILiveRoomLiveDisplayLayoutView *)liveDisplayView {
    if (!_liveDisplayView) {
        _liveDisplayView = [[AUILiveRoomLiveDisplayLayoutView alloc] initWithFrame:self.view.bounds];
        _liveDisplayView.resolution = CGSizeMake(720, 1280);
        [self.view addSubview:_liveDisplayView];
    }
    return _liveDisplayView;
}

- (AUILiveRoomLivingContainerView *)livingContainerView {
    if (!_livingContainerView) {
        _livingContainerView = [[AUILiveRoomLivingContainerView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_livingContainerView];
    }
    return _livingContainerView;
}

- (AUILiveRoomMemberButton *)membersButton {
    if (!_membersButton) {
        _membersButton = [[AUILiveRoomMemberButton alloc] initWithFrame:CGRectMake(self.livingContainerView.av_right - 48 - 55, AVSafeTop + 10, 55, 24)];
        _membersButton.layer.cornerRadius = 12;
        _membersButton.layer.masksToBounds = YES;
        [_membersButton updateMemberCount:self.roomManager.pv];
        [self.livingContainerView addSubview:_membersButton];
    }
    return _membersButton;
}

- (AUILiveRoomInfoView *)liveInfoView {
    if(!_liveInfoView) {
        AUILiveRoomInfoView* view = [[AUILiveRoomInfoView alloc] initWithFrame:CGRectMake(16, AVSafeTop + 2, 150, 40) withModel:self.roomManager.liveInfoModel];
        [self.livingContainerView addSubview:view];
        view.layer.cornerRadius = 20;
        view.layer.masksToBounds = YES;
        _liveInfoView = view;
    }
    return _liveInfoView;
}


- (AUILiveRoomNoticeButton *)noticeButton {
    if (!_noticeButton) {
        AUILiveRoomNoticeButton* button = [[AUILiveRoomNoticeButton alloc] initWithFrame:CGRectMake(16, AVSafeTop + 52, 0, 0)];
        button.enableEdit = YES;
        [self.livingContainerView addSubview:button];
        button.noticeContent = self.roomManager.notice;
        
        __weak typeof(self) weakSelf = self;
        button.onEditNoticeContentBlock = ^{
            
            AUILIveRoomNoticePanel *panel = [[AUILIveRoomNoticePanel alloc] initWithFrame:CGRectMake(0, weakSelf.livingContainerView.av_height - AUILIveRoomNoticePanel.panelHeight, weakSelf.livingContainerView.av_width, AUILIveRoomNoticePanel.panelHeight)];
            panel.input = weakSelf.roomManager.notice;
            panel.onInputCompletedBlock = ^(AUILIveRoomNoticePanel *sender, NSString * _Nonnull input) {
                if ([input isEqualToString:weakSelf.roomManager.notice]) {
                    return;
                }
                AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:weakSelf.view animated:YES];
                [weakSelf.roomManager updateNotice:input?:@"" completed:^(BOOL success) {
                    if (success) {
                        loading.labelText = @"公告已更新";
                        loading.iconType = AVProgressHUDIconTypeSuccess;
                        [loading hideAnimated:YES afterDelay:1];
                        weakSelf.noticeButton.noticeContent = weakSelf.roomManager.notice;
                        [sender hide];
                    }
                    else {
                        loading.labelText = @"公告更新失败";
                        loading.iconType = AVProgressHUDIconTypeWarn;
                        [loading hideAnimated:YES afterDelay:3];
                    }
                }];
            };
            [panel showOnView:weakSelf.livingContainerView withBackgroundType:AVControllPanelBackgroundTypeModal];
            panel.bgViewOnShowing.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        };
        
        _noticeButton = button;
    }
    return _noticeButton;
}

- (AUILiveRoomPushStatusView *)pushStatusView {
    if (!_pushStatusView) {
        _pushStatusView = [[AUILiveRoomPushStatusView alloc] initWithFrame:CGRectMake(self.livingContainerView.av_width - 16 - 48, AVSafeTop + 55, 48, 16)];
        [self.livingContainerView addSubview:_pushStatusView];
    }
    return _pushStatusView;
}

- (AUILiveRoomCommentView *)liveCommentView {
    if(!_liveCommentView){
        _liveCommentView = [[AUILiveRoomCommentView alloc] initWithFrame:CGRectMake(16, self.livingContainerView.av_height - AVSafeBottom - 44 - 214 - 8, 240, 214)];
        [self.livingContainerView addSubview:_liveCommentView];
    }
    return _liveCommentView;
}

- (AUILiveRoomAnchorBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[AUILiveRoomAnchorBottomView alloc] initWithFrame:CGRectMake(0, self.livingContainerView.av_height - AVSafeBottom - 50, self.livingContainerView.av_width, AVSafeBottom + 50) linkMic:self.roomManager.liveInfoModel.mode == AUIInteractionLiveModeLinkMic];
        [self.livingContainerView addSubview:_bottomView];
        
        __weak typeof(self) weakSelf = self;
        _bottomView.onMoreButtonClickedBlock = ^(AUILiveRoomAnchorBottomView * _Nonnull sender) {
            [weakSelf openMorePanel];
        };
        _bottomView.onBeautyButtonClickedBlock = ^(AUILiveRoomAnchorBottomView * _Nonnull sender) {
            [weakSelf.liveManager.livePusher.beautyController showPanel:YES];
        };
        _bottomView.onLinkMicButtonClickedBlock = ^(AUILiveRoomAnchorBottomView * _Nonnull sender) {
            [weakSelf openLinkMicPanel:YES needJump:YES onApplyTab:NO];
        };
        _bottomView.sendCommentBlock = ^(AUILiveRoomAnchorBottomView * _Nonnull sender, NSString * _Nonnull comment) {
            [weakSelf.roomManager sendComment:comment completed:nil];
        };
    }
    return _bottomView;
}

- (AUILiveRoomAnchorPrestartView *)livePrestartView {
    if (!_livePrestartView) {
        _livePrestartView = [[AUILiveRoomAnchorPrestartView alloc] initWithFrame:self.view.bounds withModel:self.roomManager.liveInfoModel];
        _livePrestartView.hidden = YES;
        [self.view insertSubview:_livePrestartView aboveSubview:self.livingContainerView];
        
        __weak typeof(self) weakSelf = self;
        _livePrestartView.onBeautyBlock = ^(AUILiveRoomAnchorPrestartView * _Nonnull sender) {
            [weakSelf.liveManager.livePusher.beautyController showPanel:YES];
        };
        _livePrestartView.onSwitchCameraBlock = ^(AUILiveRoomAnchorPrestartView * _Nonnull sender) {
            [weakSelf.liveManager.livePusher switchCamera];
        };
        _livePrestartView.onWillStartLiveBlock = ^BOOL(AUILiveRoomAnchorPrestartView * _Nonnull sender) {
            weakSelf.exitButton.hidden = YES;
            return YES;
        };
        _livePrestartView.onStartLiveBlock = ^(AUILiveRoomAnchorPrestartView * _Nonnull sender) {
            weakSelf.exitButton.hidden = NO;
            [weakSelf startLive];
        };
    }
    return _livePrestartView;
}

- (AUILiveRoomFinishView *)liveFinishView {
    if (!_liveFinishView) {
        _liveFinishView = [[AUILiveRoomFinishView alloc] initWithFrame:self.livingContainerView.bounds];
        _liveFinishView.hidden = YES;
        _liveFinishView.hiddenReplayerButtons = YES;
        [self.livingContainerView insertSubview:_liveFinishView atIndex:0];
        
        __weak typeof(self) weakSelf = self;
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
    NSLog(@"dealloc:AUILiveRoomAnchorViewController");
}

- (instancetype)initWithManger:(AUILiveRoomManager *)manager {
    self = [super init];
    if (self) {
        _roomManager = manager;
        
        __weak typeof(self) weakSelf = self;
        _roomManager.onReceivedComment = ^(AUIInteractionLiveUser * _Nonnull sender, NSString * _Nonnull content) {
            if (content.length > 0) {
                NSString *senderNick = sender.nickName;
                NSString *senderId = sender.userId;
                [weakSelf.liveCommentView insertLiveComment:content commentSenderNick:senderNick commentSenderID:senderId presentedCompulsorily:NO];
            }
        };
        _roomManager.onReceivedMuteAll = ^(AUIInteractionLiveUser * _Nonnull sender, BOOL isMuteAll) {
            weakSelf.bottomView.commentTextField.commentState = isMuteAll ?  AUILiveRoomCommentStateMute : AUILiveRoomCommentStateDefault;
        };
        _roomManager.onReceivedLike = ^(AUIInteractionLiveUser * _Nonnull sender, NSInteger likeCount) {
        };
        _roomManager.onReceivedPV = ^(AUIInteractionLiveUser * _Nonnull sender, NSInteger pv) {
            [weakSelf.membersButton updateMemberCount:pv];
        };
        _roomManager.onReceivedApplyLinkMic = ^(AUIInteractionLiveUser * _Nonnull sender) {
            [weakSelf receiveApply:sender];
        };
        _roomManager.onReceivedCancelApplyLinkMic = ^(AUIInteractionLiveUser * _Nonnull sender) {
            [weakSelf receiveCancelApply:sender];
        };
        _roomManager.onReceivedJoinLinkMic = ^(AUIInteractionLiveUser * _Nonnull sender, AUIInteractionLiveLinkMicJoinInfoModel * _Nonnull joinInfo) {
            [weakSelf receivedJoinLinkMic:joinInfo];
        };
        _roomManager.onReceivedLeaveLinkMic = ^(AUIInteractionLiveUser * _Nonnull sender, NSString * _Nonnull userId) {
            [weakSelf receivedLeaveLinkMic:userId];
        };
        _roomManager.onReceivedMicOpened = ^(AUIInteractionLiveUser * _Nonnull sender, BOOL opened) {
            [weakSelf receivedMicOpened:sender opened:opened];
        };
        _roomManager.onReceivedCameraOpened = ^(AUIInteractionLiveUser * _Nonnull sender, BOOL opened) {
            [weakSelf receivedCameraOpened:sender opened:opened];
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
        
    if (self.roomManager.liveInfoModel.status == AUIInteractionLiveStatusNone) {
        [self showPrestartUI];
    }
    else if (self.roomManager.liveInfoModel.status == AUIInteractionLiveStatusFinished) {
        [self showFinishUI];
        self.liveFinishView.vodModel = self.roomManager.liveInfoModel.vod_info;
        self.noticeButton.enableEdit = NO;
    }
    else {
        [self showLivingUI];
    }
    
    [self setupLiveManager];
    
    __weak typeof(self) weakSelf = self;
    [self.roomManager enterRoom:^(BOOL success) {
        if (!success) {
            [AVAlertController showWithTitle:nil message:@"进入直播间失败，请稍后重试~" needCancel:NO onCompleted:^(BOOL isCanced) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }
        else {
            [weakSelf.roomManager queryMuteAll:^(BOOL success) {
                weakSelf.bottomView.commentTextField.commentState = weakSelf.roomManager.isMuteAll ? AUILiveRoomCommentStateMute : AUILiveRoomCommentStateDefault;
            }];
            
            [weakSelf.membersButton updateMemberCount:weakSelf.roomManager.pv];
            if (weakSelf.roomManager.liveInfoModel.status == AUIInteractionLiveStatusNone) {
                [weakSelf.liveManager prepareLivePusher];
            }
            else if (weakSelf.roomManager.liveInfoModel.status == AUIInteractionLiveStatusLiving) {
                [weakSelf.liveManager prepareLivePusher];
                [weakSelf.liveManager startLivePusher];
            }
            else if (weakSelf.roomManager.liveInfoModel.status == AUIInteractionLiveStatusFinished) {
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
    
    [self livingContainerView];
    [self membersButton];
    [self liveInfoView];
    [self noticeButton];
    [self pushStatusView];
    [self bottomView];
    [self liveCommentView];
    [self liveFinishView];
        
    [self exitButton];
}

- (void)showPrestartUI {
    self.livingContainerView.hidden = YES;
    self.livePrestartView.hidden = NO;
}

- (void)showLivingUI {
    self.livingContainerView.hidden = NO;
    _livePrestartView.hidden = YES;
    
    self.liveFinishView.hidden = YES;
    self.pushStatusView.hidden = NO;
    self.bottomView.hidden = NO;
    self.liveCommentView.hidden = NO;
}

- (void)showFinishUI {
    self.livingContainerView.hidden = NO;
    _livePrestartView.hidden = YES;
    
    self.liveFinishView.hidden = NO;
    self.pushStatusView.hidden = YES;
    self.bottomView.hidden = YES;
    self.liveCommentView.hidden = YES;
}

- (void)openMorePanel {
    AUILiveRoomMorePanel *morePanel = [[AUILiveRoomMorePanel alloc] initWithFrame:CGRectMake(0, 0, self.livingContainerView.av_width, 0)];
    [morePanel updateClickedSelected:AUILiveRoomMorePanelActionTypeMute selected:self.liveManager.livePusher.isMute];
    [morePanel updateClickedSelected:AUILiveRoomMorePanelActionTypeAudioOnly selected:self.liveManager.livePusher.isPause];
    [morePanel updateClickedSelected:AUILiveRoomMorePanelActionTypeCamera selected:self.liveManager.livePusher.isBackCamera];
    [morePanel updateClickedSelected:AUILiveRoomMorePanelActionTypeMirror selected:self.liveManager.livePusher.isMirror];
    [morePanel updateClickedSelected:AUILiveRoomMorePanelActionTypeBan selected:[self.roomManager isMuteAll]];
    __weak typeof(self) weakSelf = self;
    morePanel.onClickedAction = ^BOOL(AUILiveRoomMorePanel *sender, AUILiveRoomMorePanelActionType type, BOOL selected) {
        BOOL ret = selected;
        switch (type) {
            case AUILiveRoomMorePanelActionTypeMute:
            {
                ret = ![weakSelf.liveManager openLivePusherMic:selected];
            }
                break;
            case AUILiveRoomMorePanelActionTypeAudioOnly:
            {
                ret = ![weakSelf.liveManager openLivePusherCamera:selected];
            }
                break;
            case AUILiveRoomMorePanelActionTypeCamera:
            {
                [weakSelf.liveManager.livePusher switchCamera];
                ret = weakSelf.liveManager.livePusher.isBackCamera;
            }
                break;
            case AUILiveRoomMorePanelActionTypeMirror:
            {
                [weakSelf.liveManager.livePusher mirror:!selected];
                ret = weakSelf.liveManager.livePusher.isMirror;
            }
                break;
            case AUILiveRoomMorePanelActionTypeBan:
            {
                void (^completedBlock)(BOOL, NSString *, NSString *, AVProgressHUD *) = ^(BOOL success, NSString *successText, NSString *warnText, AVProgressHUD *loading) {
                    if (success) {
                        loading.labelText = successText;
                        loading.iconType = AVProgressHUDIconTypeSuccess;
                        [loading hideAnimated:YES afterDelay:1];
                    }
                    else {
                        loading.labelText = warnText;
                        loading.iconType = AVProgressHUDIconTypeWarn;
                        [loading hideAnimated:YES afterDelay:3];
                    }
                    [sender updateClickedSelected:AUILiveRoomMorePanelActionTypeBan selected:[weakSelf.roomManager isMuteAll]];
                };
                if (selected) {
                    AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:weakSelf.view animated:YES];
                    [weakSelf.roomManager cancelMuteAll:^(BOOL result) {
                        completedBlock(result, @"已取消全员禁言", @"取消全员禁言失败，请稍后再试", loading);
                    }];
                }
                else {
                    [AVAlertController showWithTitle:nil message:@"是否开启全员禁言？" needCancel:YES onCompleted:^(BOOL isCanced) {
                        if (!isCanced) {
                            AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:weakSelf.view animated:YES];
                            [weakSelf.roomManager muteAll:^(BOOL result) {
                                completedBlock(result, @"已全员禁言", @"全员禁言失败，请稍后再试", loading);
                            }];
                        }
                    }];
                }
            }
                break;
            default:
                break;
        }
        
        return ret;
    };
    [morePanel showOnView:self.livingContainerView];
    morePanel.bgViewOnShowing.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
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

#pragma mark - live & pusher

- (void)startLive {
    __weak typeof(self) weakSelf = self;
    [self.liveManager startLivePusher];
    [self.roomManager startLive:^(BOOL success) {
        NSLog(@"开始直播：%@", success ? @"成功" : @"失败");
        if (success) {
            [weakSelf showLivingUI];
            [weakSelf.livePrestartView removeFromSuperview];
            weakSelf.livePrestartView = nil;
            return;
        }
        
        [AVToastView show:@"开始直播失败了" view:weakSelf.view position:AVToastViewPositionMid];
        [weakSelf.livePrestartView restore];
        [weakSelf.liveManager stopLivePusher];
    }];
}

- (void)setupLiveManager {
    
    __weak typeof(self) weakSelf = self;
    
    if (self.roomManager.liveInfoModel.mode == AUIInteractionLiveModeLinkMic) {
        self.liveManager = [[AUILiveRoomLinkMicManagerAnchor alloc] initWithRoomManager:self.roomManager displayView:self.liveDisplayView];
    }
    else {
        self.liveManager = [[AUILiveRoomBaseLiveManagerAnchor alloc] initWithRoomManager:self.roomManager displayView:self.liveDisplayView];
    }
    
    self.liveManager.onStartedBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusFluent;
    };
    self.liveManager.onRestartBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusFluent;
    };
    self.liveManager.onConnectionPoorBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusStuttering;
    };
    self.liveManager.onConnectionLostBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusBrokenOff;
    };
    self.liveManager.onConnectionRecoveryBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusFluent;
    };
    self.liveManager.onConnectErrorBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusBrokenOff;
    };
    self.liveManager.onReconnectStartBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusBrokenOff;
    };
    self.liveManager.onReconnectSuccessBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusFluent;
    };
    self.liveManager.onReconnectErrorBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusBrokenOff;
    };
    self.liveManager.roomVC = self;
    [self.liveManager setupLivePusher];
    self.liveManager.livePusher.beautyController = [[AUILiveRoomBeautyController alloc] initWithPresentView:self.view contextMode:self.roomManager.liveInfoModel.mode == AUIInteractionLiveModeLinkMic];
    
    //
    AUILiveRoomLinkMicManagerAnchor *linkMicManager = [self linkMicManager];
    if (linkMicManager) {
        linkMicManager.applyListChangedBlock = ^(AUILiveRoomLinkMicManagerAnchor * _Nonnull sender) {
            [weakSelf.bottomView updateLinkMicNumber:sender.currentApplyList.count];
        };
        [linkMicManager reportLinkMicJoinList:nil];
    }
}

#pragma mark - link mic

- (AUILiveRoomLinkMicManagerAnchor *)linkMicManager {
    if ([self.liveManager isKindOfClass:AUILiveRoomLinkMicManagerAnchor.class]) {
        return self.liveManager;
    }
    return nil;
}

- (void)receiveApply:(AUIInteractionLiveUser *)sender {
    __weak typeof(self) weakSelf = self;
    if (![[self linkMicManager] checkCanLinkMic]) {
        // 超过最大连麦数，直接拒绝
        [[self linkMicManager] responseApplyLinkMic:sender agree:NO force:YES completed:^(BOOL success) {
            
        }];
        return;
    }
    
    [[self linkMicManager] receiveApplyLinkMic:sender completed:^(BOOL success) {
        if (success) {
            [weakSelf openLinkMicPanel:YES needJump:YES onApplyTab:YES];
        }
    }];
}

- (void)receiveCancelApply:(AUIInteractionLiveUser *)sender {
    __weak typeof(self) weakSelf = self;
    [[self linkMicManager] receiveCancelApplyLinkMic:sender completed:^(BOOL success) {
        if (success) {
            [weakSelf.linkMicPanel reload];
        }
    }];
}

- (void)receivedJoinLinkMic:(AUIInteractionLiveLinkMicJoinInfoModel *)joinInfo {
    __weak typeof(self) weakSelf = self;
    [[self linkMicManager] receivedJoinLinkMic:joinInfo completed:^(BOOL success) {
        if (success) {
            [weakSelf.linkMicPanel reload];
        }
    }];
}

- (void)receivedLeaveLinkMic:(NSString *)userId {
    __weak typeof(self) weakSelf = self;
    [[self linkMicManager] receivedLeaveLinkMic:userId completed:^(BOOL success) {
        if (success) {
            [weakSelf.linkMicPanel reload];
        }
    }];
}

- (void)receivedMicOpened:(AUIInteractionLiveUser *)sender opened:(BOOL)opened {
    __weak typeof(self) weakSelf = self;
    [[self linkMicManager] receivedMicOpened:sender opened:opened completed:^(BOOL success) {
        if (success) {
            [weakSelf openLinkMicPanel:NO needJump:NO onApplyTab:NO];
        }
    }];
}

- (void)receivedCameraOpened:(AUIInteractionLiveUser *)sender opened:(BOOL)opened {
    __weak typeof(self) weakSelf = self;
    [[self linkMicManager] receivedCameraOpened:sender opened:opened completed:^(BOOL success) {
        if (success) {
            [weakSelf openLinkMicPanel:NO needJump:NO onApplyTab:NO];
        }
    }];
}

- (void)openLinkMicPanel:(BOOL)open needJump:(BOOL)jump onApplyTab:(BOOL)applyTab {
    
    if (![self linkMicManager].isLiving) {
        return;
    }
    
    AUILiveRoomLinkMicItemType tab = applyTab ? AUILiveRoomLinkMicItemTypeApply : AUILiveRoomLinkMicItemTypeJoined;
    if (self.linkMicPanel) {
        if (self.linkMicPanel.tabType == tab) {
            [self.linkMicPanel reload];
            return;
        }
        if (jump) {
            self.linkMicPanel.tabType = tab;
        }
        return;
    }
    if (open) {
        __weak typeof(self) weakSelf = self;
        AUILiveRoomLinkMicListPanel *panel = [[AUILiveRoomLinkMicListPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.av_width, 0) withManager:[self linkMicManager]];
        [panel showOnView:self.view];
        panel.bgViewOnShowing.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        panel.onShowChanged = ^(AVBaseControllPanel * _Nonnull sender) {
            if (!weakSelf.linkMicPanel.isShowing) {
                weakSelf.linkMicPanel = nil;
            }
        };
        weakSelf.linkMicPanel = panel;
        weakSelf.linkMicPanel.tabType = tab;
    }
}

@end
