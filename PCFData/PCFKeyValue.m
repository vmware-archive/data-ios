//
//  PCFKeyValue.m
//  PCFData
//
//  Created by DX122-XL on 2015-01-15.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "PCFKeyValue.h"
#import "PCFConfig.h"
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
    return @{
         PCFCollection: self.collection,
         PCFKey: self.key,
         PCFValue: self.value,
    };
}

- (NSURL *)url {
    NSString *url = [[PCFConfig serviceUrl] stringByAppendingFormat:@"/%@/%@", self.collection, self.key];
    return [NSURL URLWithString:url];
}

@end
