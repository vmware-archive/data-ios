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

- (void)queueGetWithRequest:(PCFDataRequest *)request;

- (void)queuePutWithRequest:(PCFDataRequest *)request;

- (void)queueDeleteWithRequest:(PCFDataRequest *)request;

- (void)executePendingRequests;

- (void)executePendingRequestsWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end

