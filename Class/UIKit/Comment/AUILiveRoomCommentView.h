//
//  AUILiveRoomCommentView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>
#import "AUILiveRoomCommentModel.h"


NS_ASSUME_NONNULL_BEGIN


@interface AUILiveRoomCommentView : UIView

@property(nonatomic, assign, readonly) NSUInteger commentCount;

/**
 * 插入普通直播弹幕
 * @param comment 弹幕model
 * @param presentedCompulsorily 是否强制显示，默认不强制
 */
- (void)insertLiveComment:(AUILiveRoomCommentModel *)comment
     presentedCompulsorily:(BOOL)presentedCompulsorily;

/**
 * 插入普通直播弹幕
 * @param content 弹幕内容
 * @param nick 弹幕发送者昵称
 * @param presentedCompulsorily 是否强制显示，默认不强制
 */
- (void)insertLiveComment:(NSString *)content
         commentSenderNick:(NSString *)nick
           commentSenderID:(NSString *)userID
     presentedCompulsorily:(BOOL)presentedCompulsorily;

// For test
- (void)runAutoCommentInputTest;

@end

NS_ASSUME_NONNULL_END
