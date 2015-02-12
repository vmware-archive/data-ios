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
#import "PCFDataRequest.h"
#import "PCFPendingRequest.h"
#import "PCFDataResponse.h"
#import "PCFDataLogger.h"

@interface PCFRequestCache ()

@property PCFRequestCacheQueue *queue;
@property PCFRequestCacheExecutor *executor;

@end

@implementation PCFRequestCache

- (instancetype)init {
    PCFOfflineStore *offlineStore = [[PCFOfflineStore alloc] init];
    PCFKeyValueStore *fallbackStore = [[PCFKeyValueStore alloc] init];
    return [self initWithOfflineStore:offlineStore fallbackStore:fallbackStore];
}

- (instancetype)initWithOfflineStore:(PCFOfflineStore *)offlineStore fallbackStore:(id<PCFDataStore>)fallbackStore {
    self = [super init];
    _queue = [[PCFRequestCacheQueue alloc] initWithPersistence:[[PCFDataPersistence alloc] init]];
    _executor = [[PCFRequestCacheExecutor alloc] initWithOfflineStore:offlineStore fallbackStore:fallbackStore];
    return self;
}

- (instancetype)initWithRequestQueue:(PCFRequestCacheQueue *)queue executor:(PCFRequestCacheExecutor *)executor {
    self = [super init];
    _queue = queue;
    _executor = executor;
    return self;
}

- (void)queueGetWithRequest:(PCFDataRequest *)request {
    LogInfo(@"PCFRequestCache queueGetWithRequest: %@", request);
    PCFPendingRequest *pending = [[PCFPendingRequest alloc] initWithRequest:request method:PCF_HTTP_GET];
    [self.queue addRequest:pending];
}

- (void)queuePutWithRequest:(PCFDataRequest *)request {
    LogInfo(@"PCFRequestCache queuePutWithRequest: %@", request);
    PCFPendingRequest *pending = [[PCFPendingRequest alloc] initWithRequest:request method:PCF_HTTP_PUT];
    [self.queue addRequest:pending];
}

- (void)queueDeleteWithRequest:(PCFDataRequest *)request {
    LogInfo(@"PCFRequestCache queueDeleteWithRequest: %@", request);
    PCFPendingRequest *pending = [[PCFPendingRequest alloc] initWithRequest:request method:PCF_HTTP_DELETE];
    [self.queue addRequest:pending];
}

- (void)executePendingRequests {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self executePendingRequestsWithCompletionHandler:nil];
    });
}

- (void)executePendingRequestsWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
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
    for (PCFPendingRequest *request in requests) {
        [self.executor executeRequest:request];
    }
}

@end