//
//  AUILiveRoomAnchorViewController.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/2.
//

#import <UIKit/UIKit.h>
#import "AUIRoomLiveService.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomAnchorViewController : UIViewController

@property (nonatomic , strong) NSString *chat_id;

- (instancetype)initWithLiveService:(AUIRoomLiveService *)liveService;

@end

NS_ASSUME_NONNULL_END
