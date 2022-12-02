//
//  AUILiveRoomCdnPull.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/25.
//

#import <UIKit/UIKit.h>
#import "AUILiveRoomLiveDisplayLayoutView.h"
#import "AUIInteractionLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomCdnPull : NSObject

@property (strong, nonatomic) AUIInteractionLiveInfoModel *liveInfoModel;

@property (strong, nonatomic, readonly) AUILiveRoomLiveDisplayView *displayView;

@property (copy, nonatomic) void(^onPrepareStartBlock)(void);
@property (copy, nonatomic) void(^onPrepareDoneBlock)(void);
@property (copy, nonatomic) void(^onLoadingStartBlock)(void);
@property (copy, nonatomic) void(^onLoadingEndBlock)(void);
@property (copy, nonatomic) void(^onPlayErrorBlock)(void);

- (void)prepare;
- (BOOL)start;
- (void)destory;

@end

NS_ASSUME_NONNULL_END
