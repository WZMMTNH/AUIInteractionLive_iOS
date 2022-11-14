//
//  AUILiveRoomInfoView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomInfoView : UIView

@property (strong, nonatomic) UILabel *anchorNickLabel;
@property (strong, nonatomic) UIImageView *anchorAvatarView;
@property (strong, nonatomic) UILabel *pvLabel;
@property (strong, nonatomic) UILabel *likeCountLabel;

- (void)updateLikeCount:(NSInteger)count;
- (void)updatePV:(NSInteger)pv;

@end

NS_ASSUME_NONNULL_END
