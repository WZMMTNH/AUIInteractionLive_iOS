//
//  AUILiveRoomAnchorPrestartView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomAnchorPrestartView.h"
#import "AUIFoundation.h"
#import "AUIInteractionLiveMacro.h"
#import <Masonry/Masonry.h>


@interface AUILiveRoomAnchorPrestartView()

@end

@implementation AUILiveRoomAnchorPrestartView

- (UIButton *)startLiveButton {
    if (!_startLiveButton) {
        UIButton* button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(startLiveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 25;
        button.backgroundColor = [UIColor av_colorWithHexString:@"#FF8E19" alpha:1];
        [button setTitle:@"开始直播" forState:UIControlStateNormal];
        button.titleLabel.textColor = [UIColor whiteColor];
        button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20];
        [self addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.centerX.equalTo(self);
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).with.offset(-150);
            } else {
                make.bottom.equalTo(self.mas_bottom).with.offset(-150);
            }
            make.width.mas_equalTo(246);
            make.height.mas_equalTo(50);
        }];
        
        _startLiveButton = button;
    }
    return _startLiveButton;
}

- (UIButton *)switchCameraButton {
    if (!_switchCameraButton) {
        UIButton* button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(switchCameraButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.imageView.contentMode = UIViewContentModeScaleAspectFill;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        [button setImage:AUIInteractionLiveGetImage(@"icon-camera_switch") forState:UIControlStateNormal];
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.centerX.equalTo(self).with.offset(-80);
            make.bottom.equalTo(self.startLiveButton.mas_top).with.offset(-47);
            make.width.mas_equalTo(36);
            make.height.mas_equalTo(32);
        }];
        
        [button addSubview:({
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(-10, 36, 60, 18)];
            label.textAlignment = NSTextAlignmentCenter;
            label.adjustsFontSizeToFitWidth = YES;
            label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
            label.textColor = [UIColor whiteColor];
            label.text = @"翻转";
            label;
        })];
        
        _switchCameraButton = button;
    }
    return _switchCameraButton;
    
}

- (UIButton *)beautyButton {
    if (!_beautyButton) {
        UIButton* button = [[UIButton alloc] init];
        [button addTarget:self action:@selector(beautyButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [button setImage:AUIInteractionLiveGetImage(@"icon-beauty_white") forState:UIControlStateNormal];
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.centerX.equalTo(self).with.offset(80);
            make.bottom.equalTo(self.startLiveButton.mas_top).with.offset(-47);
            make.width.mas_equalTo(36);
            make.height.mas_equalTo(36);
        }];
        
        [button addSubview:({
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(-10, 40, 60, 18)];
            label.textAlignment = NSTextAlignmentCenter;
            label.adjustsFontSizeToFitWidth = YES;
            label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
            label.textColor = [UIColor whiteColor];
            label.text = @"美颜";
            label;
        })];
        _beautyButton = button;
    }
    return _beautyButton;
}

#pragma mark -Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [self bringSubviewToFront:self.startLiveButton];
        [self bringSubviewToFront:self.switchCameraButton];
        [self bringSubviewToFront:self.beautyButton];
    }
    return self;
}

// 横屏
- (void)updateLayoutRotated:(BOOL)rotated {
    if (rotated) {
        [self.startLiveButton mas_remakeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.centerX.equalTo(self);
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).with.offset(-10);
            } else {
                make.bottom.equalTo(self.mas_bottom).with.offset(-10);
            }
            make.width.mas_equalTo(246);
            make.height.mas_equalTo(50);
        }];
    }
}

#pragma mark -UIButton Selectors
- (void)startLiveButtonAction:(UIButton*)sender {
    if ([self.delegate respondsToSelector:@selector(onPrestartStartLiveButtonClicked)]) {
        [self.delegate onPrestartStartLiveButtonClicked];
    }
    [sender setTitle:@"加载中  " forState:UIControlStateNormal];
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(140, 0, 50, 50)];
    spinner.color = [UIColor whiteColor];
    spinner.tintColor = [UIColor whiteColor];
    [sender addSubview:spinner];
    [spinner startAnimating];
    sender.userInteractionEnabled = NO;
    sender.alpha = 0.8;
}

- (void)switchCameraButtonAction:(UIButton*)sender {
    if ([self.delegate respondsToSelector:@selector(onPrestartSwitchCameraButtonClicked)]) {
        [self.delegate onPrestartSwitchCameraButtonClicked];
    }
}

- (void)beautyButtonAction:(UIButton*)sender {
    if ([self.delegate respondsToSelector:@selector(onPrestartBeautyButtonClicked)]) {
        [self.delegate onPrestartBeautyButtonClicked];
    }
}

@end
