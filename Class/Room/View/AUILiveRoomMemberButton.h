//
//  AUILiveRoomMemberButton.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomMemberButton : UIView

@property (strong, nonatomic) UIButton *memberHeaderImageButton;
@property (strong, nonatomic) UIButton *memberTextButton;
@property (strong, nonatomic) UIButton *memberDowndropFlagImageButton;
@property (copy, nonatomic) void(^onMemberButtonClicked)(void);

@end

NS_ASSUME_NONNULL_END
