//
//  AUILiveRoomAnchorBottomView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AUILiveRoomAnchorBottomViewDelegate <NSObject>
- (void)onShareButtonClicked;
- (void)onBeautyButtonClicked;
- (void)onMoreInteractionButtonClicked;
- (void)onCommentSent:(NSString*)comment;
- (void)onLikeSent;
@end

typedef NS_ENUM(NSUInteger, AUILiveRoomAnchorBottomCommentState) {
    AUILiveRoomAnchorBottomCommentStateDefault,
    AUILiveRoomAnchorBottomCommentStateBeenMuteAll,
};

@interface AUILiveRoomAnchorBottomView : UIView

@property (assign, nonatomic) AUILiveRoomAnchorBottomCommentState commentState;
@property (weak, nonatomic) id<AUILiveRoomAnchorBottomViewDelegate> actionsDelegate;

- (void)updateLayoutRotated:(BOOL)rotated;

@end

NS_ASSUME_NONNULL_END
