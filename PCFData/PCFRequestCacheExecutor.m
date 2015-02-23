//
//  RequestCacheExecutor.m
//  PCFData
//
//  Created by DX122-XL on 2015-01-14.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "PCFRequestCacheExecutor.h"
#import "PCFKeyValueOfflineStore.h"
#import "PCFPendingRequest.h"
#import "PCFRequestCache.h"
#import "PCFDataResponse.h"

@interface PCFRequestCacheExecutor ()

@property PCFKeyValueOfflineStore *offlineStore;

@property id<PCFDataStore> fallbackStore;

@end

@implementation PCFRequestCacheExecutor

- (instancetype)initWithOfflineStore:(PCFKeyValueOfflineStore *)offlineStore fallbackStore:(id<PCFDataStore>)fallbackStore {
    self = [super init];
    _offlineStore = offlineStore;
    _fallbackStore = fallbackStore;
    return self;
}

- (void)executeRequest:(PCFPendingRequest *)request {
    switch (request.method) {
        case PCF_HTTP_GET:
            [self.offlineStore executeRequest:request];
            break;
            
        case PCF_HTTP_PUT:
        case PCF_HTTP_DELETE:
            [self executeWithFallback:request];
            break;
            
        default:
            @throw [NSException exceptionWithName:PCFExecutionError reason:PCFUnsupportedOperation userInfo:nil];
    }
}

- (void)executeWithFallback:(PCFPendingRequest *)request {
    PCFDataResponse *response = [self.offlineStore executeRequest:request];
    if (response.error) {
        PCFPendingRequest *fallback = [[PCFPendingRequest alloc] initWithRequest:request];
        fallback.method = PCF_HTTP_PUT;
        fallback.object = request.fallback;
        
        [self.fallbackStore executeRequest:fallback];
    }
}

@end
