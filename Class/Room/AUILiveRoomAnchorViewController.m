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
#import "AUILiveBlockButton.h"
#import "AUILiveDetailButton.h"
#import "AUILiveRoomMemberButton.h"
#import "AUILiveRoomAnchorBottomView.h"
#import "AUILiveRoomMorePanel.h"
#import "AUILiveRoomCommentView.h"
#import "AUILiveRoomLoadingIndicatorView.h"
#import "AUILiveRoomAnchorPrestartView.h"
#import "AUILiveRoomFinishView.h"
#import "AUILiveRoomLiveDisplayLayoutView.h"
#import "AUILiveRoomLivingContainerView.h"

#import "AUIInteractionAccountManager.h"
#import "AUILiveRoomBaseLiveManager.h"
#import "AUILiveRoomLinkMicManager.h"
#import "AUILiveRoomLinkMicListPanel.h"


@interface AUILiveRoomAnchorViewController () <
AVUIViewControllerInteractivePodGesture,
AUILiveRoomAnchorPrestartViewDelegate,
AUILiveRoomAnchorBottomViewDelegate
>

@property (strong, nonatomic) AUILiveBlockButton* exitButton;

@property (strong, nonatomic) AUILiveRoomLiveDisplayLayoutView *liveDisplayView;

@property (strong, nonatomic) AUILiveRoomLivingContainerView *livingContainerView;
@property (strong, nonatomic) AUILiveRoomInfoView *liveInfoView;
@property (strong, nonatomic) AUILiveDetailButton *noticeButton;
@property (strong, nonatomic) AUILiveRoomMemberButton *membersButton;
@property (strong, nonatomic) AUILiveRoomPushStatusView *pushStatusView;
@property (strong, nonatomic) AUILiveRoomCommentView *liveCommentView;
@property (strong, nonatomic) AUILiveRoomAnchorBottomView *bottomView;
@property (strong, nonatomic) AUILiveRoomLoadingIndicatorView *pushLoadingIndicator;

@property (strong, nonatomic) AUILiveRoomAnchorPrestartView *livePrestartView;
@property (strong, nonatomic) AUILiveRoomFinishView *liveFinishView;


@property (strong, nonatomic) AUILiveRoomManager *roomManager;
@property (strong, nonatomic) id<AUILiveRoomLiveManagerAnchorProtocol> liveManager;

@property (strong, nonatomic) AUILiveBlockButton* linkMicButton;
@property (strong, nonatomic) AUILiveRoomLinkMicListPanel* linkMicPanel;

@end



@implementation AUILiveRoomAnchorViewController

#pragma mark -- UI控件懒加载

- (AUILiveBlockButton *)exitButton {
    if (!_exitButton) {
        AUILiveBlockButton* button = [[AUILiveBlockButton alloc] init];
        [self.view addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).with.offset(10);
                make.right.equalTo(self.view.mas_safeAreaLayoutGuideRight).with.offset(-10);
            } else {
                make.top.equalTo(self.view).with.offset(10);
                make.right.equalTo(self.view.mas_right).with.offset(-10);
            }
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(30);
        }];
        [button setBackgroundImage:AUIInteractionLiveGetImage(@"icon-exit") forState:UIControlStateNormal];
        [button setAdjustsImageWhenHighlighted:NO];
        
        __weak typeof(self) weakSelf = self;
        button.clickBlock = ^(AUILiveBlockButton * _Nonnull sender) {
            [AVAlertController showWithTitle:@"提示" message:@"还有观众正在路上，确定要结束直播吗？" needCancel:YES onCompleted:^(BOOL isCanced) {
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
        _liveDisplayView.contentAreaInsets = UIEdgeInsetsMake(AVSafeTop+56+20, 0, AVSafeBottom+64+30, 0);
        _liveDisplayView.resolution = CGSizeMake(720, 1280);
        [self.view addSubview:_liveDisplayView];
        [_liveDisplayView mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _liveDisplayView;
}

- (AUILiveRoomLivingContainerView *)livingContainerView {
    if (!_livingContainerView) {
        _livingContainerView = [[AUILiveRoomLivingContainerView alloc] init];
        [self.view addSubview:_livingContainerView];
        [_livingContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _livingContainerView;
}

- (AUILiveRoomPushStatusView *)pushStatusView {
    if (!_pushStatusView) {
        _pushStatusView = [[AUILiveRoomPushStatusView alloc] init];
        _pushStatusView.hidden = YES;
//        [self.livingContainerView addSubview:_pushStatusView];
//        [_pushStatusView mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
//            make.width.mas_equalTo(75);
//            make.height.mas_equalTo(30);
//            if (@available(iOS 11.0, *)) {
//                make.right.equalTo(self.livingContainerView.mas_safeAreaLayoutGuideRight);
//            } else {
//                make.right.equalTo(self.livingContainerView.mas_right);
//            }
//            make.top.equalTo(self.livingContainerView.mas_top).with.offset(85);
//        }];
    }
    return _pushStatusView;
}

- (AUILiveRoomInfoView *)liveInfoView {
    if(!_liveInfoView) {
        AUILiveRoomInfoView* view = [[AUILiveRoomInfoView alloc] init];
        [self.livingContainerView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.livingContainerView.mas_safeAreaLayoutGuideTop).with.offset(8);
                make.left.equalTo(self.livingContainerView.mas_safeAreaLayoutGuideLeft).with.offset(10);
            } else {
                make.top.equalTo(self.livingContainerView).with.offset(8);
                make.left.equalTo(self.livingContainerView).with.offset(10);
            }
            make.width.mas_equalTo(173);
            make.height.mas_equalTo(43);
        }];
        view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 21.5;
        view.anchorNickLabel.text = @"昵称";
        view.anchorAvatarView.image = AUIInteractionLiveGetImage(@"img-user-default");
        [view updateLikeCount:0];
        [view updatePV:0];
        _liveInfoView = view;
    }
    return _liveInfoView;
}

- (AUILiveDetailButton *)noticeButton {
    if (!_noticeButton) {
        AUILiveDetailButton* button = [[AUILiveDetailButton alloc] initWithFrame:CGRectMake(0, 0, 64.8, 19.6) image:AUIInteractionLiveGetImage(@"直播-公告") title:@"公告"];
//        [self.livingContainerView addSubview:button];
//        [button mas_makeConstraints:^(MASConstraintMaker *make) {
//            if (@available(iOS 11.0, *)) {
//                make.top.equalTo(self.livingContainerView.mas_safeAreaLayoutGuideTop).with.offset(56);
//            } else {
//                make.top.equalTo(self.livingContainerView).with.offset(56);
//            }
//            make.left.equalTo(self.membersButton.mas_right).with.offset(10);
//            make.width.mas_equalTo(64.8);
//            make.height.mas_equalTo(19.6);
//        }];
//        __weak typeof(self) weakSelf = self;
//        button.clickBlock = ^(AUILiveBlockButton * _Nonnull sender) {
//
//        };
        
        _noticeButton = button;
    }
    return _noticeButton;
}

- (AUILiveRoomMemberButton *)membersButton{
    if (!_membersButton) {
        _membersButton = [[AUILiveRoomMemberButton alloc] init];
        _membersButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
        _membersButton.layer.cornerRadius = 12.3;
//        [self.livingContainerView addSubview:_membersButton];
//        [_membersButton mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
//
//            if (@available(iOS 11.0, *)) {
//                make.top.equalTo(self.livingContainerView.mas_safeAreaLayoutGuideTop).with.offset(56);
//                make.left.equalTo(self.livingContainerView.mas_safeAreaLayoutGuideLeft).with.offset(18);
//            } else {
//                make.top.equalTo(self.livingContainerView).with.offset(56);
//                make.left.equalTo(self.livingContainerView.mas_left).with.offset(18);
//            }
//            make.width.mas_equalTo(64.8);
//            make.height.mas_equalTo(19.6);
//        }];
//
//        __weak typeof(self) weakSelf = self;
//        _membersButton.onMemberButtonClicked = ^{
//
//        };
    }
    return _membersButton;
}

- (AUILiveRoomCommentView *)liveCommentView {
    if(!_liveCommentView){
        _liveCommentView = [[AUILiveRoomCommentView alloc] init];
        [self.livingContainerView addSubview:_liveCommentView];
        [_liveCommentView mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.livingContainerView.mas_safeAreaLayoutGuideBottom).with.offset(-59);
                make.left.equalTo(self.livingContainerView.mas_safeAreaLayoutGuideLeft).with.offset(10);
            } else {
                make.bottom.equalTo(self.livingContainerView).with.offset(-59);
                make.left.equalTo(self.livingContainerView.mas_left).with.offset(10);
            }
            make.right.equalTo(self.view.mas_right).with.offset(-1 * kLiveCommentPortraitRightGap - 20);
            make.height.mas_equalTo(kLiveCommentPortraitHeight);
        }];
    }
    return _liveCommentView;
}

- (AUILiveRoomAnchorBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[AUILiveRoomAnchorBottomView alloc] init];
        _bottomView.actionsDelegate = self;
        [self.livingContainerView addSubview:_bottomView];
        [_bottomView mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.livingContainerView.mas_safeAreaLayoutGuideBottom);
                make.left.equalTo(self.livingContainerView.mas_safeAreaLayoutGuideLeft);
                make.right.equalTo(self.livingContainerView.mas_safeAreaLayoutGuideRight);
            } else {
                make.bottom.equalTo(self.livingContainerView);
                make.left.equalTo(self.livingContainerView);
                make.right.equalTo(self.livingContainerView);
            }
            make.height.mas_equalTo(59);
        }];
    }
    return _bottomView;
}

- (AUILiveRoomLoadingIndicatorView*)pushLoadingIndicator {
    if (!_pushLoadingIndicator) {
        _pushLoadingIndicator = [[AUILiveRoomLoadingIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _pushLoadingIndicator.hidden = YES;
        _pushLoadingIndicator.tintColor = [UIColor whiteColor];
        _pushLoadingIndicator.color = [UIColor whiteColor];
        [self.livingContainerView addSubview:_pushLoadingIndicator];
        [_pushLoadingIndicator mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.size.mas_equalTo(CGSizeMake(38.4, 38.4));
            make.centerX.equalTo(self.livingContainerView.mas_centerX);
            make.centerY.equalTo(self.livingContainerView.mas_centerY);
        }];
    }
    return  _pushLoadingIndicator;
}

- (AUILiveRoomAnchorPrestartView *)livePrestartView {
    if (!_livePrestartView) {
        _livePrestartView = [[AUILiveRoomAnchorPrestartView alloc] init];
        _livePrestartView.hidden = YES;
        _livePrestartView.delegate = self;
        [self.view addSubview:_livePrestartView];
        [self.view insertSubview:_livePrestartView aboveSubview:self.livingContainerView];
        [_livePrestartView mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _livePrestartView;
}

- (AUILiveRoomFinishView *)liveFinishView {
    if (!_liveFinishView) {
        _liveFinishView = [[AUILiveRoomFinishView alloc] init];
        _liveFinishView.hidden = YES;
        [self.view insertSubview:_liveFinishView belowSubview:self.livingContainerView];
        [_liveFinishView mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _liveFinishView;
}

#pragma mark - AVUIViewControllerInteractivePodGesture

- (BOOL)disableInteractivePodGesture {
    return YES;
}

#pragma mark - AUILiveRoomAnchorBottomViewDelegate

- (void)onShareButtonClicked {
    
}

- (void)onBeautyButtonClicked {
    [self.liveManager.livePusher.beautyController showPanel:YES];
}

- (void)onMoreInteractionButtonClicked {
    AUILiveRoomMorePanel *morePanel = [[AUILiveRoomMorePanel alloc] initWithFrame:CGRectMake(0, self.view.av_height - 200, self.view.av_width, 200)];
    [morePanel updateClickedSelected:AUILiveRoomMorePanelActionTypeMute selected:self.liveManager.livePusher.isMute];
    [morePanel updateClickedSelected:AUILiveRoomMorePanelActionTypePause selected:self.liveManager.livePusher.isPause];
    [morePanel updateClickedSelected:AUILiveRoomMorePanelActionTypeCamera selected:self.liveManager.livePusher.isBackCamera];
    [morePanel updateClickedSelected:AUILiveRoomMorePanelActionTypeMirror selected:self.liveManager.livePusher.isMirror];
    [morePanel updateClickedSelected:AUILiveRoomMorePanelActionTypeBan selected:[self.roomManager isMuteAll]];
    __weak typeof(self) weakSelf = self;
    morePanel.onClickedAction = ^BOOL(AUILiveRoomMorePanel *sender, AUILiveRoomMorePanelActionType type, BOOL selected) {
        BOOL ret = selected;
        switch (type) {
            case AUILiveRoomMorePanelActionTypeMute:
            {
                [weakSelf.liveManager.livePusher mute:!selected];
                ret = weakSelf.liveManager.livePusher.isMute;
            }
                break;
            case AUILiveRoomMorePanelActionTypePause:
            {
                if (!selected) {
                    [weakSelf.liveManager.livePusher pause];
                }
                else {
                    [weakSelf.liveManager.livePusher resume];
                }
                ret = weakSelf.liveManager.livePusher.isPause;
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
            case AUILiveRoomMorePanelActionTypeNotice:
            {
                [AVAlertController showInput:@"请输入新的直播公告" vc:weakSelf onCompleted:^(NSString * _Nonnull input) {
                    // TODO:
                }];
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
}

- (void)onCommentSent:(NSString*)comment {
    [self.roomManager sendComment:comment completed:nil];
}

- (void)onLikeSent {
    [self.roomManager sendLike];
}

#pragma mark - AUILiveRoomAnchorPrestartViewDelegate

- (void)onPrestartStartLiveButtonClicked {
    self.livePrestartView.userInteractionEnabled = NO;
    [self.liveManager startLivePusher];
    [self startLive];
}

- (void)onPrestartSwitchCameraButtonClicked {
    [self.liveManager.livePusher switchCamera];
}

- (void)onPrestartBeautyButtonClicked {
    [self.liveManager.livePusher.beautyController showPanel:YES];
}



#pragma mark - LifeCycle

- (void)dealloc {
    
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
            weakSelf.bottomView.commentState = isMuteAll ?  AUILiveRoomAnchorBottomCommentStateBeenMuteAll : AUILiveRoomAnchorBottomCommentStateDefault;
        };
        _roomManager.onReceivedLike = ^(AUIInteractionLiveUser * _Nonnull sender, NSInteger likeCount) {
            [weakSelf.liveInfoView updateLikeCount:likeCount];
        };
        _roomManager.onReceivedPV = ^(AUIInteractionLiveUser * _Nonnull sender, NSInteger pv) {
            [weakSelf.liveInfoView updatePV:pv];
        };
        _roomManager.onReceivedApplyLinkMic = ^(AUIInteractionLiveUser * _Nonnull sender) {
            [weakSelf receiveApply:sender];
        };
        _roomManager.onReceivedJoinLinkMic = ^(AUIInteractionLiveUser * _Nonnull sender, AUIInteractionLiveLinkMicPullInfo * _Nonnull linkMicUserInfo) {
            [weakSelf receivedJoinLinkMic:linkMicUserInfo];
        };
        _roomManager.onReceivedLeaveLinkMic = ^(AUIInteractionLiveUser * _Nonnull sender, NSString * _Nonnull userId) {
            [weakSelf receivedLeaveLinkMic:userId];
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    self.liveInfoView.anchorNickLabel.text = self.roomManager.liveInfoModel.title ?: AUIInteractionAccountManager.me.nickName;
    UIImage *avatar = [UIImage imageNamed:AUIInteractionAccountManager.me.avatar];
    if (avatar) {
        self.liveInfoView.anchorAvatarView.image = avatar;
    }
    [self.liveInfoView updateLikeCount:self.roomManager.allLikeCount];
    [self.liveInfoView updatePV:self.roomManager.pv];
    
    self.livingContainerView.hidden = NO;
    self.livePrestartView.hidden = YES;
    self.liveFinishView.hidden = YES;
    self.linkMicButton.hidden = NO;
    if (self.roomManager.liveInfoModel.status == AUIInteractionLiveStatusNone) {
        self.livingContainerView.hidden = YES;
        self.livePrestartView.hidden = NO;
        self.linkMicButton.hidden = YES;
    }
    else if (self.roomManager.liveInfoModel.status == AUIInteractionLiveStatusFinished) {
        self.liveFinishView.hidden = NO;
        self.linkMicButton.hidden = YES;
    }
    
    [self setupLiveManager];
    
    // todo: loading
    __weak typeof(self) weakSelf = self;
    [self.roomManager enterRoom:^(BOOL success) {
        if (!success) {
            [AVAlertController showWithTitle:nil message:@"进行频道失败" needCancel:NO onCompleted:^(BOOL isCanced) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }
        else {
            [weakSelf.roomManager queryMuteAll:^(BOOL success) {
                weakSelf.bottomView.commentState = weakSelf.roomManager.isMuteAll ? AUILiveRoomAnchorBottomCommentStateBeenMuteAll : AUILiveRoomAnchorBottomCommentStateDefault;
            }];
            
            [weakSelf.liveInfoView updateLikeCount:weakSelf.roomManager.allLikeCount];
            [weakSelf.liveInfoView updatePV:weakSelf.roomManager.pv];
            
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
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    [self liveDisplayView];
    
    [self livingContainerView];
    [self pushStatusView];
    [self liveInfoView];
    [self noticeButton];
    [self membersButton];
    [self liveCommentView];
    [self bottomView];
    
    [self livePrestartView];
    
    [self exitButton];
}

- (void)showLivingUI {
    _livePrestartView.hidden = YES;
    [_livePrestartView removeFromSuperview];
    
    self.livingContainerView.hidden = NO;
    self.livingContainerView.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.livingContainerView.alpha = 1.0;
    }];
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
    [self.roomManager startLive:^(BOOL success) {
        NSLog(@"开始直播：%@", success ? @"成功" : @"失败");
        if (success) {
            return;
        }
        [AVAlertController showWithTitle:@"提示" message:@"开始直播失败了，是否再试一次" needCancel:YES onCompleted:^(BOOL isCanced) {
            if (!isCanced) {
                [weakSelf startLive];
            }
        }];
    }];
}

- (void)setupLiveManager {
    
    if (self.roomManager.liveInfoModel.mode == AUIInteractionLiveModeLinkMic) {
        self.liveManager = [[AUILiveRoomLinkMicManagerAnchor alloc] initWithRoomManager:self.roomManager displayView:self.liveDisplayView];
    }
    else {
        self.liveManager = [[AUILiveRoomBaseLiveManagerAnchor alloc] initWithRoomManager:self.roomManager displayView:self.liveDisplayView];
    }
    
    __weak typeof(self) weakSelf = self;
    self.liveManager.onStartedBlock = ^{
        [weakSelf showLivingUI];
        
        weakSelf.linkMicButton.hidden = NO;
        weakSelf.pushStatusView.hidden = NO;
        weakSelf.liveCommentView.showComment = YES;
        weakSelf.liveCommentView.showLiveSystemMessage = YES;
        [weakSelf.liveCommentView insertLiveSystemMessage:@"直播已开始"];
        
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusFluent;
    };
    self.liveManager.onPausedBlock = ^{
        [weakSelf.liveCommentView insertLiveSystemMessage:@"直播已暂停"];
    };
    self.liveManager.onResumedBlock = ^{
        [weakSelf.liveCommentView insertLiveSystemMessage:@"直播已恢复"];
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
        [weakSelf.pushLoadingIndicator show:NO];
    };
    self.liveManager.onReconnectStartBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusBrokenOff;
        [weakSelf.pushLoadingIndicator show:YES];
    };
    self.liveManager.onReconnectSuccessBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusFluent;
        [weakSelf.pushLoadingIndicator show:NO];
    };
    self.liveManager.onReconnectErrorBlock = ^{
        weakSelf.pushStatusView.pushStatus = AUILiveRoomPushStatusBrokenOff;
        [weakSelf.pushLoadingIndicator show:NO];
    };
    
    self.liveManager.roomVC = self;
    [self.liveManager setupLivePusher];
    self.liveManager.livePusher.beautyController = [[AUILiveRoomBeautyController alloc] initWithPresentView:self.view contextMode:self.roomManager.liveInfoModel.mode == AUIInteractionLiveModeLinkMic];
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
            [weakSelf openLinkMicPanel];
        }
    }];
}

- (void)receivedJoinLinkMic:(AUIInteractionLiveLinkMicPullInfo *)linkMicUserInfo {
    __weak typeof(self) weakSelf = self;
    [[self linkMicManager] receivedJoinLinkMic:linkMicUserInfo completed:^(BOOL success) {
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

- (AUILiveBlockButton *)linkMicButton {
    if (self.roomManager.liveInfoModel.mode != AUIInteractionLiveModeLinkMic) {
        return nil;
    }
    if (!_linkMicButton) {
        AUILiveBlockButton* button = [[AUILiveBlockButton alloc] init];
        [button setTitle:@"申请列表" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.cyanColor forState:UIControlStateNormal];
        button.layer.cornerRadius = 15;
        button.layer.borderColor = UIColor.cyanColor.CGColor;
        button.layer.borderWidth = 1;
//        button.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.3];
        button.titleLabel.font = AVGetMediumFont(12);
        [self.livingContainerView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.livingContainerView).with.offset(-64-AVSafeBottom);
            make.right.equalTo(self.livingContainerView.mas_right).with.offset(-16);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(60);
        }];

        __weak typeof(self) weakSelf = self;
        button.clickBlock = ^(AUILiveBlockButton * _Nonnull sender) {
            [weakSelf openLinkMicPanel];
        };
        _linkMicButton = button;
    }
    return _linkMicButton;
}

- (void)openLinkMicPanel {
    
    if (![self linkMicManager].isLiving) {
        return;
    }
    
    if (self.linkMicPanel) {
        [self.linkMicPanel reload];
    }
    else {
        __weak typeof(self) weakSelf = self;
        AUILiveRoomLinkMicListPanel *panel = [[AUILiveRoomLinkMicListPanel alloc] initWithFrame:CGRectMake(0, self.view.av_height - 200, self.view.av_width, 240) withManager:[self linkMicManager]];
        [panel showOnView:self.view];
        panel.onShowChanged = ^(AVBaseControllPanel * _Nonnull sender) {
            if (!weakSelf.linkMicPanel.isShowing) {
                weakSelf.linkMicPanel = nil;
            }
        };
        weakSelf.linkMicPanel = panel;
    }
}

@end
