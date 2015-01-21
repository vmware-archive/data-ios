//
//  PCFResponse.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFResponse.h"

@implementation PCFResponse

- (instancetype)initWithObject:(id)object {
    _object = object;
    return self;
}

- (instancetype)initWithObject:(id)object error:(NSError *)error {
    _object = object;
    _error = error;
    return self;
}

@end