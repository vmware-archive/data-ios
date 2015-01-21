//
//  PCFRequestCache.m
//  PCFData
//
//  Created by DX122-XL on 2014-11-21.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFRequestCache.h"
#import "PCFDataPersistence.h"
#import "PCFRequestCacheQueue.h"
#import "PCFRequestCacheExecutor.h"
#import "PCFOfflineStore.h"
#import "PCFRequest.h"
#import "PCFPendingRequest.h"
#import "PCFResponse.h"
#import "PCFLogger.h"

@interface PCFRequestCache ()

@property PCFRequestCacheQueue *queue;
@property PCFRequestCacheExecutor *executor;

@end

@implementation PCFRequestCache

- (instancetype)initWithOfflineStore:(PCFOfflineStore *)offlineStore fallbackStore:(id<PCFDataStore>)fallbackStore {
    _queue = [[PCFRequestCacheQueue alloc] initWithPersistence:[[PCFDataPersistence alloc] init]];
    _executor = [[PCFRequestCacheExecutor alloc] initWithOfflineStore:offlineStore fallbackStore:fallbackStore];
    return self;
}

- (instancetype)initWithRequestQueue:(PCFRequestCacheQueue *)queue executor:(PCFRequestCacheExecutor *)executor {
    _queue = queue;
    _executor = executor;
    return self;
}

- (void)queueGetWithRequest:(PCFRequest *)request {
    LogInfo(@"PCFLocalStore queueGetWithRequest: %@", request);
    PCFPendingRequest *pending = [[PCFPendingRequest alloc] initWithRequest:request method:PCF_HTTP_GET];
    [self.queue addRequest:pending];
}

- (void)queuePutWithRequest:(PCFRequest *)request {
    LogInfo(@"PCFLocalStore queuePutWithRequest: %@", request);
    PCFPendingRequest *pending = [[PCFPendingRequest alloc] initWithRequest:request method:PCF_HTTP_PUT];
    [self.queue addRequest:pending];
}

- (void)queueDeleteWithRequest:(PCFRequest *)request {
    LogInfo(@"PCFLocalStore queueDeleteWithRequest: %@", request);
    PCFPendingRequest *pending = [[PCFPendingRequest alloc] initWithRequest:request method:PCF_HTTP_DELETE];
    [self.queue addRequest:pending];
}

- (void)executePendingRequestsWithToken:(NSString *)accessToken {
    [self executePendingRequestsWithToken:accessToken completionHandler:nil];
}

- (void)executePendingRequestsWithToken:(NSString *)accessToken completionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSArray *requests = [self.queue empty];
    
    if (requests.count > 0) {
        [self executePendingRequests:requests];
        
        if (completionHandler) {
            completionHandler(UIBackgroundFetchResultNewData);
        }
    } else {
        if (completionHandler) {
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }
}

- (void)executePendingRequests:(NSArray *)requests {
    for (NSDictionary *dictionary in requests) {
        PCFPendingRequest *request  = [[PCFPendingRequest alloc] initWithDictionary:dictionary];
        
        [self.executor executeRequest:request];
    }
}

@end