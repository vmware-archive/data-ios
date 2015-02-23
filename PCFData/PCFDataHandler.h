//
//  PCFDataHandler.h
//  PCFData
//
//  Created by DX122-XL on 2015-02-12.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFData.h"

@interface PCFDataHandler : NSObject

- (void)registerTokenProviderBlock:(PCFTokenProviderBlock)block;

- (void)registerTokenInvalidatorBlock:(PCFTokenInvalidatorBlock)block;

- (void)registerNetworkObserverBlock:(PCFNetworkBlock)block;

- (NSString *)provideToken;

- (void)invalidateToken;

- (void)notifyNetworkStatusChanged:(BOOL)connected;

- (void)registerForReachabilityNotifications;

- (void)registerDefaultConnectedBlock;

- (void)unregisterForReachabilityNotifications;

- (void)unregisterDefaultConnectedBlock;

- (void)startReachability;

- (void)stopReachability;

@end
