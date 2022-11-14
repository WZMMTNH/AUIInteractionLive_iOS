//
//  AUILiveRoomCommentModel.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomCommentModel.h"

@interface AUILiveRoomCommentModel()

@property (copy, nonatomic) NSString* fullCommentString;

@end

@implementation AUILiveRoomCommentModel

#pragma mark --Properties

- (void) setSenderNick:(NSString *)senderNick {
    _senderNick = senderNick;
    [self updateDefaultSenderNickColor];
    [self constructFullCommentString];
}

- (void) setSentContent:(NSString *)sentContent {
    _sentContent = sentContent;
    [self constructFullCommentString];
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _sentContentColor = [UIColor whiteColor];
    }
    return self;
}

- (void) constructFullCommentString {
    if (_sentContent.length > 0) {
        if (_senderNick > 0) {
            _fullCommentString = [NSString stringWithFormat:@"%@：%@", _senderNick, _sentContent];
        } else {
            _fullCommentString = [NSString stringWithFormat:@"%@", _sentContent];
        }
    }
}

- (void) updateDefaultSenderNickColor {
    if (_senderNick && !_senderNickColor) {
        NSUInteger senderHash = [_senderNick hash];
        CGFloat hue = (senderHash % 256 / 256.0 );
        CGFloat saturation = (senderHash% 128 / 256.0 ) + 0.5;
        CGFloat brightness = (senderHash% 128 / 256.0 ) + 0.5;
        _senderNickColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    }
}

@end

@implementation AUILiveRoomSystemMessageModel

@end
