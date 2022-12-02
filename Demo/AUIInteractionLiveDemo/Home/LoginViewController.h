//
//  LoginViewController.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/1.
//

#import <UIKit/UIKit.h>
#import "AUIFoundation.h"


NS_ASSUME_NONNULL_BEGIN

@interface LoginViewController : AVBaseViewController

@property (nonatomic, copy) void (^onLoginSuccessHandler)(LoginViewController *sender);

+ (BOOL)isLogin;
+ (void)logout;

@end

NS_ASSUME_NONNULL_END
