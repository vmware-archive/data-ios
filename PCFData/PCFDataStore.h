//
//  PCFDataStore.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCFDataRequest, PCFDataResponse;

typedef void(^PCFDataResponseBlock)(PCFDataResponse *response);

@protocol PCFDataStore <NSObject>

- (PCFDataResponse *)getWithRequest:(PCFDataRequest *)request;

- (void)getWithRequest:(PCFDataRequest *)request completionBlock:(PCFDataResponseBlock)completionBlock;

- (PCFDataResponse *)putWithRequest:(PCFDataRequest *)request;

- (void)putWithRequest:(PCFDataRequest *)request completionBlock:(PCFDataResponseBlock)completionBlock;

- (PCFDataResponse *)deleteWithRequest:(PCFDataRequest *)request;

- (void)deleteWithRequest:(PCFDataRequest *)request completionBlock:(PCFDataResponseBlock)completionBlock;

@end


