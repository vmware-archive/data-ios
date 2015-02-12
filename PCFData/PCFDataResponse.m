//
//  PCFDataResponse.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFDataResponse.h"

@implementation PCFDataResponse

- (instancetype)initWithObject:(id)object {
    _object = object;
    return self;
}

- (instancetype)initWithObject:(id)object error:(NSError *)error {
    _object = object;
    _error = error;
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"PCFDataResponse: {Object=%@, Error=%@}", self.object, self.error];
}

@end