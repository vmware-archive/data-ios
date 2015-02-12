//
//  PCFData.m
//  PCFData
//
//  Created by DX122-XL on 2014-12-15.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFData.h"
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

+ (void)registerTokenProviderBlock:(PCFTokenBlock)block {
    [self.handler registerTokenProviderBlock:block];
}

+ (NSString *)provideTokenWithUserPrompt:(BOOL)prompt {
    return [self.handler provideTokenWithUserPrompt:prompt];
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

@end