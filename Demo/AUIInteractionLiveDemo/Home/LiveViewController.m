//
//  LiveViewController.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/10/24.
//

#import "LiveViewController.h"
#import "AUIInteractionLiveListViewController.h"
#import "AUIInteractionLiveService.h"
#import "AUIFoundation.h"
#import "AUIInteractionAccountManager.h"
#import "AUIInteractionLiveManager.h"

@interface LiveViewController ()

@property (nonatomic, strong) UIButton *modifyUserBtn;

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.headerView.hidden = YES;
    
    [self.class loadCurrentUser];
    
    UIButton *modifyUser = [[UIButton alloc] initWithFrame:CGRectMake(24, 200, 100, 44)];
    modifyUser.backgroundColor = UIColor.orangeColor;
    [modifyUser setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [modifyUser addTarget:self action:@selector(onModifyUserClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:modifyUser];
    self.modifyUserBtn = modifyUser;
    [self updateModifyUserButtonTitle];
    
    UIButton *liveList = [[UIButton alloc] initWithFrame:CGRectMake(24, modifyUser.av_bottom + 24, 100, 44)];
    liveList.backgroundColor = UIColor.orangeColor;
    [liveList setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [liveList setTitle:@"直播间" forState:UIControlStateNormal];
    [liveList addTarget:self action:@selector(onLiveListClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:liveList];
}

- (void)updateModifyUserButtonTitle {
    [self.modifyUserBtn setTitle:[self.class isLogin] ? @"登出" : @"登录" forState:UIControlStateNormal];
}

- (void)onModifyUserClicked:(UIButton *)sender {
    if ([self.class isLogin]) {
        [self onLogout];
        return;
    }
    
    [AVAlertController showInput:AUIInteractionAccountManager.me.nickName title:@"请输入用户昵称" message:@"用户昵称与Id一致" okTitle:nil cancelTitle:nil vc:nil onCompleted:^(NSString * _Nonnull input, BOOL isCancel) {
        if (!isCancel) {
            [self onLogin:input];
        }
    }];
}

- (void)onLiveListClicked:(UIButton *)sender {
    BOOL isLogin = [self.class isLogin];
    if (!isLogin) {
        [AVAlertController show:@"请先登录" vc:self];
    }
    
    
    AUIInteractionLiveListViewController *roomListVC = [AUIInteractionLiveListViewController new];
    // 直播列表的展示需要使用导航控制器，否则页面间无法跳转，建议AVNavigationController
    if (self.navigationController) {
        [self.navigationController pushViewController:roomListVC animated:YES];
    }
    else {
        AVNavigationController *nav =[[AVNavigationController alloc]initWithRootViewController:roomListVC];
        [self av_presentFullScreenViewController:nav animated:YES completion:nil];
    }
}

- (void)onLogout {
    [[AUIInteractionLiveManager defaultManager] logout];
    AUIInteractionAccountManager.me.userId = @"";
    AUIInteractionAccountManager.me.nickName = @"";
    AUIInteractionAccountManager.me.token = @"";
    [self.class saveCurrentUser];

    [self updateModifyUserButtonTitle];
    [AVAlertController show:@"已成功登出"];
}

- (void)onLogin:(NSString *)uid {
    if (uid.length > 0) {
        [AUIInteractionLiveService requestWithPath:@"/api/v1/live/login" bodyDic:@{@"password":uid, @"username":uid} completionHandler:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject, NSError * _Nonnull error) {
            if (!error) {
                AUIInteractionAccountManager.me.userId = uid;
                AUIInteractionAccountManager.me.nickName = uid;
                AUIInteractionAccountManager.me.token = [responseObject objectForKey:@"token"];
                [AVAlertController show:@"已成功登录"];
                [self.class saveCurrentUser];
                [self updateModifyUserButtonTitle];
            }
            else {
                [AVAlertController show:@"登录失败"];
            }
        }];
    }
}


+ (BOOL)isLogin {
    return AUIInteractionAccountManager.me.userId.length > 0;
}


+ (void)loadCurrentUser {
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"my_user_id"];
    NSString *nickName = [[NSUserDefaults standardUserDefaults] objectForKey:@"my_user_name"];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"my_user_token"];
    if (userId.length > 0) {
        AUIInteractionAccountManager.me.userId = userId;
        AUIInteractionAccountManager.me.nickName = nickName ?: userId;
        AUIInteractionAccountManager.me.token = token;
    }
}

+ (void)saveCurrentUser {
    [[NSUserDefaults standardUserDefaults] setObject:AUIInteractionAccountManager.me.userId forKey:@"my_user_id"];
    [[NSUserDefaults standardUserDefaults] setObject:AUIInteractionAccountManager.me.nickName forKey:@"my_user_name"];
    [[NSUserDefaults standardUserDefaults] setObject:AUIInteractionAccountManager.me.token forKey:@"my_user_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
