//
//  AUILiveRoomLinkMicListPanel.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/28.
//

#import "AUIFoundation.h"
#import "AUILiveRoomLinkMicManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomLinkMicListPanel : AVBaseCollectionControllPanel

- (instancetype)initWithFrame:(CGRect)frame withManager:(AUILiveRoomLinkMicManagerAnchor *)manager;

- (void)reload;

@end

NS_ASSUME_NONNULL_END
