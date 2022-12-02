//
//  AUILiveRoomVodPlay.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/21.
//

#import <UIKit/UIKit.h>
#import "AUIInteractionLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomVodPlay : UIView

@property (strong, nonatomic) AUIInteractionLiveVodInfoModel *vodInfoModel;

@property (copy, nonatomic) void(^onPrepareStartBlock)(void);
@property (copy, nonatomic) void(^onPrepareDoneBlock)(void);
@property (copy, nonatomic) void(^onLoadingStartBlock)(void);
@property (copy, nonatomic) void(^onLoadingEndBlock)(void);
@property (copy, nonatomic) void(^onPlayErrorBlock)(BOOL willRetry);

@property (assign, nonatomic) BOOL hiddenButtons;
@property (copy, nonatomic) void (^onLikeButtonClickedBlock)(AUILiveRoomVodPlay *sender);
@property (copy, nonatomic) void (^onShareButtonClickedBlock)(AUILiveRoomVodPlay *sender);
@property (copy, nonatomic) void (^onFullScreenBlock)(AUILiveRoomVodPlay *sender, BOOL fullScreen);


- (void)start;
- (void)stop;


@end

NS_ASSUME_NONNULL_END
