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
static PCFTokenBlock tokenWithPromptBlock;

static PCFNetworkBlock connectedBlock;
static PCFNetworkBlock disconnectedBlock;

static id reachabilityObserver;


+ (void)logLevel:(PCFDataLogLevel)level {
    [PCFDataLogger sharedInstance].level = level;
}

+ (void)registerTokenProviderBlock:(PCFTokenBlock)block {
    tokenBlock = block;
    [PCFData startReachability];
}

+ (void)registerTokenProviderWithUserPromptBlock:(PCFTokenBlock)block {
    tokenWithPromptBlock = block;
    [PCFData startReachability];
}

+ (void)registerNetworkConnectedBlock:(PCFNetworkBlock)block {
    connectedBlock = block;
    [PCFData startReachability];
}

+ (void)registerNetworkDisconnectedBlock:(PCFNetworkBlock)block {
    disconnectedBlock = block;
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
    if (connected) {
        if (connectedBlock) {
            connectedBlock();
        }
    } else {
        if (disconnectedBlock) {
            disconnectedBlock();
        }
    }
}

+ (void)registerDefaultConnectedBlock {
    if (!connectedBlock) {
        connectedBlock = ^() {
            [PCFData performSync];
        };
    }
}

+ (void)unregisterDefaultConnectedBlock {
    if (connectedBlock) {
        connectedBlock = nil;
    }
    if (disconnectedBlock) {
        disconnectedBlock = nil;
    }
}

+ (NSString*)provideToken {
    if (tokenBlock) {
        return tokenBlock();
    } else {
        return nil;
    }
}

+ (NSString*)provideTokenWithUserPrompt {
    if (tokenWithPromptBlock) {
        return tokenWithPromptBlock();
    } else {
        return nil;
    }
}

@end