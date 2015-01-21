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
    _fallback = request.fallback;
    return [self initWithAccessToken:request.accessToken object:request.object force:request.force];
}

- (instancetype)initWithAccessToken:(NSString *)accessToken object:(id<PCFMappable>)object {
    return [self initWithAccessToken:accessToken object:object force:false];
}

- (instancetype)initWithAccessToken:(NSString *)accessToken object:(id<PCFMappable>)object force:(BOOL)force {
    self.accessToken = accessToken;
    self.object = object;
    self.force = force;
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    id klass = NSClassFromString([dict objectForKey:PCFType]);
    _object = [[klass alloc] initWithDictionary:[dict objectForKey:PCFObject]];
    _fallback = [[klass alloc] initWithDictionary:[dict objectForKey:PCFFallback]];
    _accessToken = [dict objectForKey:PCFAccessToken];
    _force = [[dict objectForKey:PCFForce] boolValue];
    return self;
}

- (NSDictionary*)toDictionary {
    return @{
        PCFAccessToken: self.accessToken,
        PCFObject: [self.object toDictionary],
        PCFFallback: [self.fallback toDictionary],
        PCFForce: [NSString stringWithFormat:@"%d", self.force],
        PCFType: NSStringFromClass([self.object class])
    };
}

@end
