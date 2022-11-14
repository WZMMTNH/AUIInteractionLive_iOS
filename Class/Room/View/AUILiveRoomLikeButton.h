//
//  AUILiveRoomLikeButton.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomLikeButton : UIButton

@property (copy, nonatomic) void(^onLikeSent)(void);

@end

NS_ASSUME_NONNULL_END
