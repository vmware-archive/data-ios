//
//  PCFOfflineStore.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-30.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFKeyValueOfflineStore.h"
#import "PCFKeyValueRemoteStore.h"
#import "PCFKeyValueLocalStore.h"
#import "PCFRequestCache.h"
#import "PCFDataResponse.h"
#import "PCFDataRequest.h"
#import "PCFReachability.h"
#import "PCFDataConfig.h"
#import "PCFDataLogger.h"


@interface PCFKeyValueOfflineStore ()

@property PCFKeyValueRemoteStore *remoteStore;
@property PCFKeyValueLocalStore *localStore;
@property (readonly) PCFRequestCache *requestCache;

- (BOOL)isConnected;

@end

@implementation PCFKeyValueOfflineStore

- (instancetype)init {
    PCFKeyValueRemoteStore *remoteStore = [[PCFKeyValueRemoteStore alloc] init];
    PCFKeyValueLocalStore *localStore = [[PCFKeyValueLocalStore alloc] init];
    return [self initWithLocalStore:localStore remoteStore:remoteStore];
}

- (instancetype)initWithLocalStore:(PCFKeyValueLocalStore *)localStore remoteStore:(PCFKeyValueRemoteStore *)remoteStore {
    self = [super init];
    _remoteStore = remoteStore;
    _localStore = localStore;
    return self;
}

- (PCFRequestCache *)requestCache {
    return [[PCFRequestCache alloc] initWithOfflineStore:self fallbackStore:self.localStore];
}

- (PCFDataResponse *)executeRequest:(PCFDataRequest *)request {
    LogInfo(@"PCFKeyValueLocalStore executeRequest: %@", request);
    
    @try {
        return [self executeRequestForMethod:request];
    }
    
    @catch (NSException *exception) {
        NSError *error = [[NSError alloc] initWithDomain:exception.reason code:-1 userInfo:nil];
        return [[PCFDataResponse alloc] initWithObject:nil error:error];
    }
}

- (PCFDataResponse *)executeRequestForMethod:(PCFDataRequest *)request {
    switch (request.method) {
        case PCF_HTTP_GET:
            LogInfo(@"PCFKeyValueOfflineStore getWithRequest: %@", request);
            return [self executeGetRequest:request];
            
        case PCF_HTTP_PUT:
            LogInfo(@"PCFKeyValueOfflineStore putWithRequest: %@", request);
            return [self executeRequestWithFallback:request];
            
        case PCF_HTTP_DELETE:
            LogInfo(@"PCFKeyValueOfflineStore deleteWithRequest: %@", request);
            return [self executeRequestWithFallback:request];
            
        default:
            @throw [NSException exceptionWithName:PCFExecutionError reason:PCFUnsupportedOperation userInfo:nil];
    }
}

- (void)executeRequest:(PCFDataRequest *)request completionBlock:(PCFDataResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFDataResponse *response = [self executeRequest:request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(response);
            }
        });
    });
}

- (PCFDataResponse *)executeGetRequest:(PCFDataRequest *)request {
    
    if ([self isConnected]) {
        return [self executeGetRequestRemotely:request];
        
    } else {
        return [self queueGetRequest:request];
    }
}

- (PCFDataResponse *)executeRequestWithFallback:(PCFDataRequest *)request {
    
    if ([self isConnected]) {
        return [self executeRequestRemotely:request];
        
    } else {
        
        return [self queueRequestWithFallback:request];
    }
}

- (PCFDataResponse *)executeGetRequestRemotely:(PCFDataRequest *)request {
    PCFDataResponse *response = [self.remoteStore executeRequest:request];
    
    if (!response.error) {
        return [self executePutRequestLocally:request response:response];
        
    } else if (response.error.code == 404) {
        return [self executeDeleteRequestLocally:request response:response];
        
    } else if (response.error.code == 304) {
        LogInfo(@"Got error code 304 in get request. Getting local value.");
        return [self.localStore executeRequest:request];
        
    } else {
        return response;
    }
}

- (PCFDataResponse *)executePutRequestLocally:(PCFDataRequest *)request response:(PCFDataResponse *)response {
    PCFDataRequest *put = [[PCFDataRequest alloc] initWithRequest:request];
    put.method = PCF_HTTP_PUT;
    put.object = response.object;
    
    return [self.localStore executeRequest:put];
}

- (PCFDataResponse *)executeDeleteRequestLocally:(PCFDataRequest *)request response:(PCFDataResponse *)response {
    PCFDataRequest *delete = [[PCFDataRequest alloc] initWithRequest:request];
    delete.method = PCF_HTTP_DELETE;
    
    [self.localStore executeRequest:delete];
    
    return response;
}

- (PCFDataResponse *)executeRequestRemotely:(PCFDataRequest *)request {
    PCFDataResponse *response = [self.remoteStore executeRequest:request];
    
    if (!response.error) {
        return [self.localStore executeRequest:request];
        
    } else {
        return response;
    }
}

- (PCFDataResponse *)queueGetRequest:(PCFDataRequest *)request {
    PCFDataResponse *response = [self.localStore executeRequest:request];
    
    [self.requestCache queueRequest:request];
    
    return response;
}

- (PCFDataResponse *)queueRequestWithFallback:(PCFDataRequest *)request {
    PCFDataRequest *get = [[PCFDataRequest alloc] initWithRequest:request];
    get.method = PCF_HTTP_GET;
    
    PCFDataResponse *fallback = [self.localStore executeRequest:get];
    PCFDataResponse *response = [self.localStore executeRequest:request];
    
    request.fallback = fallback.object;
    
    [self.requestCache queueRequest:request];
    
    return response;
}

- (BOOL)isConnected {
    PCFNetworkStatus networkStatus = [[PCFReachability reachability] currentReachabilityStatus];
    
    LogInfo(@"PCFOfflineStore isConnected: %d", networkStatus != NotReachable);
    
    return networkStatus != NotReachable;
}

@end