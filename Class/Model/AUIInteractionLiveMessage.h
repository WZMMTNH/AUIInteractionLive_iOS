//
//  AUIInteractionLiveMessage.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/7.
//

#import <Foundation/Foundation.h>
#import "AUIInteractionLiveUser.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUIInteractionLiveMessageType) {
    AUIInteractionLiveMessageTypeComment = 10001,
    AUIInteractionLiveMessageTypeLike,
    AUIInteractionLiveMessageTypeStartLive,
    AUIInteractionLiveMessageTypeStopLive,
    AUIInteractionLiveMessageTypeLiveInfo,
    AUIInteractionLiveMessageTypeNotice,
    
    AUIInteractionLiveMessageTypeApplyLinkMic = 20001,
    AUIInteractionLiveMessageTypeResponseLinkMic,
    AUIInteractionLiveMessageTypeJoinLinkMic,
    AUIInteractionLiveMessageTypeLeaveLinkMic,
    AUIInteractionLiveMessageTypeKickoutLinkMic,
    AUIInteractionLiveMessageTypeCancelApplyLinkMic,
    AUIInteractionLiveMessageTypeMicOpened,
    AUIInteractionLiveMessageTypeCameraOpened,
    AUIInteractionLiveMessageTypeNeedOpenMic,
    AUIInteractionLiveMessageTypeNeedOpenCamera,
};

@interface AUIInteractionLiveMessage : NSObject

@property (nonatomic, copy) NSString *msgId;
@property (nonatomic, assign) AUIInteractionLiveMessageType msgType;

@property (nonatomic, strong) AUIInteractionLiveUser *sender;
@property (nonatomic, copy) NSDictionary *data;

@end

NS_ASSUME_NONNULL_END
