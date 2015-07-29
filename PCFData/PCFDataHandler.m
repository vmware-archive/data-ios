//
//  PCFDataHandler.m
//  PCFData
//
//  Created by DX122-XL on 2015-02-12.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "PCFDataHandler.h"
#import "PCFReachability.h"
#import "PCFDataLogger.h"

@interface PCFDataHandler ()

@property (strong) PCFTokenProviderBlock provideTokenBlock;
@property (strong) PCFTokenInvalidatorBlock invalidateTokenBlock;
@property (strong) PCFNetworkBlock networkBlock;

@property PCFReachability *reachability;
@property id reachabilityObserver;

@end

@implementation PCFDataHandler

- (void)registerTokenProviderBlock:(PCFTokenProviderBlock)block {
    self.provideTokenBlock = block;
    [self startReachability];
}

- (void)registerTokenInvalidatorBlock:(PCFTokenInvalidatorBlock)block {
    self.invalidateTokenBlock = block;
    [self startReachability];
}

- (void)registerNetworkObserverBlock:(PCFNetworkBlock)block {
    self.networkBlock = block;
    [self startReachability];
}

- (void)startReachability {
    if (!self.reachability) {
        [self registerForReachabilityNotifications];
        [self registerDefaultConnectedBlock];
        
        self.reachability = [PCFReachability reachability];
        [self.reachability currentReachabilityStatus];
        [self.reachability startNotifier];
    }
}

- (void)stopReachability {
    if (self.reachability) {
        [self unregisterForReachabilityNotifications];
        [self unregisterDefaultConnectedBlock];
        
        [self.reachability stopNotifier];
        self.reachability = nil;
    }
}

- (void)registerForReachabilityNotifications {
    self.reachabilityObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kPCFReachabilityChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        PCFNetworkStatus status = [self.reachability currentReachabilityStatus];
        BOOL connected = status != NotReachable;
        
        LogInfo(@"PCFReachability notification isConnected: %d", connected);
        
        [self notifyNetworkStatusChanged:connected];
    }];
}


- (void)unregisterForReachabilityNotifications {
    if (self.reachabilityObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.reachabilityObserver];
        self.reachabilityObserver = nil;
    }
}

- (void)notifyNetworkStatusChanged:(BOOL)connected {
    if (self.networkBlock) {
        self.networkBlock(connected);
    }
}

- (void)registerDefaultConnectedBlock {
    if (!self.networkBlock) {
        self.networkBlock = ^(BOOL connected) {
            if (connected) {
                [PCFData performSync];
            }
        };
    }
}

- (void)unregisterDefaultConnectedBlock {
    if (self.networkBlock) {
        self.networkBlock = nil;
    }
}

- (NSString *)provideToken {
    if (self.provideTokenBlock) {
        return self.provideTokenBlock();
    } else {
        return nil;
    }
}

- (void)invalidateToken {
    if (self.invalidateTokenBlock) {
        return self.invalidateTokenBlock();
    }
}


@end
