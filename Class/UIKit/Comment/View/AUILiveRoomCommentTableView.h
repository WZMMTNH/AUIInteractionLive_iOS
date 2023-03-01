//
//  AUILiveRoomCommentTableView.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import <UIKit/UIKit.h>
#import "AUILiveRoomCommentModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AUILiveRoomCommentTableViewDelegate <NSObject>

- (void)onCommentCellLongPressed:(AUILiveRoomCommentModel *)commentModel;
- (void)onCommentCellTapped:(AUILiveRoomCommentModel *)commentModel;

@end

@interface AUILiveRoomCommentTableView : UITableView

@property(nonatomic, weak) id<AUILiveRoomCommentTableViewDelegate> commentDelegate;
@property(nonatomic, assign, readonly) NSUInteger commentCount;

- (void)insertNewComment:(AUILiveRoomCommentModel*)comment
   presentedCompulsorily:(BOOL)presentedCompulsorily;

@end

NS_ASSUME_NONNULL_END
