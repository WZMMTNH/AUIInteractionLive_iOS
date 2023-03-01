//
//  AUIRoomBeautyController.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/4.
//

#import <UIKit/UIKit.h>
#import "AUIRoomSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIRoomBeautyController : NSObject

- (instancetype)initWithPresentView:(UIView *)presentView contextMode:(BOOL)contextMode;

- (void)setupBeautyController;
- (void)destroyBeautyController;

- (void)detectVideoBuffer:(long)buffer withWidth:(int)width withHeight:(int)height withVideoFormat:(AlivcLivePushVideoFormat)videoFormat withPushOrientation:(AlivcLivePushOrientation)pushOrientation;

// contextMode=NO进行处理
- (int)processGLTextureWithTextureID:(int)textureID withWidth:(int)width withHeight:(int)height;

// contextMode=YES进行处理
- (BOOL)processPixelBuffer:(CVPixelBufferRef)pixelBufferRef withPushOrientation:(AlivcLivePushOrientation)pushOrientation;

- (void)showPanel:(BOOL)animated;

+ (void)setupMotionManager;
+ (void)destroyMotionManager;

@end

NS_ASSUME_NONNULL_END
