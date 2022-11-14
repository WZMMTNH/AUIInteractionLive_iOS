//
//  AUILiveRoomLiveDisplayLayoutView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomLiveDisplayView : UIView

@property (nonatomic, strong, readonly) UIView *renderView;
@property (nonatomic, copy) NSString *nickName;

@property (nonatomic, copy) void (^onLayoutUpdated)(void);

@end

@interface AUILiveRoomLiveDisplayLayoutView : UIView

@property (nonatomic, assign) UIEdgeInsets contentAreaInsets;
@property (nonatomic, assign) CGSize resolution;

- (CGRect)renderRect:(AUILiveRoomLiveDisplayView *)displayView;

- (void)insertDisplayView:(AUILiveRoomLiveDisplayView *)displayView atIndex:(NSUInteger)index;
- (void)addDisplayView:(AUILiveRoomLiveDisplayView *)displayView;
- (void)removeDisplayView:(AUILiveRoomLiveDisplayView *)displayView;

- (void)layoutAll;

@end

NS_ASSUME_NONNULL_END
