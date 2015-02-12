//
//  RequestCacheExecutor.m
//  PCFData
//
//  Created by DX122-XL on 2015-01-14.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "PCFRequestCacheExecutor.h"
#import "PCFOfflineStore.h"
#import "PCFPendingRequest.h"
#import "PCFRequestCache.h"
#import "PCFDataResponse.h"

@interface PCFRequestCacheExecutor ()

@property PCFOfflineStore *offlineStore;
@property id<PCFDataStore> fallbackStore;

@end

@implementation PCFRequestCacheExecutor

static NSString* const PCFExecutionError = @"PCFExecutionError";
static NSString* const PCFUnsupportedOperation = @"Unsupported operation in RequestCache.";

- (instancetype)initWithOfflineStore:(PCFOfflineStore *)offlineStore fallbackStore:(id<PCFDataStore>)fallbackStore {
    _offlineStore = offlineStore;
    _fallbackStore = fallbackStore;
    return self;
}

- (void)executeRequest:(PCFPendingRequest *)request {
    switch (request.method) {
        case PCF_HTTP_GET:
            [self executeGet:request];
            break;
            
        case PCF_HTTP_PUT:
            [self executePut:request];
            break;
            
        case PCF_HTTP_DELETE:
            [self executeDelete:request];
            break;
            
        default:
            @throw [NSException exceptionWithName:PCFExecutionError reason:PCFUnsupportedOperation userInfo:nil];
    }
}

- (void)executeGet:(PCFPendingRequest *)request {
    [self.offlineStore getWithRequest:request];
}

- (void)executePut:(PCFPendingRequest *)request {
    PCFDataResponse *response = [self.offlineStore putWithRequest:request];
    if (response.error) {
        PCFPendingRequest *fallback = [[PCFPendingRequest alloc] initWithRequest:request];
        fallback.object = request.fallback;
        [self.fallbackStore putWithRequest:fallback];
    }
}

- (void)executeDelete:(PCFPendingRequest *)request {
    PCFDataResponse *response = [self.offlineStore deleteWithRequest:request];
    if (response.error) {
        PCFPendingRequest *fallback = [[PCFPendingRequest alloc] initWithRequest:request];
        fallback.object = request.fallback;
        [self.fallbackStore putWithRequest:fallback];
    }
}

@end
