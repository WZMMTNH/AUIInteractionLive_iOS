//
//  AUILiveRoomAudiencePrestartView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/8.
//

#import "AUILiveRoomAudiencePrestartView.h"
#import "AUIFoundation.h"
#import "AUIInteractionLiveMacro.h"
#import <Masonry/Masonry.h>

@implementation AUILiveRoomAudiencePrestartView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView* defaultView = [[UIImageView alloc] initWithImage:AUIInteractionLiveGetImage(@"直播未开始")];
        defaultView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:defaultView];
        [defaultView mas_makeConstraints:^(MASConstraintMaker * _Nonnull make) {
            make.center.equalTo(self);
            make.width.equalTo(self.mas_width);
            make.height.equalTo(self.mas_width).multipliedBy(393.0/714.0);
        }];
        
        UILabel* label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"主播尚未开播，请稍后再来～";
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:20];
        label.textColor = [UIColor whiteColor];
        [defaultView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(defaultView);
            make.top.equalTo(defaultView.mas_bottom);
            make.width.equalTo(defaultView);
            make.height.mas_equalTo(47);
        }];
    }
    return self;
}

@end
