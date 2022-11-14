//
//  AUILiveRoomAnchorBottomView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomAnchorBottomView.h"
#import "AUILiveRoomLikeButton.h"
#import "AUIFoundation.h"
#import "AUIInteractionLiveMacro.h"
#import <Masonry/Masonry.h>

@interface AUILiveRoomAnchorBottomView() <UITextFieldDelegate>

@property (strong, nonatomic) UITextField* commentInputField;
@property (strong, nonatomic) UIButton* shareButton;
@property (strong, nonatomic) AUILiveRoomLikeButton* likeButton;
@property (strong, nonatomic) UIButton* beautyButton;
@property (strong, nonatomic) UIButton* moreInteractionButton;

@property (assign, nonatomic) BOOL rotated;

@end

@implementation AUILiveRoomAnchorBottomView

- (void)setCommentState:(AUILiveRoomAnchorBottomCommentState)commentState {
    if (_commentState == commentState) {
        return;
    }
    
    _commentState = commentState;
    _commentInputField.text = @"";
    if (_commentState == AUILiveRoomAnchorBottomCommentStateBeenMuteAll) {
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"你已开启全员禁言"
                                                                         attributes:@{
                                                                             NSForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:0.8],
                                                                             NSFontAttributeName:[UIFont systemFontOfSize:14]
                                                                         }];
        _commentInputField.attributedPlaceholder = attrString;
        _commentInputField.enabled = NO;
    }
    else {
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"说点什么……"
                                                                         attributes:@{
                                                                             NSForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:0.8],
                                                                             NSFontAttributeName:[UIFont systemFontOfSize:14]
                                                                         }];
        _commentInputField.attributedPlaceholder = attrString;
        _commentInputField.enabled = YES;
    }
}

- (UITextField *)commentInputField {
    if (!_commentInputField) {
        UITextField* textField = [[UITextField alloc] init];
        [self addSubview:textField];
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).with.offset(-9);
            make.left.equalTo(self.mas_left).with.offset(10);
            make.right.equalTo(self.shareButton.mas_left).with.offset(-10);
            make.height.mas_equalTo(40);
        }];
        textField.layer.masksToBounds = YES;
        textField.layer.cornerRadius = 20;
        textField.textColor = [UIColor blackColor];
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"说点什么……"
                                                                         attributes:@{
                                                                             NSForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:0.8],
                                                                             NSFontAttributeName:[UIFont systemFontOfSize:14]
                                                                         }];
        textField.attributedPlaceholder = attrString;
        textField.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
        textField.textAlignment = NSTextAlignmentLeft;
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeySend;
        textField.keyboardAppearance = UIKeyboardAppearanceDefault;
        textField.delegate = self;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.layer.borderColor = [UIColor.whiteColor colorWithAlphaComponent:0.3].CGColor;
        textField.layer.borderWidth = 1.0;
        [textField setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        _commentInputField = textField;
    }
    return _commentInputField;
}

- (UIButton *)beautyButton {
    if (!_beautyButton) {
        UIButton* button = [[UIButton alloc] init];
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.moreInteractionButton.mas_left).with.offset(-10);
            make.centerY.equalTo(self.moreInteractionButton);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(40);
        }];
        [button setImage:AUIInteractionLiveGetImage(@"直播-互动区-美颜") forState:UIControlStateNormal];
        [button setAdjustsImageWhenHighlighted:NO];
        [button addTarget:self action:@selector(beautyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _beautyButton = button;
    }
    return _beautyButton;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        UIButton* button = [[UIButton alloc] init];
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.likeButton.mas_left).with.offset(-10);
            make.centerY.equalTo(self.likeButton);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(40);
        }];
        [button setImage:AUIInteractionLiveGetImage(@"直播-互动区-分享") forState:UIControlStateNormal];
        [button setAdjustsImageWhenHighlighted:NO];
        [button addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _shareButton = button;
    }
    return _shareButton;
}

- (UIButton *)likeButton {
    if (!_likeButton) {
        AUILiveRoomLikeButton* button = [[AUILiveRoomLikeButton alloc] init];
        [self addSubview:button];
        
        __weak typeof(self) weakSelf = self;
        button.onLikeSent = ^{
            [weakSelf.actionsDelegate onLikeSent];
        };
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.beautyButton.mas_left).with.offset(-10);
            make.centerY.equalTo(self.beautyButton);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(40);

        }];
        [button setImage:AUIInteractionLiveGetImage(@"直播-互动区-点赞") forState:UIControlStateNormal];
        [button setAdjustsImageWhenHighlighted:NO];
        _likeButton = button;
    }
    return _likeButton;
}

- (UIButton *)moreInteractionButton {
    if (!_moreInteractionButton) {
        UIButton* button = [[UIButton alloc] init];
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).with.offset(-9);
            make.right.equalTo(self.mas_right).with.offset(-10);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(40);
        }];
        [button setImage:AUIInteractionLiveGetImage(@"直播-互动区-更多") forState:UIControlStateNormal];
        [button setAdjustsImageWhenHighlighted:NO];
        [button addTarget:self action:@selector(moreInteractionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _moreInteractionButton = button;
    }
    return _moreInteractionButton;
}

#pragma mark --Lifecycle

- (instancetype) init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        [self addSubview:self.commentInputField];
        [self addSubview:self.beautyButton];
        [self addSubview:self.shareButton];
        [self addSubview:self.likeButton];
        [self addSubview:self.moreInteractionButton];
    }
    
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark --Methods

- (void)updateLayoutRotated:(BOOL)rotated{
    self.rotated = rotated;
    
    if (!rotated){
        [self.commentInputField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).with.offset(-9);
            make.left.equalTo(self.mas_left).with.offset(10);
            make.right.equalTo(self.shareButton.mas_left).with.offset(-10);
            make.height.mas_equalTo(40);
        }];
        return;
    }
    
    [self.commentInputField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).with.offset(-9);
        make.left.equalTo(self.mas_left).with.offset(10);
        make.width.mas_equalTo(250);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark --UIButton Selectors

- (void)beautyButtonAction:(UIButton *)sender {
    [self.actionsDelegate onBeautyButtonClicked];
}

- (void)moreInteractionButtonAction:(UIButton *)sender {
    [self.actionsDelegate onMoreInteractionButtonClicked];
}

- (void)shareButtonAction:(UIButton *)sender {
    [self.actionsDelegate onShareButtonClicked];
}

#pragma mark --UITextFieldDelegate

- (void)keyBoardWillShow:(NSNotification *)note {
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGFloat keyBoardHeight = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    if(self.commentInputField.isEditing){
        self.commentInputField.layer.cornerRadius = 2;
        self.commentInputField.backgroundColor = [UIColor whiteColor];
        self.commentInputField.textColor = [UIColor blackColor];
        [self.commentInputField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.bottom.equalTo(self.superview ? : self).offset(-keyBoardHeight);
            make.height.mas_equalTo(40);
        }];
        [self layoutIfNeeded];
    }
}

- (void)keyBoardWillHide:(NSNotification *)note {

    self.commentInputField.transform = CGAffineTransformIdentity;
    self.commentInputField.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
    self.commentInputField.layer.cornerRadius = 20;
    self.commentInputField.textColor = [UIColor whiteColor];
    [self.commentInputField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).with.offset(-9);
        make.left.equalTo(self).with.offset(10);
        if (!_rotated){ // 竖屏
            make.right.equalTo(self.shareButton.mas_left).with.offset(-10);
        } else{ // 横屏
            make.width.mas_equalTo(250);
        }
        make.height.mas_equalTo(40);
    }];
    [self layoutIfNeeded];
}

#pragma mark --UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.commentInputField resignFirstResponder];    //主要是[receiver resignFirstResponder]在哪调用就能把receiver对应的键盘往下收

    if (textField.text.length > 0) {
        [self.actionsDelegate onCommentSent:textField.text];
    }
    self.commentInputField.text = nil;
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
     return YES;
}

// 重写该方法，使超出此view的输入框能响应点击事件
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (self.commentInputField.isEditing) {
        CGPoint tempPoint = [self.commentInputField convertPoint:point fromView:self];
        if ([self.commentInputField pointInside:tempPoint withEvent:event]) {
            return self.commentInputField;
        }
    }
    if (!view) {
        [self.commentInputField resignFirstResponder];
    }
    return view;
}

@end
