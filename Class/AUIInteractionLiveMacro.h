//
//  AUIInteractionLiveMacro.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/14.
//

#ifndef AUIInteractionLiveMacro_h
#define AUIInteractionLiveMacro_h

#import "AUIFoundation.h"

#define AUIInteractionLiveGetImage(key) AVGetImage(key, @"AUIInteractionLive")
#define AUIInteractionLiveGetCommonImage(key) AVGetCommonImage(key, @"AUIInteractionLive")
#define AUIInteractionLiveGetString(key) AVGetString(key, @"AUIInteractionLive")

#define AUIInteractionLiveColourfulFillStrong [UIColor av_colorWithHexString:@"#FF5722"]
#define AUIInteractionLiveColourfulFillDisable [UIColor av_colorWithHexString:@"#FFCCBC"]

#endif /* AUIInteractionLiveMacro_h */
