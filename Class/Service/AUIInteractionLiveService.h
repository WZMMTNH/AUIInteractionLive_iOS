//
//  AUIInteractionLiveService.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/8/31.
//

#import <Foundation/Foundation.h>
#import "AUIInteractionLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIInteractionLiveService : NSObject

+ (void)requestWithPath:(NSString *)path bodyDic:(NSDictionary *)bodyDic completionHandler:(void (^)(NSURLResponse *response, id responseObject,  NSError * error))completionHandler;

+ (void)fetchToken:(void(^)(NSString * _Nullable accessToken, NSString * _Nullable refreshToken, NSError * _Nullable error))completed;

+ (void)createLive:(NSString * _Nullable)groupId mode:(NSInteger)mode title:(NSString *)title extend:(NSDictionary * _Nullable)extend completed:(void(^)(AUIInteractionLiveInfoModel * _Nullable model, NSError * _Nullable error))completed;

+ (void)startLive:(NSString *)liveId completed:(void(^)(AUIInteractionLiveInfoModel * _Nullable model, NSError * _Nullable error))completed;

+ (void)stopLive:(NSString *)liveId completed:(void(^)(AUIInteractionLiveInfoModel * _Nullable model, NSError * _Nullable error))completed;

+ (void)fetchLiveList:(NSUInteger)pageNum pageSize:(NSUInteger)pageSize completed:(void(^)(NSArray<AUIInteractionLiveInfoModel *> * _Nullable models, NSError * _Nullable error))completed;

+ (void)fetchLive:(NSString *)liveId userId:(NSString * _Nullable)userId completed:(void(^)(AUIInteractionLiveInfoModel * _Nullable model, NSError * _Nullable error))completed;

+ (void)updateLive:(NSString *)liveId title:(NSString *)title extend:(NSDictionary * _Nullable)extend completed:(void(^)(AUIInteractionLiveInfoModel * _Nullable model, NSError * _Nullable error))completed;

@end

NS_ASSUME_NONNULL_END
