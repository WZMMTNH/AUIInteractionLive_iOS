//
//  AUILiveRoomCommentView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomCommentView.h"
#import "AUILiveRoomCommentTableView.h"
#import "AUIFoundation.h"


@interface AUILiveRoomCommentView() <AUILiveRoomCommentTableViewDelegate>

@property (strong, nonatomic) AUILiveRoomCommentTableView *internalCommentView;

@end

@implementation AUILiveRoomCommentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _internalCommentView = [[AUILiveRoomCommentTableView alloc] initWithFrame:self.bounds];
        _internalCommentView.commentDelegate = self;
        [self addSubview:_internalCommentView];
        
        AUILiveRoomCommentModel* model = [[AUILiveRoomCommentModel alloc] init];
        model.sentContent = @"欢迎来到直播间，直播内容和评论禁止政治、低俗色情、吸烟酗酒或发布虚假信息等内容，若有违反将禁播、封停账号。";
        model.sentContentColor = [UIColor av_colorWithHexString:@"#A4E0A7"];
        [_internalCommentView insertNewComment:model presentedCompulsorily:YES];
    }
    return self;
}

#pragma mark -Public Methods

- (NSUInteger)commentCount {
    return self.internalCommentView.commentCount;
}

- (void)insertLiveComment:(AUILiveRoomCommentModel *)comment
    presentedCompulsorily:(BOOL)presentedCompulsorily {
    [self.internalCommentView insertNewComment:comment presentedCompulsorily:presentedCompulsorily];
}

- (void)insertLiveComment:(NSString *)content
        commentSenderNick:(NSString *)nick
          commentSenderID:(NSString *)userID
    presentedCompulsorily:(BOOL)presentedCompulsorily {
    AUILiveRoomCommentModel* model = [[AUILiveRoomCommentModel alloc] init];
    model.senderID = userID;
    model.senderNick = nick;
    model.sentContent = content;
    
    [self insertLiveComment:model presentedCompulsorily:presentedCompulsorily];
}

- (void)runAutoCommentInputTest {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(arc4random() % 1000 / 500.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *string = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
        NSUInteger count = string.length;
        NSMutableString *nick = [NSMutableString new];
        NSUInteger nickLength = arc4random() % 10;
        for (NSUInteger i=0; i<nickLength; i++) {
            [nick appendString:[string substringWithRange:NSMakeRange(arc4random()%count, 1)]];
        }
        
        NSMutableString *comment = [NSMutableString new];
        NSUInteger commentLength = arc4random() % 50;
        for (NSUInteger i=0; i<commentLength; i++) {
            [comment appendString:[string substringWithRange:NSMakeRange(arc4random()%count, 1)]];
        }
        
        [self insertLiveComment:comment commentSenderNick:nick commentSenderID:nick presentedCompulsorily:YES];
        
        if (self.internalCommentView.commentCount < 50) {
            [self runAutoCommentInputTest];
        }
    });
}

#pragma mark -AUILiveRoomCommentTableViewDelegate

-(void)onCommentCellLongPressed:(AUILiveRoomCommentModel *)commentModel {

}

-(void)onCommentCellTapped:(AUILiveRoomCommentModel *)commentModel {

}

@end
