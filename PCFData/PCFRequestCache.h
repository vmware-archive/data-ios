//
//  PCFRequestCache.h
//  PCFData
//
//  Created by DX122-XL on 2014-11-21.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PCFPendingRequest, PCFOfflineStore, PCFLocalStore, PCFResponse;

@interface PCFRequestCache : NSObject

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults;

+ (PCFRequestCache *)sharedInstance;

- (PCFOfflineStore *)createOfflineStoreWithCollection:(NSString *)collection;

- (PCFLocalStore *)createLocalStoreWithCollection:(NSString *)collection;

- (void)queueGetWithToken:(NSString *)accessToken collection:(NSString *)collection key:(NSString *)key;

- (void)queuePutWithToken:(NSString *)accessToken collection:(NSString *)collection key:(NSString *)key value:(NSString *)value fallback:(NSString *)fallback;

- (void)queueDeleteWithToken:(NSString *)accessToken collection:(NSString *)collection key:(NSString *)key fallback:(NSString *)fallback;

- (void)queuePendingRequest:(PCFPendingRequest *)request;

- (void)executePendingRequestsWithToken:(NSString *)accessToken;

- (void)executePendingRequestsWithToken:(NSString *)accessToken completionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end

@interface PCFPendingRequest : NSObject

@property NSDictionary *values;
@property (readonly) int method;
@property (readonly) NSString *key;
@property (readonly) NSString *value;
@property (readonly) NSString *collection;
@property (readonly) NSString *fallback;
@property (readonly) NSString *accessToken;

- (instancetype)initWithDictionary:(NSDictionary *)values;

- (instancetype)initWithMethod:(int)method accessToken:(NSString *)accessToken collection:(NSString *)collection key:(NSString *)key value:(NSString *)value fallback:(NSString *)fallback;

@end 