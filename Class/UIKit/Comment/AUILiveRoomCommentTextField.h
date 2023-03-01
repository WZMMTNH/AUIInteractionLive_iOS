//
//  AUILiveRoomCommentTextField.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUILiveRoomCommentState) {
    AUILiveRoomCommentStateDefault,
    AUILiveRoomCommentStateMute,
};

@interface AUILiveRoomCommentTextField : UITextField

@property (assign, nonatomic) AUILiveRoomCommentState commentState;

@property (copy, nonatomic) void (^sendCommentBlock)(AUILiveRoomCommentTextField *sender, NSString *comment);

@property (copy, nonatomic) void (^willEditBlock)(AUILiveRoomCommentTextField *sender, CGRect keyboardFrame);
@property (copy, nonatomic) void (^endEditBlock)(AUILiveRoomCommentTextField *sender);


@end

NS_ASSUME_NONNULL_END
