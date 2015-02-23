//
//  PCFDataRequest.h
//  PCFData
//
//  Created by DX122-XL on 2015-01-12.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFMappable.h"

static int const PCF_HTTP_GET = 1;
static int const PCF_HTTP_PUT = 2;
static int const PCF_HTTP_DELETE = 3;

static NSString* const PCFExecutionError = @"PCFExecutionError";
static NSString* const PCFUnsupportedOperation = @"Unsupported request method.";

@interface PCFDataRequest : NSObject <PCFMappable>

@property int method;
@property id<PCFMappable> object;
@property id<PCFMappable> fallback;
@property BOOL force;

- (instancetype)initWithRequest:(PCFDataRequest *)request;

- (instancetype)initWithMethod:(int)method object:(id<PCFMappable>)object;

- (instancetype)initWithMethod:(int)method object:(id<PCFMappable>)object fallback:(id<PCFMappable>)fallback force:(BOOL)force;

@end
