//
//  AUILiveRoomSystemMessageLabel.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>
#import "AUILiveRoomCommentModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomSystemMessageLabel : UILabel

@property (assign, atomic) BOOL canPresenting;

- (void)insertLiveSystemMessage:(AUILiveRoomSystemMessageModel *)model;
- (void)stopPresenting;

@end

NS_ASSUME_NONNULL_END
