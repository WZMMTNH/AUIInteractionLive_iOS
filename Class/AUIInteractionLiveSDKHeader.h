//
//  AUIInteractionLiveSDKHeader.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/4.
//

#ifndef AUIInteractionLiveSDKHeader_h
#define AUIInteractionLiveSDKHeader_h


#if __has_include(<AliVCSDK_Premium/AliVCSDK_Premium.h>)
#import <AliVCSDK_Premium/AliVCSDK_Premium.h>
#elif __has_include(<AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>)
#import <AliVCSDK_InteractiveLive/AliVCSDK_InteractiveLive.h>
#elif __has_include(<AliVCSDK_PremiumLive/AliVCSDK_PremiumLive.h>)
#import <AliVCSDK_PremiumLive/AliVCSDK_PremiumLive.h>
#endif

#if __has_include(<Queen/Queen.h>)
#import <Queen/Queen.h>
#endif

#import <AliyunPlayer/AliyunPlayer.h>

#import <AlivcInteraction/AlivcInteraction.h>

#endif /* AUIInteractionLiveSDKHeader_h */
