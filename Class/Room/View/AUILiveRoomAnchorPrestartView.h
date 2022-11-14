//
//  AUILiveRoomAnchorPrestartView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AUILiveRoomAnchorPrestartViewDelegate <NSObject>

- (void)onPrestartStartLiveButtonClicked;
- (void)onPrestartSwitchCameraButtonClicked;
- (void)onPrestartBeautyButtonClicked;

@end

@interface AUILiveRoomAnchorPrestartView : UIView


@property (strong, nonatomic) UIButton *switchCameraButton;
@property (strong, nonatomic) UIButton *beautyButton;
@property (strong, nonatomic) UIButton *startLiveButton;

@property (weak, nonatomic) id<AUILiveRoomAnchorPrestartViewDelegate> delegate;

- (void)updateLayoutRotated:(BOOL)rotated;

@end

NS_ASSUME_NONNULL_END
