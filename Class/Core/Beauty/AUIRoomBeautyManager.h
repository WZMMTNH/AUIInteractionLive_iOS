//
//  AUIRoomBeautyManager.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomBeautyManager : NSObject

+ (void)registerBeautyEngine;
+ (void)checkResourceWithCurrentView:(UIView *)view completed:(void (^)(BOOL completed))completed;

@end

NS_ASSUME_NONNULL_END
