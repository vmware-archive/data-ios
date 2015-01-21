//
//  PCFOfflineStore.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-30.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFOfflineStore.h"
#import "PCFRemoteStore.h"
#import "PCFKeyValueStore.h"
#import "PCFRequestCache.h"
#import "PCFResponse.h"
#import "PCFRequest.h"
#import "PCFReachability.h"
#import "PCFConfig.h"
#import "PCFLogger.h"


@interface PCFOfflineStore ()

@property PCFRemoteStore *remoteStore;
@property PCFKeyValueStore *localStore;
@property (readonly) PCFRequestCache *requestCache;

- (BOOL)isConnected;

@end

@implementation PCFOfflineStore

- (instancetype)init {
    PCFRemoteStore *remoteStore = [[PCFRemoteStore alloc] init];
    PCFKeyValueStore *localStore = [[PCFKeyValueStore alloc] init];
    return [self initWithLocalStore:localStore remoteStore:remoteStore];
}

- (instancetype)initWithLocalStore:(PCFKeyValueStore *)localStore remoteStore:(PCFRemoteStore *)remoteStore {
    self = [super init];
    _remoteStore = remoteStore;
    _localStore = localStore;
    return self;
}

- (PCFRequestCache *)requestCache {
    return [[PCFRequestCache alloc] initWithOfflineStore:self fallbackStore:self.localStore];
}

- (PCFResponse *)getWithRequest:(PCFRequest *)request {
    LogInfo(@"PCFOfflineStore getWithRequest: %@", request);

    if ([self isConnected]) {
        PCFResponse *response = [self.remoteStore getWithRequest:request];
        
        if (!response.error) {
            PCFRequest *localRequest = [[PCFRequest alloc] initWithRequest:request];
            localRequest.object = response.object;
            
            return [self.localStore putWithRequest:localRequest];
            
        } else if (response.error.code == 304) {
            return [self.localStore getWithRequest:request];
            
        } else {
            return response;
        }
        
    } else {
        PCFResponse *response = [self.localStore getWithRequest:request];
        
        [self.requestCache queueGetWithRequest:request];
        
        return response;
    }
}

- (void)getWithRequest:(PCFRequest *)request completionBlock:(PCFResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self getWithRequest:request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFResponse *)putWithRequest:(PCFRequest *)request {
    LogInfo(@"PCFOfflineStore putWithRequest: %@", request);
    
    if ([self isConnected]) {
        PCFResponse *response = [self.remoteStore putWithRequest:request];
        
        if (!response.error) {
            return [self.localStore putWithRequest:request];
        } else {
            return response;
        }
        
    } else {
        PCFResponse *fallback = [self.localStore getWithRequest:request];
        PCFResponse *response = [self.localStore putWithRequest:request];
        
        request.fallback = [fallback object];
        
        [self.requestCache queuePutWithRequest:request];
        
        return response;
    }
}

- (void)putWithRequest:(PCFRequest *)request completionBlock:(PCFResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self putWithRequest:request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFResponse *)deleteWithRequest:(PCFRequest *)request {
    LogInfo(@"PCFOfflineStore deleteWithKey: %@", request);
    
    if ([self isConnected]) {
        PCFResponse *response = [self.remoteStore deleteWithRequest:request];
        
        if (!response.error) {
            return [self.localStore deleteWithRequest:request];
        } else {
            return response;
        }
        
    } else {
        PCFResponse *fallback = [self.localStore getWithRequest:(PCFRequest *)request];
        PCFResponse *response = [self.localStore deleteWithRequest:(PCFRequest *)request];
        
        request.fallback = fallback.object;
        
        [self.requestCache queueDeleteWithRequest:request];
        
        return response;
    }
}

- (void)deleteWithRequest:(PCFRequest *)request completionBlock:(PCFResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self deleteWithRequest:(PCFRequest *)request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (BOOL)isConnected {
    PCFNetworkStatus networkStatus = [[PCFReachability reachability] currentReachabilityStatus];
    return networkStatus != NotReachable;
}

@end