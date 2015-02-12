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
#import "PCFDataResponse.h"
#import "PCFDataRequest.h"
#import "PCFReachability.h"
#import "PCFDataConfig.h"
#import "PCFDataLogger.h"


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

- (PCFDataResponse *)getWithRequest:(PCFDataRequest *)request {
    LogInfo(@"PCFOfflineStore getWithRequest: %@", request);

    if ([self isConnected]) {
        PCFDataResponse *response = [self.remoteStore getWithRequest:request];
        
        if (!response.error) {
            PCFDataRequest *localRequest = [[PCFDataRequest alloc] initWithRequest:request];
            localRequest.object = response.object;
            
            return [self.localStore putWithRequest:localRequest];
            
        } else if (response.error.code == 404) {
            [self.localStore deleteWithRequest:request];
            return response;
            
        } else if (response.error.code == 304) {
            return [self.localStore getWithRequest:request];
            
        } else {
            return response;
        }
        
    } else {
        PCFDataResponse *response = [self.localStore getWithRequest:request];
        
        [self.requestCache queueGetWithRequest:request];
        
        return response;
    }
}

- (void)getWithRequest:(PCFDataRequest *)request completionBlock:(PCFDataResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFDataResponse *response = [self getWithRequest:request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFDataResponse *)putWithRequest:(PCFDataRequest *)request {
    LogInfo(@"PCFOfflineStore putWithRequest: %@", request);
    
    if ([self isConnected]) {
        PCFDataResponse *response = [self.remoteStore putWithRequest:request];
        
        if (!response.error) {
            return [self.localStore putWithRequest:request];
            
        } else {
            return response;
        }
        
    } else {
        PCFDataResponse *fallback = [self.localStore getWithRequest:request];
        PCFDataResponse *response = [self.localStore putWithRequest:request];
        
        request.fallback = fallback.object;
        
        [self.requestCache queuePutWithRequest:request];
        
        return response;
    }
}

- (void)putWithRequest:(PCFDataRequest *)request completionBlock:(PCFDataResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFDataResponse *response = [self putWithRequest:request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFDataResponse *)deleteWithRequest:(PCFDataRequest *)request {
    LogInfo(@"PCFOfflineStore deleteWithKey: %@", request);
    
    if ([self isConnected]) {
        PCFDataResponse *response = [self.remoteStore deleteWithRequest:request];
        
        if (!response.error) {
            return [self.localStore deleteWithRequest:request];
        } else {
            return response;
        }
        
    } else {
        PCFDataResponse *fallback = [self.localStore getWithRequest:(PCFDataRequest *)request];
        PCFDataResponse *response = [self.localStore deleteWithRequest:(PCFDataRequest *)request];
        
        request.fallback = fallback.object;
        
        [self.requestCache queueDeleteWithRequest:request];
        
        return response;
    }
}

- (void)deleteWithRequest:(PCFDataRequest *)request completionBlock:(PCFDataResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFDataResponse *response = [self deleteWithRequest:(PCFDataRequest *)request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (BOOL)isConnected {
    PCFNetworkStatus networkStatus = [[PCFReachability reachability] currentReachabilityStatus];
    
    LogInfo(@"PCFOfflineStore isConnected: %d", networkStatus != NotReachable);
    
    return networkStatus != NotReachable;
}

@end