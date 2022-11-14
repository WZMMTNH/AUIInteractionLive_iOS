//
//  AUILiveRoomBaseLiveManager+Private.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/29.
//

#import "AUILiveRoomBaseLiveManager.h"

@interface AUILiveRoomBaseLiveManagerAnchor ()

@property (strong, nonatomic) AUILiveRoomManager *roomManager;
@property (nonatomic, strong) AUILiveRoomLiveDisplayLayoutView *displayView;
@property (strong, nonatomic) AUILiveRoomPusher *livePusher;
@property (assign, nonatomic) BOOL isLiving;

@end


@interface AUILiveRoomBaseLiveManagerAudience ()

@property (strong, nonatomic) AUILiveRoomManager *roomManager;
@property (nonatomic, strong) AUILiveRoomLiveDisplayLayoutView *displayView;
@property (strong, nonatomic) AUILiveRoomCdnPull *cdnPull;
@property (assign, nonatomic) BOOL isLiving;

@end

