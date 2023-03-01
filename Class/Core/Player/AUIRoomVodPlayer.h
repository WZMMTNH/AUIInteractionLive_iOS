//
//  AUIRoomVodPlayer.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/21.
//

#import <UIKit/UIKit.h>
#import "AUIRoomLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomVodPlayer : UIView

@property (strong, nonatomic) AUIRoomLiveVodInfoModel *vodInfoModel;

@property (copy, nonatomic) void(^onPrepareStartBlock)(void);
@property (copy, nonatomic) void(^onPrepareDoneBlock)(void);
@property (copy, nonatomic) void(^onLoadingStartBlock)(void);
@property (copy, nonatomic) void(^onLoadingEndBlock)(void);
@property (copy, nonatomic) void(^onPlayErrorBlock)(BOOL willRetry);

@property (copy, nonatomic) void (^onLikeButtonClickedBlock)(AUIRoomVodPlayer *sender);
@property (copy, nonatomic) void (^onShareButtonClickedBlock)(AUIRoomVodPlayer *sender);
@property (copy, nonatomic) void (^onFullScreenBlock)(AUIRoomVodPlayer *sender, BOOL fullScreen);


- (void)start;
- (void)stop;


@end

NS_ASSUME_NONNULL_END
