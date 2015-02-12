//
//  PCFRemoteClient.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-29.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCFDataRequest, PCFDataResponse;

@interface PCFRemoteClient : NSObject

- (PCFDataResponse *)getWithRequest:(PCFDataRequest *)request;

- (PCFDataResponse *)putWithRequest:(PCFDataRequest *)request;

- (PCFDataResponse *)deleteWithRequest:(PCFDataRequest *)request;

@end
