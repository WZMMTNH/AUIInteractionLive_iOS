//
//  AUIInteractionLiveManager.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/6.
//

#import <UIKit/UIKit.h>
#import "AUIInteractionLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIInteractionLiveManager : NSObject

+ (void)registerLive;

+ (instancetype)defaultManager;

- (void)createLive:(AUIInteractionLiveMode)mode title:(NSString *)title currentVC:(UIViewController *)currentVC;
- (void)joinLive:(AUIInteractionLiveInfoModel *)model currentVC:(UIViewController *)currentVC;

- (void)logout;

@end

NS_ASSUME_NONNULL_END
