//
//  PCFTestMappable.m
//  PCFData
//
//  Created by DX122-XL on 2015-01-20.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "PCFTestMappable.h"

@implementation PCFTestMappable

static NSString* const PCFValue = @"value";

- (instancetype)init {
    _value = [NSUUID UUID].UUIDString;
    return self;
}

- (instancetype)initWithValue:(NSString *)value {
    _value = value;
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    _value = [dict objectForKey:PCFValue];
    return self;
}

- (NSDictionary *)toDictionary {
    return @{ PCFValue: self.value };
}

@end
