//
//  AUIInteractionLiveManager.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/6.
//

#import <UIKit/UIKit.h>
#import "AUIRoomLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIInteractionLiveManager : NSObject

+ (void)registerLive;

+ (instancetype)defaultManager;

// 创建直播间
- (void)createLive:(AUIRoomLiveMode)mode title:(NSString *)title notice:(NSString  * _Nullable)notice currentVC:(UIViewController *)currentVC completed:(void(^)(BOOL success))completedBlock;
- (void)createLive:(UIViewController *)currentVC;

// 加入直播间
- (void)joinLive:(AUIRoomLiveInfoModel *)model currentVC:(UIViewController *)currentVC;

// 上一场直播
- (void)loadLastLiveData;
- (BOOL)hasLastLive;
- (void)joinLastLive:(UIViewController *)currentVC;

// 登出
- (void)logout;

@end

NS_ASSUME_NONNULL_END
