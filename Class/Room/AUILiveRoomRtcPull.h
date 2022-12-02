//
//  AUILiveRoomRtcPull.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/25.
//

#import <UIKit/UIKit.h>
#import "AUILiveRoomLiveDisplayLayoutView.h"
#import "AUIInteractionLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomRtcPull : NSObject

@property (strong, nonatomic) AUIInteractionLiveLinkMicJoinInfoModel *joinInfo;

@property (strong, nonatomic, readonly) AUILiveRoomLiveDisplayView *displayView;

@property (copy, nonatomic) void(^onPlayErrorBlock)(void);

- (void)prepare;
- (BOOL)start;
- (void)destory;

@end

NS_ASSUME_NONNULL_END
