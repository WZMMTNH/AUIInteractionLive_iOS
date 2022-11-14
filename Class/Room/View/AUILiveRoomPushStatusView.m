//
//  AUILiveRoomPushStatusView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomPushStatusView.h"
#import "AUIFoundation.h"
#import <Masonry/Masonry.h>

@implementation AUILiveRoomPushStatusView

#pragma mark -Properties

- (void)setPushStatus:(AUILiveRoomPushStatus)pushStatus {
    _pushStatus = pushStatus;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (pushStatus == AUILiveRoomPushStatusFluent) {
            self.statusTextLabel.text = @"直播流畅";
            self.statusColorButton.backgroundColor = [UIColor av_colorWithHexString:@"#51C359" alpha:1.0];
        } else if (pushStatus == AUILiveRoomPushStatusStuttering) {
            self.statusTextLabel.text = @"直播卡顿";
            self.statusColorButton.backgroundColor = [UIColor av_colorWithHexString:@"#FFA623" alpha:1.0];
        } else if (pushStatus == AUILiveRoomPushStatusBrokenOff) {
            self.statusTextLabel.text = @"直播中断";
            self.statusColorButton.backgroundColor = [UIColor av_colorWithHexString:@"#FE3143" alpha:1.0];
        }
    });
}

- (UIButton *)statusColorButton {
    if (!_statusColorButton) {
        _statusColorButton = [[UIButton alloc] init];
        _statusColorButton.layer.cornerRadius = 3;
        _statusColorButton.clipsToBounds = YES;
        _statusColorButton.backgroundColor = [UIColor av_colorWithHexString:@"#51C359" alpha:1.0];
        [self addSubview:_statusColorButton];
        [_statusColorButton mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.width.mas_equalTo(6);
            make.height.mas_equalTo(6);
            make.left.equalTo(self.mas_left);
            make.centerY.equalTo(self.mas_centerY);
        }];
    }
    return _statusColorButton;
}

- (UILabel *)statusTextLabel {
    if (!_statusTextLabel) {
        _statusTextLabel = [[UILabel alloc] init];
        _statusTextLabel.text = @"直播中断";
        _statusTextLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        [self addSubview:_statusTextLabel];
        [_statusTextLabel mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.width.mas_equalTo(52);
            make.height.mas_equalTo(18);
            make.right.equalTo(self.mas_right).with.offset(-12);
            make.centerY.equalTo(self.mas_centerY);
        }];
    }
    return _statusTextLabel;
}

#pragma mark -Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [self bringSubviewToFront:self.statusColorButton];
        [self bringSubviewToFront:self.statusTextLabel];
    }
    return self;
}

@end
