//
//  AUIInteractionLiveActionManager.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/29.
//

#import "AUIInteractionLiveActionManager.h"

@implementation AUIInteractionLiveActionManager

+ (AUIInteractionLiveActionManager *)defaultManager {
    static AUIInteractionLiveActionManager *_instance = nil;
    if (!_instance) {
        _instance = [AUIInteractionLiveActionManager new];
    }
    return _instance;
}

@end
