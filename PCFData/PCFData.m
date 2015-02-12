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
#import "PCFDataLogger.h"

@implementation PCFData

static PCFReachability *reachability;

static PCFTokenBlock tokenBlock;
static PCFNetworkBlock networkBlock;

static id reachabilityObserver;


+ (void)logLevel:(PCFDataLogLevel)level {
    [PCFDataLogger sharedInstance].level = level;
}

+ (void)registerTokenProviderBlock:(PCFTokenBlock)block {
    tokenBlock = block;
    [PCFData startReachability];
}

+ (void)registerNetworkObserverBlock:(PCFNetworkBlock)block {
    networkBlock = block;
    [PCFData startReachability];
}

+ (void)performSync {
    [[[PCFRequestCache alloc] init] executePendingRequests];
}

+ (void)performSyncWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [[[PCFRequestCache alloc] init] executePendingRequestsWithCompletionHandler:completionHandler];
}

+ (void)startReachability {
    if (!reachability) {
        [self registerForReachabilityNotifications];
        [self registerDefaultConnectedBlock];
        
        reachability = [PCFReachability reachability];
        [reachability startNotifier];
    }
}

+ (void)stopReachability {
    if (reachability) {
        [self unregisterForReachabilityNotifications];
        [self unregisterDefaultConnectedBlock];
        
        [reachability stopNotifier];
        reachability = nil;
    }
}

+ (void)registerForReachabilityNotifications {
    reachabilityObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kPCFReachabilityChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        PCFNetworkStatus status = [reachability currentReachabilityStatus];
        BOOL connected = status != NotReachable;
        
        LogInfo(@"PCFReachability notification isConnected: %d", connected);
        
        [self notifyNetworkStatusChanged:connected];
    }];
}


+ (void)unregisterForReachabilityNotifications {
    if (reachabilityObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:reachabilityObserver];
        reachabilityObserver = nil;
    }
}

+ (void)notifyNetworkStatusChanged:(BOOL)connected {
    if (networkBlock) {
        networkBlock(connected);
    }
}

+ (void)registerDefaultConnectedBlock {
    if (!networkBlock) {
        networkBlock = ^(BOOL connected) {
            if (connected) {
                [PCFData performSync];
            }
        };
    }
}

+ (void)unregisterDefaultConnectedBlock {
    if (networkBlock) {
        networkBlock = nil;
    }
}

+ (NSString*)provideTokenWithUserPrompt:(BOOL)prompt {
    if (tokenBlock) {
        return tokenBlock(prompt);
    } else {
        return nil;
    }
}

@end