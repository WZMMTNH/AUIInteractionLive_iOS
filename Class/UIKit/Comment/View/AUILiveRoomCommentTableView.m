//
//  AUILiveRoomCommentTableView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomCommentTableView.h"
#import "AUILiveRoomCommentCell.h"
#import "AUIFoundation.h"
#import <Masonry/Masonry.h>

#define ReuseableCellId @"CommentViewCell"

@interface AUILiveRoomCommentTableView ()<UITableViewDelegate, UITableViewDataSource, AUILiveRoomCommentCellDelegate>

@property (strong, nonatomic) NSMutableArray<AUILiveRoomCommentModel *> *commentsPresented;
@property (assign, nonatomic) CGFloat maxHeight;
@property (assign, nonatomic) BOOL autoScroll;

@end


@implementation AUILiveRoomCommentTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.maxHeight = frame.size.height;
        self.backgroundColor = UIColor.clearColor;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.showsVerticalScrollIndicator = NO;
        self.dataSource = self;
        self.delegate = self;
        self.contentInset = UIEdgeInsetsMake(8, 0, 8, 0);
        [self registerClass:[AUILiveRoomCommentCell class] forCellReuseIdentifier:ReuseableCellId];
        
        _commentsPresented = [[NSMutableArray alloc] init];
        _autoScroll = YES;
    }
    return self;
}

- (NSUInteger)commentCount {
    return self.commentsPresented.count;
}

- (void)insertNewComment:(AUILiveRoomCommentModel *)comment presentedCompulsorily:(BOOL)presentedCompulsorily {
    comment.height = [AUILiveRoomCommentCell heightWithModel:comment withLimitWidth:self.av_width];
    [self.commentsPresented addObject:comment];
    CGFloat height = MIN(self.contentSize.height + comment.height + self.contentInset.top + self.contentInset.bottom, self.maxHeight);
    if (height < self.maxHeight) {
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(self.av_left, self.av_bottom - height, self.av_width, height);
        }];
    }
    
    [CATransaction begin];
    [self beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.commentsPresented.count - 1 inSection:0];
    [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self endUpdates];
    [CATransaction commit];
    
    if (self.autoScroll || presentedCompulsorily) {
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUILiveRoomCommentModel *model = self.commentsPresented[indexPath.row];
    if (model.height <= 0) {
        model.height = [AUILiveRoomCommentCell heightWithModel:model withLimitWidth:self.av_width];
    }
    return model.height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentsPresented.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AUILiveRoomCommentCell* cell = [self dequeueReusableCellWithIdentifier:ReuseableCellId];
    cell.delegate = self;
    cell.commentModel = self.commentsPresented[indexPath.row];
    return cell;
}

#pragma mark - AUILiveRoomCommentCellDelegate

-(void)onCommentCellLongPressGesture:(UILongPressGestureRecognizer *)recognizer commentModel:(AUILiveRoomCommentModel *)commentModel{
    if(recognizer.state == UIGestureRecognizerStateBegan){
        if([self.commentDelegate respondsToSelector:@selector(onCommentCellTapped:)]){
            [self.commentDelegate onCommentCellTapped:commentModel];
        }
    }
}

-(void)onCommentCellTapGesture:(UITapGestureRecognizer *)recognizer
                       commentModel:(AUILiveRoomCommentModel *)commentModel {
    if([self.commentDelegate respondsToSelector:@selector(onCommentCellTapped:)]){
        [self.commentDelegate onCommentCellTapped:commentModel];
    }
}

@end
