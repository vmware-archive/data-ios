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
#import "PCFReachability.h"
#import "PCFLogger.h"

@implementation PCFData

static PCFReachability *reachability;

+ (void)syncWhenNetworkAvailableWithBlock:(SyncBlock)syncBlock {
    reachability = [PCFReachability reachability];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kPCFReachabilityChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        PCFNetworkStatus status = [reachability currentReachabilityStatus];
        if (status != NotReachable) {
            syncBlock();
        }
    }];
    
    [reachability startNotifier];
}

+ (void)syncWithAccessToken:(NSString *)accessToken {
    [[PCFData requestCache] executePendingRequestsWithToken:accessToken];
}

+ (void)syncWithAccessToken:(NSString *)accessToken completionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[PCFData requestCache] executePendingRequestsWithToken:accessToken completionHandler:completionHandler];
}

+ (PCFRequestCache *)requestCache {
    PCFOfflineStore *offlineStore = [[PCFOfflineStore alloc] init];
    PCFKeyValueStore *fallbackStore = [[PCFKeyValueStore alloc] init];
    return [[PCFRequestCache alloc] initWithOfflineStore:offlineStore fallbackStore:fallbackStore];
}

+ (void)logLevel:(PCFDataLogLevel)level {
    [PCFLogger sharedInstance].level = level;
}

@end