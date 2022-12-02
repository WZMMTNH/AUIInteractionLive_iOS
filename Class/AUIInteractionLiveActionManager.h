//
//  AUIInteractionLiveActionManager.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/29.
//

#import <UIKit/UIKit.h>
#import "AUIInteractionLiveUser.h"
#import "AUIInteractionLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^onActionCompleted)(BOOL success);

@interface AUIInteractionLiveActionManager : NSObject

@property (nonatomic, strong, readonly, class) AUIInteractionLiveActionManager *defaultManager;

@property (nonatomic, copy) void (^followAnchorAction)(AUIInteractionLiveUser *anchor, BOOL isFollowed, UIViewController *roomVC, onActionCompleted completed);

@property (nonatomic, copy) void (^openShare)(AUIInteractionLiveInfoModel *liveInfo, UIViewController *roomVC, _Nullable onActionCompleted completed);

@end

NS_ASSUME_NONNULL_END
