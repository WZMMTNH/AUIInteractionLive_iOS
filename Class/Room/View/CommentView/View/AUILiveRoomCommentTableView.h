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

- (void)actionWhenCommentCellLongPressed:(AUILiveRoomCommentModel *)commentModel;
- (void)actionWhenCommentCellTapped:(AUILiveRoomCommentModel *)commentModel;
- (void)actionWhenUnpresentedCommentCountChange:(NSInteger)count;
- (void)actionWhenOneCommentPresentedWithActualHeight:(CGFloat)height;
- (void)actionWhenCommentJustAboutToPresent:(AUILiveRoomCommentModel *)model;

@end

@interface AUILiveRoomCommentTableView : UITableView

@property(nonatomic, weak) id<AUILiveRoomCommentTableViewDelegate> commentDelegate;

- (void)insertNewComment:(AUILiveRoomCommentModel*)comment presentedCompulsorily:(BOOL)presentedCompulsorily;

- (void)scrollToNewestComment;

- (void) startPresenting;
- (void) stopPresenting;

@end

NS_ASSUME_NONNULL_END
