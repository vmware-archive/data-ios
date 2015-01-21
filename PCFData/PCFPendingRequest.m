//
//  PCFPendingRequest.m
//  PCFData
//
//  Created by DX122-XL on 2015-01-20.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "PCFPendingRequest.h"

@implementation PCFPendingRequest

static NSString* const PCFMethod = @"method";

- (instancetype)initWithRequest:(PCFRequest *)request method:(long)method {
    self = [super initWithRequest:request];
    _method = method;
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    _method = [[dict objectForKey:PCFMethod] intValue];
    return self;
}

- (NSDictionary*)toDictionary {
    NSMutableDictionary *dict = [[super toDictionary] mutableCopy];
    if (self.method) [dict setObject:[NSString stringWithFormat:@"%ld", self.method] forKey:PCFMethod];
    return dict;
}

@end
