//
//  AUILiveBlockButton.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/2.
//

#import "AUILiveBlockButton.h"

@interface AUILiveBlockButton ()

@property (nonatomic, strong) NSMutableDictionary *borderColorDict;

@end

@implementation AUILiveBlockButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setClickBlock:(void (^)(AUILiveBlockButton * _Nonnull))clickBlock {
    _clickBlock = clickBlock;
    if (clickBlock) {
        [self addTarget:self action:@selector(onClickAction) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [self removeTarget:self action:@selector(onClickAction) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)onClickAction {
    if (self.clickBlock) {
        self.clickBlock(self);
    }
}

- (NSMutableDictionary *)borderColorDict {
    if (!_borderColorDict) {
        _borderColorDict = [NSMutableDictionary dictionary];
    }
    return _borderColorDict;
}

- (void)updateBorderColor {
    NSUInteger state = UIControlStateNormal;
    if (self.isSelected) {
        state = state | UIControlStateSelected;
    }
    if (self.isHighlighted) {
        state = state | UIControlStateHighlighted;
    }
    if (!self.isEnabled) {
        state = state | UIControlStateDisabled;
    }
    UIColor *borderColor = [self.borderColorDict objectForKey:@(state)] ?: [self.borderColorDict objectForKey:@(UIControlStateNormal)];
    self.layer.borderColor = [borderColor CGColor];

}

- (void)setBorderColor:(UIColor *)color forState:(UIControlState)state {
    [self.borderColorDict setObject:color forKey:@(state)];
    [self updateBorderColor];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    [self updateBorderColor];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [self updateBorderColor];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    [self updateBorderColor];
}



@end
