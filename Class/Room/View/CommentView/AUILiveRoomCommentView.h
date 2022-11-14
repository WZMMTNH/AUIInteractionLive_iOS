//
//  AUILiveRoomCommentView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>
#import "AUILiveRoomCommentModel.h"
#import "AUILiveRoomSystemMessageLabel.h"

#define kLiveCommentPortraitHeight (26 + [UIScreen mainScreen].bounds.size.height / 3)
#define kLiveCommentPortraitRightGap ([UIScreen mainScreen].bounds.size.width / 4)

#define kLiveCommentLandscapeHeight (26 + [UIScreen mainScreen].bounds.size.height / 3)
#define kLiveCommentLandscapeRightGap ([UIScreen mainScreen].bounds.size.width / 2)


NS_ASSUME_NONNULL_BEGIN


@interface AUILiveRoomCommentView : UIView

@property (assign, nonatomic) BOOL showComment;
@property (assign, nonatomic) BOOL showLiveSystemMessage;

/**
 * 直播系统消息展示用的label
 */
@property (strong, nonatomic) AUILiveRoomSystemMessageLabel *liveSystemMessageLabel;

/**
 * @brief 插入直播系统消息
 * @param message 消息内容
 */
- (void)insertLiveSystemMessage:(NSString *)message;

/**
 * @brief 插入直播系统消息
 * @param messageModel 消息model
 */
- (void)insertLiveSystemMessageModel:(AUILiveRoomSystemMessageModel *)messageModel;


/**
 * 插入普通直播弹幕
 * @param comment 弹幕model
 * @param presentedCompulsorily 是否强制显示，默认不强制
 */
- (void) insertLiveComment:(AUILiveRoomCommentModel *)comment
     presentedCompulsorily:(BOOL)presentedCompulsorily;

/**
 * 插入普通直播弹幕
 * @param content 弹幕内容
 * @param nick 弹幕发送者昵称
 * @param presentedCompulsorily 是否强制显示，默认不强制
 */
- (void) insertLiveComment:(NSString *)content
         commentSenderNick:(NSString *)nick
           commentSenderID:(NSString *)userID
     presentedCompulsorily:(BOOL)presentedCompulsorily;


- (void) updateLayoutRotated:(BOOL)rotated;

@end

NS_ASSUME_NONNULL_END
