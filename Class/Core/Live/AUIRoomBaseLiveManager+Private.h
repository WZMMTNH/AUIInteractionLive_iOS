//
//  AUIRoomBaseLiveManager+Private.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/29.
//

#import "AUIRoomBaseLiveManager.h"

@interface AUIRoomBaseLiveManagerAnchor ()

@property (strong, nonatomic) AUIRoomLiveService *liveService;
@property (nonatomic, strong) AUIRoomDisplayLayoutView *displayLayoutView;
@property (strong, nonatomic) AUIRoomLivePusher *livePusher;
@property (assign, nonatomic) BOOL isLiving;

@end


@interface AUIRoomBaseLiveManagerAudience ()

@property (strong, nonatomic) AUIRoomLiveService *liveService;
@property (nonatomic, strong) AUIRoomDisplayLayoutView *displayLayoutView;
@property (strong, nonatomic) AUIRoomLiveCdnPlayer *cdnPull;
@property (assign, nonatomic) BOOL isLiving;

@end

