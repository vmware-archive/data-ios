//
//  PCFPendingRequest.h
//  PCFData
//
//  Created by DX122-XL on 2015-01-20.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFRequest.h"

@interface PCFPendingRequest : PCFRequest

@property long method;

- (instancetype)initWithRequest:(PCFRequest *)request method:(long)method;

@end
