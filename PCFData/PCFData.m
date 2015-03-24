//
//  PCFData.m
//  PCFData
//
//  Created by DX122-XL on 2014-12-15.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFData.h"
#import "PCFEtagStore.h"
#import "PCFDataPersistence.h"
#import "PCFRequestCache.h"
#import "PCFDataLogger.h"
#import "PCFDataHandler.h"

@implementation PCFData

+ (PCFDataHandler *)handler {
    static PCFDataHandler *handler = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        handler = [[PCFDataHandler alloc] init];
    });
    return handler;
}

+ (void)logLevel:(PCFDataLogLevel)level {
    [PCFDataLogger sharedInstance].level = level;
}

+ (void)registerTokenProviderBlock:(PCFTokenProviderBlock)block {
    [self.handler registerTokenProviderBlock:block];
}

+ (void)unregisterTokenProviderBlock {
    [self.handler registerTokenProviderBlock:nil];
}

+ (void)registerTokenInvalidatorBlock:(PCFTokenInvalidatorBlock)block {
    [self.handler registerTokenInvalidatorBlock:block];
}

+ (void)unregisterTokenInvalidatorBlock {
    [self.handler registerTokenInvalidatorBlock:nil];
}

+ (NSString *)provideToken {
    return [self.handler provideToken];
}

+ (void)invalidateToken {
    return [self.handler invalidateToken];
}

+ (void)registerNetworkObserverBlock:(PCFNetworkBlock)block {
    [self.handler registerNetworkObserverBlock:block];
}

+ (void)performSync {
    [[[PCFRequestCache alloc] init] executePendingRequests];
}

+ (void)performSyncWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[[PCFRequestCache alloc] init] executePendingRequestsWithCompletionHandler:completionHandler];
}

+ (void)clearCachedData {
    [[[PCFDataPersistence alloc] initWithDomainName:PCFDataPrefix] clear];
    [[[PCFDataPersistence alloc] initWithDomainName:PCFDataEtagPrefix] clear];
}

@end