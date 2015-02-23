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

@class PCFKeyValueOfflineStore, PCFRequestCacheQueue, PCFRequestCacheExecutor;

@interface PCFRequestCache : NSObject

- (instancetype)initWithOfflineStore:(PCFKeyValueOfflineStore *)offlineStore fallbackStore:(id<PCFDataStore>)fallbackStore;

- (instancetype)initWithRequestQueue:(PCFRequestCacheQueue *)queue executor:(PCFRequestCacheExecutor *)executor;

- (void)queueRequest:(PCFDataRequest *)request;

- (void)executePendingRequests;

- (void)executePendingRequestsWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

@end

