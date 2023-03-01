//
//  AUILiveRoomFinishView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/8.
//

#import <UIKit/UIKit.h>
#import "AUIRoomLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomFinishView : UIView

@property (strong, nonatomic) AUIRoomLiveVodInfoModel *vodModel;

@property (assign, nonatomic) BOOL isAnchor;
@property (copy, nonatomic) void (^onLikeButtonClickedBlock)(AUILiveRoomFinishView *sender);
@property (copy, nonatomic) void (^onShareButtonClickedBlock)(AUILiveRoomFinishView *sender);
@property (copy, nonatomic) void (^onFullScreenBlock)(AUILiveRoomFinishView *sender, BOOL fullScreen);


@end

NS_ASSUME_NONNULL_END
