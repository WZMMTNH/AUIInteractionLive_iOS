//
//  AUIRoomBeautyManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/3.
//

#import "AUIRoomBeautyManager.h"
#import "AUIFoundation.h"
#import "AUIRoomBeautyController.h"

#import "AUIRoomSDKHeader.h"

@interface AUIRoomBeautyManager ()<QueenMaterialDelegate>

@property (nonatomic, copy) void (^checkResult)(BOOL completed);
@property (nonatomic, strong) AVProgressHUD *hub;

@end

@implementation AUIRoomBeautyManager

+ (instancetype)manager {
    static AUIRoomBeautyManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AUIRoomBeautyManager alloc] init];
    });
    return manager;
}

+ (void)registerBeautyEngine {
    [[QueenMaterial sharedInstance] requestMaterial:kQueenMaterialModel];
    [AUIRoomBeautyController setupMotionManager];
}

+ (void)checkResourceWithCurrentView:(UIView *)view completed:(void (^)(BOOL completed))completed {
    [AUIRoomBeautyManager manager].checkResult = completed;
    [[AUIRoomBeautyManager manager] startCheckWithCurrentView:view];
}

- (void)startCheckWithCurrentView:(UIView *)view {
    
    BOOL result = [[QueenMaterial sharedInstance] requestMaterial:kQueenMaterialModel];
    if (!result) {
        if (self.checkResult) {
            self.checkResult(YES);
        }
    }
    else {
        [self.hub hideAnimated:NO];
        
        AVProgressHUD *loading = [AVProgressHUD ShowHUDAddedTo:view animated:YES];
        loading.labelText = @"正在下载美颜模型中，请等待";
        self.hub = loading;
        
        [QueenMaterial sharedInstance].delegate = self;
    }
}

#pragma mark - QueenMaterialDelegate

- (void)queenMaterialOnReady:(kQueenMaterialType)type
{
    // 资源下载成功
    if (type == kQueenMaterialModel) {
        [self.hub hideAnimated:YES];
        self.hub = nil;
        if (self.checkResult) {
            self.checkResult(YES);
        }
    }
}

- (void)queenMaterialOnProgress:(kQueenMaterialType)type withCurrentSize:(int)currentSize withTotalSize:(int)totalSize withProgess:(float)progress
{
    // 资源下载进度回调
    if (type == kQueenMaterialModel) {
        NSLog(@"====正在下载资源模型，进度：%f", progress);
    }
}

- (void)queenMaterialOnError:(kQueenMaterialType)type
{
    // 资源下载出错
    if (type == kQueenMaterialModel){
        [self.hub hideAnimated:YES];
        self.hub = nil;
        if (self.checkResult) {
            self.checkResult(NO);
        }
    }
}

@end
