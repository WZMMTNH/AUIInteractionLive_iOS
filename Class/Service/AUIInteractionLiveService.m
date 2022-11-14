//
//  AUIInteractionLiveService.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/8/31.
//

#import "AUIInteractionLiveService.h"
#import "AUIInteractionAccountManager.h"


static NSString * const kLiveServiceDomainString =  @"http://live-example.live.1569899459811379.cn-hangzhou.fc.devsapp.net";

@implementation AUIInteractionLiveService

+ (NSString *)jsonStringWithDict:(NSDictionary *)dict {
    if (!dict) {
        return nil;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (void)requestWithPath:(NSString *)path bodyDic:(NSDictionary *)bodyDic completionHandler:(void (^)(NSURLResponse *response, id responseObject,  NSError * error))completionHandler {
        
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kLiveServiceDomainString, path];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"accept"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:@"production" forHTTPHeaderField:@"x-live-env"];  // staging/production
    [urlRequest addValue:[NSString stringWithFormat:@"Bearer %@", AUIInteractionAccountManager.me.token ?: @"live"] forHTTPHeaderField:@"Authorization"];
    urlRequest.HTTPMethod = @"POST";
    if (bodyDic) {
        urlRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:bodyDic options:NSJSONWritingPrettyPrinted error:nil];
    }
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlRequest
                                            completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                if (completionHandler) {
                    completionHandler(response, nil, error);
                }
                return;
            }
            
            NSError *jsonError = nil;
            id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if (jsonError || [jsonObj isKindOfClass:NSNull.class]) {
                if (completionHandler) {
                    completionHandler(response, nil, jsonError);
                }
                return;
            }
            
            if ([response isKindOfClass:NSHTTPURLResponse.class]) {
                NSHTTPURLResponse *http = (NSHTTPURLResponse *)response;
                if (http.statusCode == 200) {
                    if (completionHandler) {
                        completionHandler(response, jsonObj, nil);
                    }
                }
                else if (http.statusCode >= 400) {
                    NSError *retError = [NSError errorWithDomain:@"live.service" code:http.statusCode userInfo:jsonObj];
                    if (completionHandler) {
                        completionHandler(response, nil, retError);
                    }
                }
                return;
            }
        });
    }];
    
    [task resume];
}

+ (void)fetchToken:(void (^)(NSString * _Nullable, NSString * _Nullable, NSError * _Nullable))completed {
    NSDictionary *body = @{
        @"device_id":AUIInteractionAccountManager.deviceId ?: @"",
        @"device_type":@"ios",
        @"user_id":AUIInteractionAccountManager.me.userId ?: @""
    };
    NSString *path = @"/api/v1/live/token";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(nil, nil, error);
            }
            return;
        }
        NSString *access = nil;
        NSString *refresh = nil;
        if (responseObject && [responseObject isKindOfClass:NSDictionary.class]) {
            access = [responseObject objectForKey:@"access_token"];
            refresh = [responseObject objectForKey:@"refresh_token"];
        }
        if (completed) {
            completed(access, refresh, nil);
        }
    }];
}

+ (void)createLive:(NSString *)groupId  mode:(NSInteger)mode title:(NSString *)title extend:(NSDictionary * _Nullable)extend completed:(void (^)(AUIInteractionLiveInfoModel * _Nullable, NSError * _Nullable))completed {
    
    NSDictionary *body = @{
        @"anchor":AUIInteractionAccountManager.me.userId ?: @"",
        @"id":groupId ?: @"",
        @"mode":@(mode),
        @"title":title ?: @"",
        @"extends":[self jsonStringWithDict:extend] ?: @"{}"
    };
    NSString *path = @"/api/v1/live/create";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(nil, error);
            }
            return;
        }
        AUIInteractionLiveInfoModel *model = nil;
        if (responseObject && [responseObject isKindOfClass:NSDictionary.class]) {
            model = [[AUIInteractionLiveInfoModel alloc] initWithResponseData:responseObject];
        }
        if (completed) {
            completed(model, nil);
        }
    }];
}

+ (void)startLive:(NSString *)liveId completed:(void (^)(AUIInteractionLiveInfoModel * _Nullable, NSError * _Nullable))completed {
    NSDictionary *body = @{
        @"id":liveId ?: @"",
        @"user_id":AUIInteractionAccountManager.me.userId ?: @"",
    };
    NSString *path = @"/api/v1/live/start";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(nil, error);
            }
            return;
        }
        AUIInteractionLiveInfoModel *model = nil;
        if (responseObject && [responseObject isKindOfClass:NSDictionary.class]) {
            model = [[AUIInteractionLiveInfoModel alloc] initWithResponseData:responseObject];
        }
        if (completed) {
            completed(model, nil);
        }
    }];
}

+ (void)stopLive:(NSString *)liveId completed:(void (^)(AUIInteractionLiveInfoModel * _Nullable, NSError * _Nullable))completed {
    NSDictionary *body = @{
        @"id":liveId ?: @"",
        @"user_id":AUIInteractionAccountManager.me.userId ?: @"",
    };
    NSString *path = @"/api/v1/live/stop";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(nil, error);
            }
            return;
        }
        AUIInteractionLiveInfoModel *model = nil;
        if (responseObject && [responseObject isKindOfClass:NSDictionary.class]) {
            model = [[AUIInteractionLiveInfoModel alloc] initWithResponseData:responseObject];
        }
        if (completed) {
            completed(model, nil);
        }
    }];
}

+ (void)fetchLiveList:(NSUInteger)pageNum pageSize:(NSUInteger)pageSize completed:(void (^)(NSArray<AUIInteractionLiveInfoModel *> * _Nullable, NSError * _Nullable))completed {
    NSDictionary *body = @{
        @"page_num":@(pageNum),
        @"page_size":@(pageSize),
        @"user_id":AUIInteractionAccountManager.me.userId ?: @""
    };
    NSString *path = @"/api/v1/live/list";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(nil, error);
            }
            return;
        }
        NSMutableArray *models = [NSMutableArray array];
        if (responseObject && [responseObject isKindOfClass:NSArray.class]) {
            NSArray *arr = responseObject;
            [arr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                AUIInteractionLiveInfoModel *model = [[AUIInteractionLiveInfoModel alloc] initWithResponseData:obj];
                [models addObject:model];
            }];
        }
        if (completed) {
            completed(models, nil);
        }
    }];
}

+ (void)fetchLive:(NSString *)liveId userId:(NSString *)userId completed:(void (^)(AUIInteractionLiveInfoModel * _Nullable, NSError * _Nullable))completed {
    NSDictionary *body = @{
        @"id":liveId ?: @"",
        @"user_id":(userId ?: AUIInteractionAccountManager.me.userId) ?: @"",
    };
    NSString *path = @"/api/v1/live/get";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(nil, error);
            }
            return;
        }
        AUIInteractionLiveInfoModel *model = nil;
        if (responseObject && [responseObject isKindOfClass:NSDictionary.class]) {
            model = [[AUIInteractionLiveInfoModel alloc] initWithResponseData:responseObject];
        }
        if (completed) {
            completed(model, nil);
        }
    }];
}

+ (void)updateLive:(NSString *)liveId title:(NSString *)title extend:(NSDictionary *)extend completed:(void (^)(AUIInteractionLiveInfoModel * _Nullable, NSError * _Nullable))completed {
    NSDictionary *body = @{
        @"anchor":AUIInteractionAccountManager.me.userId ?: @"",
        @"id":liveId ?: @"",
        @"title":title ?: @"",
        @"extends":[self jsonStringWithDict:extend] ?: @"{}"
    };
    NSString *path = @"/api/v1/live/update";
    [self requestWithPath:path bodyDic:body completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (completed) {
                completed(nil, error);
            }
            return;
        }
        AUIInteractionLiveInfoModel *model = nil;
        if (responseObject && [responseObject isKindOfClass:NSDictionary.class]) {
            model = [[AUIInteractionLiveInfoModel alloc] initWithResponseData:responseObject];
        }
        if (completed) {
            completed(model, nil);
        }
    }];
}

@end
