//
//  AUILiveRoomLiveDisplayLayoutView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/28.
//

#import "AUILiveRoomLiveDisplayLayoutView.h"
#import "AUIFoundation.h"

@interface AUILiveRoomLiveDisplayView ()

@property (nonatomic, strong) UIView *renderView;
@property (nonatomic, strong) UILabel *nickNameLabel;

@property (nonatomic, assign) BOOL showBorder;
@property (nonatomic, assign) BOOL showRadius;
@property (nonatomic, assign) BOOL showNickName;

@end

@implementation AUILiveRoomLiveDisplayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _renderView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_renderView];
        
        _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nickNameLabel.font = AVGetMediumFont(10);
        _nickNameLabel.textColor = UIColor.whiteColor;
        _nickNameLabel.backgroundColor = [UIColor.orangeColor colorWithAlphaComponent:0.5];
        _nickNameLabel.layer.cornerRadius = 2;
        _nickNameLabel.layer.masksToBounds = YES;
        [self addSubview:_nickNameLabel];
        
        self.backgroundColor = UIColor.blackColor;
        self.layer.masksToBounds = YES;
        self.showBorder = NO;
        self.showNickName = NO;
        self.showRadius = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _renderView.frame = self.bounds;
    [_nickNameLabel sizeToFit];
    _nickNameLabel.av_left = 4;
    _nickNameLabel.av_top = self.av_height - _nickNameLabel.av_height - 4;
}

- (void)setNickName:(NSString *)nickName {
    if ([_nickName isEqualToString:nickName]) {
        return;
    }
    _nickName = nickName;
    _nickNameLabel.text = _nickName;
    [self setNeedsLayout];
}

- (void)setShowBorder:(BOOL)showBorder {
    _showBorder = showBorder;
    if (_showBorder) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor.cyanColor colorWithAlphaComponent:0.5].CGColor;
    }
    else {
        self.layer.borderWidth = 0;
        self.layer.borderColor = [UIColor.whiteColor colorWithAlphaComponent:0.5].CGColor;
    }
}

- (void)setShowRadius:(BOOL)showRadius {
    _showRadius = showRadius;
    if (_showRadius) {
        self.layer.cornerRadius = 4;
    }
    else {
        self.layer.cornerRadius = 0;
    }
}

- (void)setShowNickName:(BOOL)showNickName {
    _showNickName = showNickName;
    self.nickNameLabel.hidden = !showNickName;
}

@end



@interface AUILiveRoomLiveDisplayLayoutView ()

@property (nonatomic, strong) NSMutableArray<AUILiveRoomLiveDisplayView *> *viewList;
@property (nonatomic, strong) UIScrollView *scrollView;


@end

@implementation AUILiveRoomLiveDisplayLayoutView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
//        _scrollView.bounces = NO;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
//        _scrollView.alwaysBounceVertical = YES;
//        _scrollView.alwaysBounceHorizontal = YES;
        [self addSubview:_scrollView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
}

- (NSMutableArray<AUILiveRoomLiveDisplayView *> *)viewList {
    if (!_viewList) {
        _viewList = [NSMutableArray array];
    }
    return _viewList;
}

- (void)insertDisplayView:(AUILiveRoomLiveDisplayView *)displayView atIndex:(NSUInteger)index {
    if ([self.viewList containsObject:displayView]) {
        return;
    }
    [self.scrollView insertSubview:displayView atIndex:index];
    [self.viewList insertObject:displayView atIndex:index];
}

- (void)addDisplayView:(AUILiveRoomLiveDisplayView *)displayView {
    if ([self.viewList containsObject:displayView]) {
        return;
    }
    [self.scrollView addSubview:displayView];
    [self.viewList addObject:displayView];
}

- (void)removeDisplayView:(AUILiveRoomLiveDisplayView *)displayView {
    [displayView removeFromSuperview];
    [self.viewList removeObject:displayView];
}

- (CGRect)renderRect:(AUILiveRoomLiveDisplayView *)displayView {
    CGRect rect = [self displayRect1:displayView];
    CGFloat ver_scale = self.resolution.width / self.scrollView.bounds.size.width;
    CGFloat hor_scale = self.resolution.height / self.scrollView.bounds.size.height;
    return CGRectMake(rect.origin.x * ver_scale, rect.origin.y * hor_scale, rect.size.width * ver_scale, rect.size.height * hor_scale);
}

- (CGRect)displayRect1:(AUILiveRoomLiveDisplayView *)displayView {
    if (![self.viewList containsObject:displayView]) {
        return CGRectZero;
    }
    if (self.viewList.count == 1) {
        return self.scrollView.bounds;
    }
    NSUInteger index = [self.viewList indexOfObject:displayView];
    if (index >= 16) {
        return CGRectZero;
    }
    if (self.viewList.count == 2) {
        if (index == 0) {
            return self.scrollView.bounds;
        }
        CGFloat width = CGRectGetWidth(self.scrollView.bounds) / 4.0;
        CGFloat height = width * self.resolution.height / self.resolution.width;
        return CGRectMake(CGRectGetMaxX(self.scrollView.bounds) - 16 - width, CGRectGetMaxY(self.scrollView.bounds) - 240 - 16 - height, width, height);
    }
    
    NSInteger count_per_line = 4;
    if (self.viewList.count <= 4) {
        count_per_line = 2;
    }
    else if (self.viewList.count <= 9) {
        count_per_line = 3;
    }
    
    CGFloat left = 5;
    CGFloat margin = 1;
    CGFloat width = (CGRectGetWidth(self.scrollView.bounds) - left * 2 - margin) / count_per_line;
    CGFloat height = width;
    CGFloat top = (CGRectGetHeight(self.scrollView.bounds) - margin * (count_per_line - 1) - height * count_per_line) / 2;
    NSUInteger hor_pos = index % count_per_line;
    NSUInteger ver_pos = index / count_per_line;
    return CGRectMake(left + hor_pos * (width + margin), top + ver_pos * (height + margin), width, height);
}

- (void)updateScrollViewContentSize1 {
    self.scrollView.contentSize = CGSizeMake(self.scrollView.av_width, self.scrollView.av_height);
}

- (CGRect)displayRect2:(AUILiveRoomLiveDisplayView *)displayView {
    if (![self.viewList containsObject:displayView]) {
        return CGRectZero;
    }
    if (self.viewList.count == 1) {
        return self.scrollView.bounds;
    }
    NSUInteger index = [self.viewList indexOfObject:displayView];
    if (self.viewList.count == 2) {
        if (index == 0) {
            return self.scrollView.bounds;
        }
        CGFloat width = CGRectGetWidth(self.scrollView.bounds) / 4.0;
        CGFloat height = width * self.resolution.height / self.resolution.width;
        return CGRectMake(CGRectGetMaxX(self.scrollView.bounds) - 16 - width, CGRectGetMaxY(self.scrollView.bounds) - 240 - 16 - height, width, height);
    }
    
    // 1行2个
    CGFloat left = 5;
    CGFloat margin = 1;
    CGFloat width = (CGRectGetWidth(self.scrollView.bounds) - left * 2 - margin) / 2.0;
    CGFloat height = width;
    CGFloat top = (CGRectGetHeight(self.scrollView.bounds) - margin - height * 2) / 2.0;
    NSUInteger hor_pos = index % 2;
    NSUInteger ver_pos = index / 2;
    return CGRectMake(left + hor_pos * (width + margin), top + ver_pos * (height + margin), width, height);
}

- (void)updateScrollViewContentSize2 {
    if (self.viewList.count > 2) {
        CGFloat left = 5;
        CGFloat margin = 1;
        CGFloat width = (CGRectGetWidth(self.scrollView.bounds) - left * 2 - margin) / 2.0;
//        CGFloat height = width * self.resolution.height / self.resolution.width;
        CGFloat height = width;
        CGFloat top = (CGRectGetHeight(self.scrollView.bounds) - margin - height * 2) / 2.0;
        NSUInteger ver_count = (self.viewList.count + 1) / 2;
        self.scrollView.contentSize = CGSizeMake(self.scrollView.av_width, height * ver_count + margin * (ver_count - 1) + top * 2);
    }
    else {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.av_width, self.scrollView.av_height);
    }
}

- (void)layoutAll {
    
    [self updateScrollViewContentSize1];
    [self.viewList enumerateObjectsUsingBlock:^(AUILiveRoomLiveDisplayView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = [self displayRect1:obj];
        [obj layoutSubviews];
        if (obj.onLayoutUpdated) {
            obj.onLayoutUpdated();
        }
        
        if (self.viewList.count == 1) {
            obj.showBorder = NO;
            obj.showRadius = NO;
            obj.showNickName = NO;
        }
        else if (self.viewList.count == 2) {
            if (idx == 0) {
                obj.showBorder = NO;
                obj.showRadius = NO;
                obj.showNickName = NO;
            }
            else {
                obj.showBorder = YES;
                obj.showRadius = YES;
                obj.showNickName = YES;
            }
        }
        else {
            obj.showBorder = YES;
            obj.showRadius = YES;
            obj.showNickName = YES;
        }
    }];
}

@end
