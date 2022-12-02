//
//  AUILiveRoomCommentCell.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomCommentCell.h"
#import "AUIFoundation.h"

@interface AUILiveRoomCommentCell()

@property (strong, nonatomic) AVEdgeInsetLabel *commentLabel;

@end

@implementation AUILiveRoomCommentCell

- (void)setCommentModel:(AUILiveRoomCommentModel *)commentModel{
    if (_commentModel == commentModel) {
        return;
    }
    _commentModel = commentModel;
    self.commentLabel.attributedText = commentModel.renderContent;
    [self layoutIfNeeded];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addTapGestureRecognizer];
        [self addLongPressGestureRecognizer];
        
        self.backgroundColor = [UIColor clearColor];
        self.commentLabel = [[AVEdgeInsetLabel alloc] init];
        self.commentLabel.layer.cornerRadius = 2.0;
        self.commentLabel.layer.shouldRasterize = YES; //圆角缓存
        self.commentLabel.layer.masksToBounds = YES;
        self.commentLabel.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.textAlignment = NSTextAlignmentLeft;
        self.commentLabel.textInsets = [self.class commentInsets];
        self.commentLabel.font = AVGetRegularFont(14);
        [self.contentView addSubview:self.commentLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = [self.commentLabel sizeThatFits:CGSizeMake(self.av_width - ([self.class cellInsets].left + [self.class cellInsets].right) - ([self.class commentInsets].left + [self.class commentInsets].right), 0)];
    self.commentLabel.frame = CGRectMake([self.class cellInsets].left, [self.class cellInsets].top, size.width + self.commentLabel.textInsets.left + self.commentLabel.textInsets.right, size.height + [self.class commentInsets].top + [self.class commentInsets].bottom);
}

- (void)addLongPressGestureRecognizer {
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureAction:)];
    recognizer.minimumPressDuration = 1;
    [self.contentView addGestureRecognizer:recognizer];
}

- (void)addTapGestureRecognizer {
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.contentView addGestureRecognizer:recognizer];
}

- (void)longPressGestureAction:(UILongPressGestureRecognizer*)recognizer{
    if ([self.delegate respondsToSelector:@selector(onCommentCellLongPressGesture:commentModel:)]){
        [self.delegate onCommentCellLongPressGesture:recognizer commentModel:self.commentModel];
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer*)recognizer{
    if ([self.delegate respondsToSelector:@selector(onCommentCellTapGesture:commentModel:)]){
        [self.delegate onCommentCellTapGesture:recognizer commentModel:self.commentModel];
    }
}

+ (UIEdgeInsets)commentInsets {
    return UIEdgeInsetsMake(2, 8, 2, 8);
}

+ (UIEdgeInsets)cellInsets {
    return UIEdgeInsetsMake(2, 0, 2, 0);
}

+ (CGFloat)heightWithModel:(AUILiveRoomCommentModel *)commentModel withLimitWidth:(CGFloat)limitWidth {
    CGRect rect = [commentModel.renderContent boundingRectWithSize:CGSizeMake(limitWidth - ([self cellInsets].left + [self cellInsets].right) - ([self commentInsets].left + [self commentInsets].right), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return rect.size.height + [self commentInsets].top + [self commentInsets].bottom + [self cellInsets].top + [self cellInsets].bottom;
}

@end
