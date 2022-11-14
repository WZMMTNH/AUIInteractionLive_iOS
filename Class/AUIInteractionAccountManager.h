//
//  AUIInteractionAccountManager.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/10/6.
//

#import <Foundation/Foundation.h>
#import "AUIInteractionLiveUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIInteractionAccountManager : NSObject

+ (AUIInteractionLiveUser *)me;
@property (nonatomic, copy, readonly, class) NSString *deviceId;

@end

NS_ASSUME_NONNULL_END
