//
//  AUILiveDetailButton.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/1.
//

#import "AUILiveBlockButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveDetailButton : AUILiveBlockButton

@property (strong, nonatomic) NSString *text;

-(instancetype)initWithFrame:(CGRect)frame image:(UIImage *)image title:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
