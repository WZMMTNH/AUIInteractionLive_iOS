//
//  AUILiveRoomCommentModel.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomCommentModel.h"
#import "AUIFoundation.h"

@interface AUILiveRoomCommentModel()

@end

@implementation AUILiveRoomCommentModel

- (instancetype) init {
    self = [super init];
    if (self) {
        _sentContentColor = [UIColor whiteColor];
    }
    return self;
}

- (UIColor *)nickColorWithUid:(NSString *)uid {
    static NSArray *_array = nil;
    if (!_array) {
        _array = @[
            [UIColor av_colorWithHexString:@"#FFAB91"],
            [UIColor av_colorWithHexString:@"#FED998"],
            [UIColor av_colorWithHexString:@"#F6A0B5"],
            [UIColor av_colorWithHexString:@"#CBED8E"],
            [UIColor av_colorWithHexString:@"#95D8F8"],
        ];
    }
    
    if (uid.length > 0) {
        unsigned short first = [uid characterAtIndex:0];
        return _array[first % _array.count];
    }
    
    return nil;
}

- (NSAttributedString *)renderContent {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
    
    NSString *nickName = self.senderNick ?: self.senderID;
    if (nickName.length > 0) {
        UIColor *nickColor = self.senderNickColor;
        if (!nickColor) {
            nickColor = [self nickColorWithUid:self.senderID ?: @"2"];
        }
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:[nickName stringByAppendingString:@"："] attributes:@{NSForegroundColorAttributeName:nickColor, NSFontAttributeName:AVGetRegularFont(14.0)}]];
    }
    if (self.sentContent.length > 0) {
        UIColor *nickColor = self.sentContentColor;
        if (!nickColor) {
            nickColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        }
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:self.sentContent attributes:@{NSForegroundColorAttributeName:nickColor, NSFontAttributeName:AVGetRegularFont(14.0)}]];
    }
    return attributeString;
}

@end
