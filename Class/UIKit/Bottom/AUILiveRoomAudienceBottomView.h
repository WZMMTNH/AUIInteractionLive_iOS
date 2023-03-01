//
//  AUILiveRoomAudienceBottomView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/7.
//

#import <UIKit/UIKit.h>
#import "AUILiveRoomCommentTextField.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomAudienceBottomView : UIView

@property (strong, nonatomic, readonly) AUILiveRoomCommentTextField* commentTextField;

@property (copy, nonatomic) void (^onLikeButtonClickedBlock)(AUILiveRoomAudienceBottomView *sender);
@property (copy, nonatomic) void (^onLinkMicButtonClickedBlock)(AUILiveRoomAudienceBottomView *sender);
@property (copy, nonatomic) void (^onShareButtonClickedBlock)(AUILiveRoomAudienceBottomView *sender);
@property (copy, nonatomic) void (^sendCommentBlock)(AUILiveRoomAudienceBottomView *sender, NSString *comment);

- (instancetype)initWithFrame:(CGRect)frame linkMic:(BOOL)linkMic;



@end

NS_ASSUME_NONNULL_END
