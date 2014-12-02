//
//  PCFOfflineStore.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-30.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFDataStore.h"

@class PCFRemoteStore, PCFLocalStore, PCFRequestCache;

@interface PCFOfflineStore : NSObject <PCFDataStore>

@property (readonly) PCFRequestCache *requestCache;

- (instancetype)initWithCollection:(NSString *)collection;

- (instancetype)initWithCollection:(NSString *)collection localStore:(PCFLocalStore *)localStore remoteStore:(PCFRemoteStore *)remoteStore;

- (PCFResponse *)errorNoConnectionWithKey:(NSString *)key;

- (BOOL)isSyncSupported;

- (BOOL)isConnected;

@end
