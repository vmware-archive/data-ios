//
//  PCFRequest.m
//  PCFData
//
//  Created by DX122-XL on 2015-01-12.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "PCFRequest.h"

@implementation PCFRequest

static NSString* const PCFAccessToken = @"accessToken";
static NSString* const PCFObject = @"object";
static NSString* const PCFFallback = @"fallback";
static NSString* const PCFForce = @"force";
static NSString* const PCFType = @"type";

- (instancetype)initWithRequest:(PCFRequest *)request {
    self = [self initWithAccessToken:request.accessToken object:request.object force:request.force];
    _fallback = request.fallback;
    return self;
}

- (instancetype)initWithAccessToken:(NSString *)accessToken object:(id<PCFMappable>)object {
    return [self initWithAccessToken:accessToken object:object force:false];
}

- (instancetype)initWithAccessToken:(NSString *)accessToken object:(id<PCFMappable>)object force:(BOOL)force {
    self = [super init];
    self.accessToken = accessToken;
    self.object = object;
    self.force = force;
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    id klass = NSClassFromString([dict objectForKey:PCFType]);
    _object = [[klass alloc] initWithDictionary:[dict objectForKey:PCFObject]];
    _fallback = [[klass alloc] initWithDictionary:[dict objectForKey:PCFFallback]];
    _accessToken = [dict objectForKey:PCFAccessToken];
    _force = [[dict objectForKey:PCFForce] boolValue];
    return self;
}

- (NSDictionary*)toDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (self.accessToken) [dict setValue:self.accessToken forKey:PCFAccessToken];
    if (self.object) [dict setValue:[self.object toDictionary] forKey:PCFObject];
    if (self.force) [dict setValue:[NSString stringWithFormat:@"%d", self.force] forKey:PCFForce];
    if (self.object) [dict setValue:NSStringFromClass([self.object class]) forKey:PCFType];
    if (self.fallback) [dict setValue:[self.fallback toDictionary] forKey:PCFFallback];
    return dict;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"PCFRequest: {Object=%@, Force=%d}", self.object, self.force];
}

@end
