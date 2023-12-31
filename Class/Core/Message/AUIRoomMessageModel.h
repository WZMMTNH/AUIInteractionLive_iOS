//
//  AUIRoomMessageModel.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/7.
//

#import <Foundation/Foundation.h>
#import "AUIRoomUser.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AUIRoomMessageType) {
    AUIRoomMessageTypeComment = 10001,
    AUIRoomMessageTypeLike,
    AUIRoomMessageTypeStartLive,
    AUIRoomMessageTypeStopLive,
    AUIRoomMessageTypeLiveInfo,
    AUIRoomMessageTypeNotice,
    
    AUIRoomMessageTypeApplyLinkMic = 20001,
    AUIRoomMessageTypeResponseLinkMic,
    AUIRoomMessageTypeJoinLinkMic,
    AUIRoomMessageTypeLeaveLinkMic,
    AUIRoomMessageTypeKickoutLinkMic,
    AUIRoomMessageTypeCancelApplyLinkMic,
    AUIRoomMessageTypeMicOpened,
    AUIRoomMessageTypeCameraOpened,
    AUIRoomMessageTypeNeedOpenMic,
    AUIRoomMessageTypeNeedOpenCamera,
    
    AUIRoomMessageTypeGift = 30001,
};

@interface AUIRoomMessageModel : NSObject

@property (nonatomic, copy) NSString *msgId;
@property (nonatomic, assign) AUIRoomMessageType msgType;

@property (nonatomic, strong) AUIRoomUser *sender;
@property (nonatomic, copy) NSDictionary *data;

@end

NS_ASSUME_NONNULL_END
