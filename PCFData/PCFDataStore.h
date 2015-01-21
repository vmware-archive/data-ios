//
//  PCFDataStore.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCFRequest, PCFResponse;

typedef void(^PCFResponseBlock)(PCFResponse *response);

@protocol PCFDataStore <NSObject>

- (PCFResponse *)getWithRequest:(PCFRequest *)request;

- (void)getWithRequest:(PCFRequest *)request completionBlock:(PCFResponseBlock)completionBlock;

- (PCFResponse *)putWithRequest:(PCFRequest *)request;

- (void)putWithRequest:(PCFRequest *)request completionBlock:(PCFResponseBlock)completionBlock;

- (PCFResponse *)deleteWithRequest:(PCFRequest *)request;

- (void)deleteWithRequest:(PCFRequest *)request completionBlock:(PCFResponseBlock)completionBlock;

@end


