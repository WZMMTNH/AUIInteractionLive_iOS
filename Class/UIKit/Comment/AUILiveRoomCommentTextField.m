//
//  AUILiveRoomCommentTextField.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/11.
//

#import "AUILiveRoomCommentTextField.h"
#import "AUIFoundation.h"

@interface AUILiveRoomCommentTextField () <UITextFieldDelegate>

@property (copy, nonatomic) NSString *inputText;
@property (nonatomic, assign) BOOL isKeyBoardShow;

@end

@implementation AUILiveRoomCommentTextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        self.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
        self.textAlignment = NSTextAlignmentLeft;
        self.keyboardType = UIKeyboardTypeDefault;
        self.returnKeyType = UIReturnKeySend;
        self.delegate = self;
        [self refreshCommentPlaceHolder];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}


- (void)setCommentState:(AUILiveRoomCommentState)commentState {
    if (_commentState == commentState) {
        return;
    }
    
    _commentState = commentState;
    if (_commentState == AUILiveRoomCommentStateMute) {
        self.inputText = self.text;
        self.text = nil;
    }
    else {
        self.text = self.inputText;
        self.inputText = nil;
    }
    
    if (self.isFirstResponder) {
        [self resignFirstResponder];
    }
    else {
        [self refreshCommentPlaceHolder];
    }
}

- (void)refreshCommentPlaceHolder {
    if (self.commentState == AUILiveRoomCommentStateMute) {
        self.attributedPlaceholder = [self commentPlaceHolder:@"已禁言"];
        self.enabled = NO;
    }
    else {
        self.attributedPlaceholder = [self commentPlaceHolder:@"说点什么..."];;
        self.enabled = YES;
    }
}

- (NSAttributedString *)commentPlaceHolder:(NSString *)placeHolder {
    return [[NSAttributedString alloc] initWithString:placeHolder
                                           attributes:@{
        NSForegroundColorAttributeName:[UIColor av_colorWithHexString:@"#B2B7C4"],
        NSFontAttributeName:AVGetRegularFont(16)
    }];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 16, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 16, 0);
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UITextPosition *end = [textField endOfDocument];
        [self setSelectedTextRange:[self textRangeFromPosition:end toPosition:end]];
    });
}

#pragma mark - Notification

- (void)keyBoardWillShow:(NSNotification *)notification {
    if (!self.isFirstResponder) {
        return;
    }
    
    self.isKeyBoardShow = YES;
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:notification.userInfo];
    CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    self.backgroundColor = AUIFoundationColor(@"fill_weak");
    self.textColor = AUIFoundationColor(@"text_strong");
    self.attributedPlaceholder = nil;

    if (self.willEditBlock) {
        self.willEditBlock(self, keyboardEndFrame);
    }
}

- (void)keyBoardWillHide:(NSNotification *)notification {
    if (self.isKeyBoardShow) {
        self.backgroundColor = [UIColor av_colorWithHexString:@"#1C1D22" alpha:0.4];
        self.textColor = [UIColor av_colorWithHexString:@"#B2B7C4"];
        [self refreshCommentPlaceHolder];

        if (self.endEditBlock) {
            self.endEditBlock(self);
        }
        self.isKeyBoardShow = NO;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self resignFirstResponder];
    if (self.text.length > 0) {
        if (self.sendCommentBlock) {
            self.sendCommentBlock(self, self.text);
        }
    }
    self.text = nil;
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
     return YES;
}

@end
