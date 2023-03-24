# AUIInteractionLive组件

互动直播解决方案是一套开源的、完整的视频直播互动推流组件，它基于阿里云音视频终端SDK，实现端侧直播推流、连麦、观看等功能，同时支持弹幕、美颜特效等插件。您可以根据业务需求复用 AUI Kits 中视频互动直播功能进行接入，快速搭建诸如互动直播、电商直播等功能，降低接入成本和周期，提升接入体验。


## 源码说明

### 源码下载
[下载地址](https://github.com/aliyunvideo/AUIInteractionLive_iOS)

### 源码结构
```
├── AUIInteractionLive  // 根目录
│   ├── AUIInteractionLive.podspec                // pod描述文件
│   ├── Class                                     // 源代码文件
│   ├── Resources                                 // 资源文件
│   ├── Demo                                      // Demo代码
│   ├── README.md                                 // Readme   

```

### 环境要求
- Xcode 12.0 及以上版本，推荐使用最新正式版本
- CocoaPods 1.9.3 及以上版本
- 准备 iOS 10.0 及以上版本的真机

### 前提条件
获取音视频终端SDK License和key，需要包含推流、播放、美颜的授权。
参考[获取License](https://help.aliyun.com/document_detail/438207.html)


## 跑通demo

- 源码下载后，进入Demo目录
- 执行“pod install  --repo-update”，自动安装依赖SDK
- 打开工程文件“AUIInteractionLiveDemo.xcworkspace”，修改包Id
- 在控制台上申请试用License，开通直播推流、播放、美颜等能力，获取License文件和LicenseKey，如果已开通License直接进入下一步
- 把License文件放到Demo/AUIInteractionLiveDemo/目录下，并修改文件名为“license.crt”
- 把“LicenseKey”（如果没有，请在控制台拷贝），打开“AUIInteractionLiveDemo/Info.plist”，填写到字段“AlivcLicenseKey”的值中
- 编译运行


## 快速搭建自己的互动直播
可通过以下几个步骤快速集成AUIInteractionLive到你的APP中，让你的APP具备互动直播功能

### 集成源码
- 导入AUIInteractionLive：拷贝AUIInteractionLive文件夹到你的APP代码目录下，与你的Podfile文件在同一层级，可以删除AUIInteractionLive/Demo目录
- 修改你的Podfile，引入：
  - AliVCSDK_PremiumLive：适用于互动直播的音视频终端SDK，也可以使用AliVCSDK_Premium，参考[SDK说明](https://help.aliyun.com/document_detail/440004.html#section-icw-ppu-dll)
  - AlivcInteraction：互动SDK
  - 基础UI组件：AUIFoundation，参考[源码](https://github.com/aliyunvideo/MONE_demo_opensource_iOS/tree/main/AUIFoundation)，根据自身的业务，有需要对组件代码修改的话，可以下载到APP代码中进行本地集成再修改
  - 美颜UI组件：AUIQueenCom，参考[源码](https://github.com/aliyunvideo/MONE_demo_opensource_iOS/tree/main/AUIQueenCom)，根据自身的业务，有需要对组件代码修改的话，可以下载到APP代码中进行本地集成再修改
  -互动直播UI组件：AUIInteractionLive，即第一步导入的源代码，根据自身的业务，有需要可以对组件代码进行修改
```ruby

#需要iOS10.0及以上才能支持
platform :ios, '10.0'

target '你的App target' do
    # 根据自己的业务场景，集成合适的音视频终端SDK
    # 如果你的APP中还需要频短视频编辑功能，可以使用音视频终端全功能SDK（AliVCSDK_Premium），可以把本文件中的所有AliVCSDK_PremiumLive替换为AliVCSDK_Premium
    pod 'AliVCSDK_PremiumLive', '~> 1.8.0'
    
    # 互动SDK
    pod 'AlivcInteraction', '~> 1.0.0'

    # 基础UI组件
    pod 'AUIFoundation/All', '~> 1.8.0'
    
    # 美颜UI组件，如果终端SDK使用的是AliVCSDK_Premium，需要AliVCSDK_PremiumLive替换为AliVCSDK_Premium
    pod 'AUIQueenCom/AliVCSDK_PremiumLive', '~> 1.8.0'
    
    # 互动直播UI组件，如果终端SDK使用的是AliVCSDK_Premium，需要AliVCSDK_PremiumLive替换为AliVCSDK_Premium
    pod 'AUIInteractionLive/AliVCSDK_PremiumLive',  :path => "./AUIInteractionLive/"

end
```
- 执行“pod install --repo-update”
- 源码集成完成

### 工程配置
- 编译设置
  - 配置Build Setting > Linking > Other Linker Flags ，添加-ObjC。
  - 配置Build Setting > Build Options > Enable Bitcode，设为NO。
- 打开工程info.Plist，添加NSCameraUsageDescription和NSMicrophoneUsageDescription权限
- 如果你需要在APP后台时继续直播，那么需要在XCode中开启“Background Modes”
- 配置License，参考[License配置](https://help.aliyun.com/document_detail/440004.html#section-51r-40z-j1w)


### 初始化
- LiveService部署后，修改LiveService域名地址，找到AUIRoomAppServer.m文件，修改kLiveServiceDomainString的值，如下：
```ObjC
// AUIRoomAppServer.m

// 在部署LiveService部署后，修改LiveService域名地址
static NSString * const kLiveServiceDomainString =  @"你的LiveService域名";
```

- 初始化SDK配置：
  - 注册InteractionLive，注意需要引入头文件，必须确保在使用功能前进行注册
  - AUI组件页面的跳转需要依赖导航控制器，在App启动后进行SDK的初始化，建议你设置导航控制器（建议使用AVNavigationController）。以下是无Storyboard场景的启动初始化示例
```ObjC
#import "AUIInteractionLiveManager.h"


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // 在这里进行InteractionLive的初始化，注意需要引入头文件
    [AUIInteractionLiveManager registerLive];

    // APP首页
    LiveViewController *liveVC = [LiveViewController new];

    // 需要使用导航控制器，否则页面间无法跳转，建议AVNavigationController
    // 如果使用系统UINavigationController作为APP导航控制器，需要你进行以下处理：
    // 1、隐藏导航控制器的导航栏：self.navigationBar.hidden = YES
    // 2、直播间（AUILiveRoomAnchorViewController和AUILiveRoomAudienceViewController）禁止使用向右滑动时关闭直播间操作。
    AVNavigationController *nav =[[AVNavigationController alloc]initWithRootViewController:liveVC];
    [self.window setRootViewController:nav];
    [self.window makeKeyAndVisible];

    // 你的其他初始化...


    
    return YES;
}
```

- 对接登录用户，必须在用户登录后才开启/观看直播，在用户登录账号后，进行互动直播当前用户的初始化，如下：
``` ObjC
// 在登录后进行，进行赋值
// 如果本次启动用户不需要重新登录（用户token未过期），可以在加载登录用户后进行赋值

AUIRoomAccount.me.userId = @"当前登录用户id";
AUIRoomAccount.me.nickName = @"当前登录用户昵称";
AUIRoomAccount.me.avatar = @"当前登录用户头像";
AUIRoomAccount.me.token = @"当前登录用户token";   // 用于服务端用户有效性验证
```

### 运行
前面工作完成后，接下来可以根据自身的业务场景和交互，可以在你APP上通过AUIInteractionLive接口快速集成直播列表，主播开播，进入直播等功能，也可以根据自身的需求修改源码。
``` ObjC
// 打开直播列表
AUIInteractionLiveListViewController *roomListVC = [AUIInteractionLiveListViewController new];
// 直播列表的展示需要使用导航控制器，否则页面间无法跳转，建议AVNavigationController
if (self.navigationController) {
    // 在启动初始化时设置了导航控制器，可以直接push
    [self.navigationController pushViewController:roomListVC animated:YES];
}
else {
    AVNavigationController *nav =[[AVNavigationController alloc]initWithRootViewController:roomListVC];
    [self av_presentFullScreenViewController:nav animated:YES completion:nil];
}


// 主播开播
[[AUIInteractionLiveManager defaultManager] createLive:self];


// 进入直播
[[AUIInteractionLiveManager defaultManager] joinLive:roomModel currentVC:self];
```
