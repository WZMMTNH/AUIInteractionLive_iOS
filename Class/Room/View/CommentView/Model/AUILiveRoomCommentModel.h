//
//  AUILiveRoomCommentModel.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRoomCommentModel : UIView

@property (copy, nonatomic) NSString* senderNick;
@property (strong, nonatomic) UIColor*  senderNickColor;
@property (copy, nonatomic) NSString* sentContent;
@property (strong, nonatomic) UIColor*  sentContentColor;
@property (copy, nonatomic) NSString* senderID;
@property (copy, nonatomic, readonly) NSString* fullCommentString;
@property (copy, nonatomic) NSDictionary* extension;

@end

@interface AUILiveRoomSystemMessageModel : NSObject

@property (copy, nonatomic) NSString* rawMessage;
@property (copy, nonatomic) NSDictionary* extension;

@end

NS_ASSUME_NONNULL_END
