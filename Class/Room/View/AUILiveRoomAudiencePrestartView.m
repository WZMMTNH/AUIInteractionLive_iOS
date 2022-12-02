//
//  AUILiveRoomAudiencePrestartView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/8.
//

#import "AUILiveRoomAudiencePrestartView.h"
#import "AUIFoundation.h"
#import "AUIInteractionLiveMacro.h"

@implementation AUILiveRoomAudiencePrestartView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel* label = [[UILabel alloc] initWithFrame:self.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"直播尚未开始～";
        label.font = AVGetRegularFont(16);
        label.textColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        [self addSubview:label];
    }
    return self;
}

@end
