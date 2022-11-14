//
//  AUILiveRoomAudienceBottomView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AUILiveRoomAudienceBottomViewDelegate <NSObject>
- (void)onShareButtonClicked;
- (void)onCommentSent:(NSString*)comment;
- (void)onLikeSent;
@end

typedef NS_ENUM(NSUInteger, AUILiveRoomAudienceBottomCommentState) {
    AUILiveRoomAudienceBottomCommentStateDefault,
    AUILiveRoomAudienceBottomCommentStateBeenMuteAll,
};

@interface AUILiveRoomAudienceBottomView : UIView

@property (assign, nonatomic) AUILiveRoomAudienceBottomCommentState commentState;
@property (weak, nonatomic) id<AUILiveRoomAudienceBottomViewDelegate> actionsDelegate;

- (void)updateLayoutRotated:(BOOL)rotated;


@end

NS_ASSUME_NONNULL_END
