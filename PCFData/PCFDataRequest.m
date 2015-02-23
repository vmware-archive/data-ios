//
//  PCFDataRequest.m
//  PCFData
//
//  Created by DX122-XL on 2015-01-12.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "PCFDataRequest.h"
#import "PCFData.h"

@implementation PCFDataRequest

static NSString* const PCFMethod = @"method";
static NSString* const PCFObject = @"object";
static NSString* const PCFFallback = @"fallback";
static NSString* const PCFForce = @"force";
static NSString* const PCFType = @"type";

- (instancetype)initWithRequest:(PCFDataRequest *)request {
    return [self initWithMethod:request.method object:request.object fallback:request.fallback force:request.force];
}

- (instancetype)initWithMethod:(int)method object:(id<PCFMappable>)object {
    return [self initWithMethod:method object:object fallback:nil force:false];
}

- (instancetype)initWithMethod:(int)method object:(id<PCFMappable>)object fallback:(id<PCFMappable>)fallback force:(BOOL)force {
    self = [super init];
    _method = method;
    _object = object;
    _fallback = fallback;
    _force = force;
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    id klass = NSClassFromString([dict objectForKey:PCFType]);
    _method = [[dict objectForKey:PCFMethod] intValue];
    _object = [[klass alloc] initWithDictionary:[dict objectForKey:PCFObject]];
    _fallback = [[klass alloc] initWithDictionary:[dict objectForKey:PCFFallback]];
    _force = [[dict objectForKey:PCFForce] boolValue];
    return self;
}

- (NSDictionary*)toDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (self.method) [dict setObject:[NSString stringWithFormat:@"%d", self.method] forKey:PCFMethod];
    if (self.object) [dict setValue:[self.object toDictionary] forKey:PCFObject];
    if (self.force) [dict setValue:[NSString stringWithFormat:@"%d", self.force] forKey:PCFForce];
    if (self.object) [dict setValue:NSStringFromClass([self.object class]) forKey:PCFType];
    if (self.fallback) [dict setValue:[self.fallback toDictionary] forKey:PCFFallback];
    return dict;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"PCFDataRequest: {Object=%@, Force=%d}", self.object, self.force];
}

@end