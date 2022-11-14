//
//  AUILiveRoomInfoView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomInfoView.h"
#import <Masonry/Masonry.h>

@implementation AUILiveRoomInfoView


- (UIImageView *)anchorAvatarView {
    if (!_anchorAvatarView) {
        UIImageView* imageView = [[UIImageView alloc] init];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 18.25;
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.left.equalTo(self.mas_left).with.offset(2);
            make.top.equalTo(self.mas_top).with.offset(3);
            make.size.mas_equalTo(CGSizeMake(36.5, 36.5));
        }];
        _anchorAvatarView = imageView;
    }
    return _anchorAvatarView;
}

- (UILabel *)anchorNickLabel {
    if(!_anchorNickLabel){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(48, 6, 117, 17)];
        label.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14];
        label.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0/1.0];
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.left.equalTo(self.mas_left).with.offset(48);
            make.top.equalTo(self.mas_top).with.offset(6);
            make.size.mas_equalTo(CGSizeMake(117, 17));
        }];
        _anchorNickLabel = label;
    }
    return _anchorNickLabel;
}

- (UILabel *)pvLabel {
    if(!_pvLabel){
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
        label.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0/1.0];
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.left.equalTo(self.mas_left).with.offset(47);
            make.top.equalTo(self.mas_top).with.offset(24);
            make.size.mas_equalTo(CGSizeMake(43, 14));
        }];
        _pvLabel = label;
    }
    return _pvLabel;
}

- (UILabel *)likeCountLabel {
    if(!_likeCountLabel){
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
        label.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0/1.0];
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.left.equalTo(self.pvLabel.mas_right).with.offset(5);
            make.top.equalTo(self.mas_top).with.offset(24);
            make.size.mas_equalTo(CGSizeMake(43, 14));
        }];
        _likeCountLabel = label;
    }
    return _likeCountLabel;
}

- (void)updateLikeCount:(NSInteger)count {
    if (count < 0) {
        self.likeCountLabel.text = @"0点赞";
    } else if (count < 10000) {
        self.likeCountLabel.text = [NSString stringWithFormat:@"%zd点赞", count];
    } else {
        self.likeCountLabel.text = [NSString stringWithFormat:@"%.1f万点赞", count * 1.0 / 10000.0];
    }
    
    CGSize sizeNew = [self.likeCountLabel.text sizeWithAttributes:@{NSFontAttributeName:self.likeCountLabel.font}];
    [self.likeCountLabel mas_updateConstraints:^(MASConstraintMaker * _Nonnull make) {
        make.width.mas_equalTo(sizeNew.width + 18);
    }];
}

- (void)updatePV:(NSInteger)pv {
    if (pv < 0) {
        self.pvLabel.text = @"0观看";
    } else if (pv < 10000) {
        self.pvLabel.text = [NSString stringWithFormat:@"%zd观看", pv];
    } else {
        self.pvLabel.text = [NSString stringWithFormat:@"%.1f万观看", pv * 1.0 / 10000.0];
    }
    
    CGSize sizeNew = [self.pvLabel.text sizeWithAttributes:@{NSFontAttributeName:self.pvLabel.font}];
    [self.pvLabel mas_updateConstraints:^(MASConstraintMaker * _Nonnull make) {
        make.width.mas_equalTo(sizeNew.width + 18);
    }];
}

@end
