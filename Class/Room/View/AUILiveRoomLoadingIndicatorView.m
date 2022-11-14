//
//  AUILiveRoomLoadingIndicatorView.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveRoomLoadingIndicatorView.h"

@implementation AUILiveRoomLoadingIndicatorView

- (void)show:(BOOL)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hidden = !show;
        if (show) {
            if (!self.isAnimating) {
                [self startAnimating];
            }
        } else {
            if (self.isAnimating) {
                [self stopAnimating];
            }
        }
    });
}

@end
