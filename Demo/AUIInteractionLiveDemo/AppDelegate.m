//
//  AppDelegate.m
//  AUIInteractionLiveDemo
//
//  Created by Bingo on 2022/11/1.
//

#import "AppDelegate.h"
#import "AUIFoundation.h"
#import "AUIInteractionLiveManager.h"

#import "LiveViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // 设置主题模式
    AVTheme.supportsAutoMode = YES;
    AVTheme.currentMode = AVThemeModeLight;
    
    [AUIInteractionLiveManager registerLive];
    
    // 你的APP首页
    LiveViewController *liveVC = [LiveViewController new];
    
    // 如果不使用AVNavigationController作为APP导航控制器，需要你进行以下处理：
    // 1、隐藏导航控制器的导航栏：self.navigationBar.hidden = YES
    // 2、直播间（AUILiveRoomAnchorViewController和AUILiveRoomAudienceViewController）禁止使用向右滑动时关闭直播间操作。
    AVNavigationController *nav =[[AVNavigationController alloc]initWithRootViewController:liveVC];
    [self.window setRootViewController:nav];
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
