//
//  PCFRemoteClient.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-29.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCFRequest, PCFResponse;

@interface PCFRemoteClient : NSObject

- (PCFResponse *)getWithRequest:(PCFRequest *)request;

- (PCFResponse *)putWithRequest:(PCFRequest *)request;

- (PCFResponse *)deleteWithRequest:(PCFRequest *)request;

@end
