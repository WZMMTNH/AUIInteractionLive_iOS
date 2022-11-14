//
//  AUILiveRoomAudienceViewController.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/2.
//

#import "AUILiveRoomAudienceViewController.h"
#import "AUIFoundation.h"
#import "AUIInteractionLiveMacro.h"
#import <Masonry/Masonry.h>

#import "AUILiveBlockButton.h"
#import "AUILiveDetailButton.h"
#import "AUILiveRoomInfoView.h"
#import "AUILiveRoomPushStatusView.h"
#import "AUILiveRoomCommentView.h"
#import "AUILiveRoomAudienceBottomView.h"
#import "AUILiveRoomLoadingIndicatorView.h"
#import "AUILiveRoomAudiencePrestartView.h"
#import "AUILiveRoomFinishView.h"
#import "AUILiveRoomLiveDisplayLayoutView.h"
#import "AUILiveRoomLivingContainerView.h"

#import "AUILiveRoomBaseLiveManager.h"
#import "AUILiveRoomLinkMicManager.h"


@interface AUILiveRoomAudienceViewController () <
AVUIViewControllerInteractivePodGesture,
AUILiveRoomAudienceBottomViewDelegate
>

@property (strong, nonatomic) AUILiveBlockButton* exitButton;

@property (strong, nonatomic) AUILiveRoomLiveDisplayLayoutView *liveDisplayView;

@property (strong, nonatomic) AUILiveRoomLivingContainerView *livingContainerView;
@property (strong, nonatomic) AUILiveRoomInfoView *liveInfoView;
@property (strong, nonatomic) AUILiveDetailButton *noticeButton;
@property (strong, nonatomic) AUILiveRoomCommentView *liveCommentView;
@property (strong, nonatomic) AUILiveRoomAudienceBottomView *bottomView;
@property (strong, nonatomic) AUILiveRoomLoadingIndicatorView *playLoadingIndicator;

@property (strong, nonatomic) AUILiveRoomAudiencePrestartView *livePrestartView;
@property (strong, nonatomic) AUILiveRoomFinishView *liveFinishView;

@property (strong, nonatomic) AUILiveRoomManager *roomManager;
@property (strong, nonatomic) id<AUILiveRoomLiveManagerAudienceProtocol> liveManager;

@property (strong, nonatomic) AUILiveBlockButton* linkMicButton;

@end

@implementation AUILiveRoomAudienceViewController

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
            [AVAlertController showWithTitle:@"提示" message:@"确定要离开吗？" needCancel:YES onCompleted:^(BOOL isCanced) {
                if (!isCanced) {
                    [weakSelf.liveManager destoryPullPlayer];
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
        _liveDisplayView.contentAreaInsets = UIEdgeInsetsMake(AVSafeTop+56, 0, AVSafeBottom+64+30, 0);
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
//            make.left.equalTo(self.livingContainerView.mas_left).with.offset(18);
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

- (AUILiveRoomAudienceBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[AUILiveRoomAudienceBottomView alloc] init];
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

- (AUILiveRoomLoadingIndicatorView*)playLoadingIndicator {
    if (!_playLoadingIndicator) {
        _playLoadingIndicator = [[AUILiveRoomLoadingIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _playLoadingIndicator.hidden = YES;
        _playLoadingIndicator.tintColor = [UIColor whiteColor];
        _playLoadingIndicator.color = [UIColor whiteColor];
        [self.livingContainerView addSubview:_playLoadingIndicator];
        [_playLoadingIndicator mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.size.mas_equalTo(CGSizeMake(38.4, 38.4));
            make.centerX.equalTo(self.livingContainerView.mas_centerX);
            make.centerY.equalTo(self.livingContainerView.mas_centerY);
        }];
    }
    return  _playLoadingIndicator;
}

- (AUILiveRoomAudiencePrestartView *)livePrestartView {
    if (!_livePrestartView) {
        _livePrestartView = [[AUILiveRoomAudiencePrestartView alloc] init];
        _livePrestartView.hidden = YES;
        [self.view insertSubview:_livePrestartView belowSubview:self.livingContainerView];
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

#pragma mark - AUILiveRoomAudienceBottomViewDelegate

- (void)onShareButtonClicked {
    
}

- (void)onCommentSent:(NSString*)comment {
    [self.roomManager sendComment:comment completed:nil];
}

- (void)onLikeSent {
    [self.roomManager sendLike];
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
            if (content.length == 0) {
                return;
            }
            NSString *senderNick = sender.nickName;
            NSString *senderId = sender.userId;
            [weakSelf.liveCommentView insertLiveComment:content commentSenderNick:senderNick commentSenderID:senderId presentedCompulsorily:NO];
        };
        _roomManager.onReceivedStartLive = ^(AUIInteractionLiveUser * _Nonnull sender) {
            weakSelf.livePrestartView.hidden = YES;
            [weakSelf.liveManager preparePullPlayer];
            [weakSelf.liveManager startPullPlayer];
            weakSelf.linkMicButton.hidden = NO;
        };
        _roomManager.onReceivedStopLive = ^(AUIInteractionLiveUser * _Nonnull sender) {
            [weakSelf.liveManager destoryPullPlayer];
            weakSelf.liveFinishView.hidden = NO;
            weakSelf.linkMicButton.hidden = YES;
            [weakSelf.playLoadingIndicator show:NO];
        };
        _roomManager.onReceivedMuteAll = ^(AUIInteractionLiveUser * _Nonnull sender, BOOL isMuteAll) {
            weakSelf.bottomView.commentState = isMuteAll ?  AUILiveRoomAudienceBottomCommentStateBeenMuteAll : AUILiveRoomAudienceBottomCommentStateDefault;
        };
        _roomManager.onReceivedLike = ^(AUIInteractionLiveUser * _Nonnull sender, NSInteger likeCount) {
            [weakSelf.liveInfoView updateLikeCount:likeCount];
        };
        _roomManager.onReceivedPV = ^(AUIInteractionLiveUser * _Nonnull sender, NSInteger pv) {
            [weakSelf.liveInfoView updatePV:pv];
        };
        _roomManager.onReceivedJoinLinkMic = ^(AUIInteractionLiveUser * _Nonnull sender, AUIInteractionLiveLinkMicPullInfo * _Nonnull linkMicUserInfo) {
            [weakSelf receivedJoinLinkMic:linkMicUserInfo];
        };
        _roomManager.onReceivedLeaveLinkMic = ^(AUIInteractionLiveUser * _Nonnull sender, NSString * _Nonnull userId) {
            [weakSelf receivedLeaveLinkMic:userId];
        };
        _roomManager.onReceivedResponseApplyLinkMic = ^(AUIInteractionLiveUser * _Nonnull sender, BOOL agree, NSString *pullUrl) {
            [weakSelf receivedApplyResult:sender.userId agree:agree];
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    
    self.liveInfoView.anchorNickLabel.text = self.roomManager.liveInfoModel.title;
    [self.liveInfoView updateLikeCount:self.roomManager.allLikeCount];
    [self.liveInfoView updatePV:self.roomManager.pv];
    
    [self setupLiveManager];
    [self updateLinkMicBUttonState];
    self.linkMicButton.hidden = YES;
    
    __weak typeof(self) weakSelf = self;
    [self.playLoadingIndicator show:YES];
    [self.roomManager enterRoom:^(BOOL success) {
        if (!weakSelf) {
            return;
        }
        [weakSelf.playLoadingIndicator show:NO];
        if (!success) {
            [AVAlertController showWithTitle:nil message:@"进行频道失败" needCancel:NO onCompleted:^(BOOL isCanced) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }
        else {
            [weakSelf.roomManager queryMuteAll:^(BOOL success) {
                weakSelf.bottomView.commentState = weakSelf.roomManager.isMuteAll ? AUILiveRoomAudienceBottomCommentStateBeenMuteAll : AUILiveRoomAudienceBottomCommentStateDefault;
            }];
            
            [weakSelf.liveInfoView updateLikeCount:weakSelf.roomManager.allLikeCount];
            [weakSelf.liveInfoView updatePV:weakSelf.roomManager.pv];
            
            // status
            if (weakSelf.roomManager.liveInfoModel.status == AUIInteractionLiveStatusNone) {
                weakSelf.livePrestartView.hidden = NO;
            }
            else if (weakSelf.roomManager.liveInfoModel.status == AUIInteractionLiveStatusLiving) {
                [weakSelf.liveManager preparePullPlayer];
                [weakSelf.liveManager startPullPlayer];
                weakSelf.linkMicButton.hidden = NO;
            }
            else if (weakSelf.roomManager.liveInfoModel.status == AUIInteractionLiveStatusFinished) {
                weakSelf.liveFinishView.hidden = NO;
                weakSelf.linkMicButton.hidden = YES;
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
    [self liveInfoView];
    [self noticeButton];
    [self liveCommentView];
    [self bottomView];
        
    [self exitButton];
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
    
    if (self.roomManager.liveInfoModel.mode == AUIInteractionLiveModeLinkMic) {
        self.liveManager = [[AUILiveRoomLinkMicManagerAudience alloc] initWithRoomManager:self.roomManager displayView:self.liveDisplayView];
    }
    else {
        self.liveManager = [[AUILiveRoomBaseLiveManagerAudience alloc] initWithRoomManager:self.roomManager displayView:self.liveDisplayView];
    }
    
    __weak typeof(self) weakSelf = self;
    self.liveManager.onPrepareStartBlock = ^{
        [weakSelf.playLoadingIndicator show:YES];
    };
    self.liveManager.onPrepareDoneBlock = ^{
        [weakSelf.playLoadingIndicator show:NO];
    };
    self.liveManager.onLoadingStartBlock = ^{
        [weakSelf.playLoadingIndicator show:YES];
    };
    self.liveManager.onLoadingEndBlock = ^{
        [weakSelf.playLoadingIndicator show:NO];
    };
    self.liveManager.onPlayErrorBlock = ^(BOOL willRetry){
        if (!willRetry) {
            [weakSelf.playLoadingIndicator show:NO];
        }
    };
    
    self.liveManager.roomVC = self;
    [self.liveManager setupPullPlayer];
}

#pragma mark - link mic

- (AUILiveRoomLinkMicManagerAudience *)linkMicManager {
    if ([self.liveManager isKindOfClass:AUILiveRoomLinkMicManagerAudience.class]) {
        return self.liveManager;
    }
    return nil;
}

- (void)receivedApplyResult:(NSString *)uid agree:(BOOL)agree {
    if (!agree) {
        [AVToastView show:@"主播已经拒绝了你的连麦请求！" view:self.view position:AVToastViewPositionMid];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[self linkMicManager] receivedResponseLinkMic:uid agree:agree completed:^(BOOL success) {
        if (success) {
            [weakSelf updateLinkMicBUttonState];
        }
    }];
}

- (void)receivedJoinLinkMic:(AUIInteractionLiveLinkMicPullInfo *)linkMicUserInfo {
    __weak typeof(self) weakSelf = self;
    [[self linkMicManager] receivedJoinLinkMic:linkMicUserInfo completed:^(BOOL success) {
        if (success) {
            [weakSelf updateLinkMicBUttonState];
        }
    }];
}

- (void)receivedLeaveLinkMic:(NSString *)userId {
    __weak typeof(self) weakSelf = self;
    [[self linkMicManager] receivedLeaveLinkMic:userId completed:^(BOOL success) {
        if (success) {
            [weakSelf updateLinkMicBUttonState];
        }
    }];
}

- (void)updateLinkMicBUttonState {
    if ([self linkMicManager].isJoinedLinkMic) {
        self.linkMicButton.selected = YES;
//        self.linkMicButton.layer.borderColor = UIColor.redColor.CGColor;
    }
    else {
        self.linkMicButton.selected = NO;
//        self.linkMicButton.layer.borderColor = UIColor.cyanColor.CGColor;
    }
}

- (AUILiveBlockButton *)linkMicButton {
    
    if (self.roomManager.liveInfoModel.mode != AUIInteractionLiveModeLinkMic) {
        return nil;
    }
    
    if (!_linkMicButton) {
        AUILiveBlockButton* button = [AUILiveBlockButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"申请连麦" forState:UIControlStateNormal];
        [button setTitle:@"连麦管理" forState:UIControlStateSelected];
        [button setTitleColor:UIColor.cyanColor forState:UIControlStateNormal];
        [button setTitleColor:UIColor.redColor forState:UIControlStateSelected];
        [button setTitleColor:UIColor.redColor forState:UIControlStateSelected | UIControlStateHighlighted];
        [button setBorderColor:UIColor.cyanColor forState:UIControlStateNormal];
        [button setBorderColor:UIColor.redColor forState:UIControlStateSelected];
        [button setBorderColor:UIColor.redColor forState:UIControlStateSelected | UIControlStateHighlighted];
        button.layer.cornerRadius = 15;
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
            [weakSelf checkCameraAuth:^(BOOL auth) {
                if (auth) {
                    [weakSelf checkMicAuth:^(BOOL auth) {
                        if (auth) {
                            [weakSelf onClickLinkMic];
                        }
                    }];
                }
            }];
        };
        _linkMicButton = button;
        [self updateLinkMicBUttonState];
    }
    return _linkMicButton;
}

- (void)onClickLinkMic {
    if (![self linkMicManager].isLiving) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    if (![self linkMicManager].isJoinedLinkMic) {
        [[self linkMicManager] applyLinkMic:^(BOOL success) {
            if (success) {
                [AVToastView show:@"已向主播发起连麦申请！" view:weakSelf.view position:AVToastViewPositionMid];
            }
            else {
                [AVToastView show:@"申请连麦失败！" view:weakSelf.view position:AVToastViewPositionMid];
            }
        }];
    }
    else {
        NSString *mute = @"静音";
        if ([self linkMicManager].livePusher.isMute) {
            mute = @"取消静音";
        }
        [AVAlertController showSheet:@[@"镜头翻转", mute, @"下麦"] alertTitle:@"连麦管理" message:nil cancelTitle:nil vc:self onCompleted:^(NSInteger idx) {
            if (idx == 0) {
                [[self linkMicManager].livePusher switchCamera];
            }
            else if (idx == 1) {
                [[self linkMicManager].livePusher mute:![self linkMicManager].livePusher.isMute];
            }
            else if (idx == 2) {
                [[self linkMicManager] leaveLinkMic:^(BOOL success) {
                    [weakSelf updateLinkMicBUttonState];
                }];
            }
        }];
    }
}

- (void)checkCameraAuth:(void(^)(BOOL auth))completed {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (completed) {
                completed(granted);
            }
        }];
        return;
    }
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        [AVAlertController showWithTitle:@"提示" message:@"需要相机权限以开启直播功能" cancelTitle:@"取消" okTitle:@"前往" onCompleted:^(BOOL isCanced) {
            if (!isCanced) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }
        }];
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    if (completed) {
        completed(YES);
    }
}

- (void)checkMicAuth:(void(^)(BOOL auth))completed {
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if (completed) {
                completed(granted);
            }
        }];
        return;
    }
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        [AVAlertController showWithTitle:@"提示" message:@"需要麦克风权限以开启直播功能" cancelTitle:@"取消" okTitle:@"前往" onCompleted:^(BOOL isCanced) {
            if (!isCanced) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }
        }];
        if (completed) {
            completed(NO);
        }
        return;
    }
    
    if (completed) {
        completed(YES);
    }
}

@end
