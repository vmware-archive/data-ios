//
//  PCFResponse.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFResponse.h"

@implementation PCFResponse

- (instancetype)initWithKey:(NSString *)key value:(NSString *)value {
    _key = key;
    _value = value;
    return self;
}

- (instancetype)initWithKey:(NSString *)key error:(NSError *)error {
    _key = key;
    _error = error;
    return self;
}

@end

@implementation PCFFailureResponse

+ (PCFFailureResponse *)failureResponse:(PCFResponse *)response {
    return [[PCFFailureResponse alloc] initWithKey:response.key error:response.error];
}

@end