//
//  PCFRequestCache.h
//  PCFData
//
//  Created by DX122-XL on 2014-11-21.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PCFDataStore.h"

@class PCFOfflineStore, PCFRequestCacheQueue, PCFRequestCacheExecutor;

static int const PCF_HTTP_GET = 1;
static int const PCF_HTTP_PUT = 2;
static int const PCF_HTTP_DELETE = 3;

@interface PCFRequestCache : NSObject

- (instancetype)initWithOfflineStore:(PCFOfflineStore *)offlineStore fallbackStore:(id<PCFDataStore>)fallbackStore;

- (instancetype)initWithRequestQueue:(PCFRequestCacheQueue *)queue executor:(PCFRequestCacheExecutor *)executor;

- (void)queueGetWithRequest:(PCFRequest *)request;

- (void)queuePutWithRequest:(PCFRequest *)request;

- (void)queueDeleteWithRequest:(PCFRequest *)request;

- (void)executePendingRequestsWithToken:(NSString *)accessToken;

- (void)executePendingRequestsWithToken:(NSString *)accessToken completionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

- (void)executePendingRequests:(NSArray *)requests;

@end

