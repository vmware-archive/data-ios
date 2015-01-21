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
    _method = method;
    return [super initWithRequest:request];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    _method = [[dict objectForKey:PCFMethod] intValue];
    return [super initWithDictionary:dict];
}

- (NSDictionary*)toDictionary {
    NSMutableDictionary *dict = [[super toDictionary] mutableCopy];
    [dict setObject:[NSString stringWithFormat:@"%ld", self.method] forKey:PCFMethod];
    return dict;
}

@end
