//
//  RequestCacheExecutor.h
//  PCFData
//
//  Created by DX122-XL on 2015-01-14.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFDataStore.h"

@class PCFPendingRequest, PCFKeyValueOfflineStore;

@interface PCFRequestCacheExecutor : NSObject

- (instancetype)initWithOfflineStore:(PCFKeyValueOfflineStore *)offlineStore fallbackStore:(id<PCFDataStore>)fallbackStore;

- (void)executeRequest:(PCFPendingRequest *)request;

@end
