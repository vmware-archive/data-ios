//
//  PCFKeyValue.m
//  PCFData
//
//  Created by DX122-XL on 2015-01-15.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "PCFKeyValue.h"
#import "PCFDataConfig.h"
#import "PCFRequest.h"

@implementation PCFKeyValue

static NSString* const PCFCollection = @"collection";
static NSString* const PCFKey = @"key";
static NSString* const PCFValue = @"value";


- (instancetype)initWithKeyValue:(PCFKeyValue *)keyValue {
    return [self initWithCollection:keyValue.collection key:keyValue.key value:keyValue.value];
}

- (instancetype)initWithCollection:(NSString *)collection key:(NSString *)key value:(NSString *)value {
    _collection = collection;
    _key = key;
    _value = value;
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    _collection = [dict objectForKey:PCFCollection];
    _key = [dict objectForKey:PCFKey];
    _value = [dict objectForKey:PCFValue];
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (self.collection) [dict setObject:self.collection forKey:PCFCollection];
    if (self.key) [dict setObject:self.key forKey:PCFKey];
    if (self.value) [dict setObject:self.value forKey:PCFValue];
    return dict;
}

- (NSURL *)url {
    NSString *url = [[PCFDataConfig serviceUrl] stringByAppendingFormat:@"/%@/%@", self.collection, self.key];
    return [NSURL URLWithString:url];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"PCFKeyValue: {Collection=%@, Key=%@, Value=%@}", self.collection, self.key, self.value];
}

@end
