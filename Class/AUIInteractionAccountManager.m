//
//  AUIInteractionAccountManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/10/6.
//

#import <UIKit/UIKit.h>
#import "AUIInteractionAccountManager.h"

@implementation AUIInteractionAccountManager

+ (AUIInteractionLiveUser *)me {
    static AUIInteractionLiveUser *_instance = nil;
    if (!_instance) {
        _instance = [AUIInteractionLiveUser new];
    }
    return _instance;
}

+ (NSString *)deviceId {
    static NSString * _deviceId = nil;
    if (!_deviceId) {
        _deviceId = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    }
    return _deviceId;
}

@end
