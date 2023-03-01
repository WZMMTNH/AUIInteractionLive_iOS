//
//  AUILiveRoomCommentModel.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomCommentModel : UIView

@property (assign, nonatomic) CGFloat height;

@property (copy, nonatomic) NSString *senderID;
@property (copy, nonatomic) NSString *senderNick;
@property (copy, nonatomic) UIColor *senderNickColor;

@property (copy, nonatomic) NSString *sentContent;
@property (copy, nonatomic) UIColor *sentContentColor;

@property (copy, nonatomic, readonly) NSAttributedString *renderContent;


@end

NS_ASSUME_NONNULL_END
