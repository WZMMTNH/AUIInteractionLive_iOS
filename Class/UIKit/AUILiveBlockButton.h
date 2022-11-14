//
//  AUILiveBlockButton.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveBlockButton : UIButton

@property (nonatomic, copy) void(^clickBlock)(AUILiveBlockButton *sender);

- (void)setBorderColor:(nullable UIColor *)color forState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
