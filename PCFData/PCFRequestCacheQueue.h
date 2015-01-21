//
//  PCFRequestCacheQueue.h
//  PCFData
//
//  Created by DX122-XL on 2015-01-13.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCFDataPersistence, PCFPendingRequest;

@interface PCFRequestCacheQueue : NSObject

- (instancetype)initWithPersistence:(PCFDataPersistence *)persistence;

- (void)addRequest:(PCFPendingRequest *)request;

- (NSArray *)empty;

@end
