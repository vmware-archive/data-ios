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

+ (void)startSyncingWithBlock:(SyncBlock)syncBlock {
    void (^block)(NSNotification*) = ^(NSNotification *notification) {
        PCFNetworkStatus status = [[PCFReachability reachability] currentReachabilityStatus];
        if (status != NotReachable) {
            syncBlock();
        }
    };
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kPCFReachabilityChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:block];
    [[PCFReachability reachability] startNotifier];
}

+ (void)syncWithAccessToken:(NSString *)accessToken {
    [[PCFRequestCache sharedInstance] executePendingRequestsWithToken:accessToken];
}

+ (void)syncWithAccessToken:(NSString *)accessToken completionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[PCFRequestCache sharedInstance] executePendingRequestsWithToken:accessToken completionHandler:completionHandler];
}

+ (void)logLevel:(PCFLogLevel)level {
    [PCFLogger sharedInstance].level = level;
}

@end