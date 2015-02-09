//
//  PCFRequest.m
//  PCFData
//
//  Created by DX122-XL on 2015-01-12.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "PCFRequest.h"
#import "PCFData.h"

@interface PCFData ()

+ (NSString*)provideTokenWithUserPrompt;

@end

@implementation PCFRequest

static NSString* const PCFObject = @"object";
static NSString* const PCFFallback = @"fallback";
static NSString* const PCFForce = @"force";
static NSString* const PCFType = @"type";

- (instancetype)initWithRequest:(PCFRequest *)request {
    return [self initWithObject:request.object fallback:request.fallback force:request.force];
}

- (instancetype)initWithObject:(id<PCFMappable>)object {
    return [self initWithObject:object fallback:nil force:false];
}

- (instancetype)initWithObject:(id<PCFMappable>)object fallback:(id<PCFMappable>)fallback force:(BOOL)force {
    self = [super init];
    self.object = object;
    self.fallback = fallback;
    self.force = force;
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    id klass = NSClassFromString([dict objectForKey:PCFType]);
    _object = [[klass alloc] initWithDictionary:[dict objectForKey:PCFObject]];
    _fallback = [[klass alloc] initWithDictionary:[dict objectForKey:PCFFallback]];
    _force = [[dict objectForKey:PCFForce] boolValue];
    return self;
}

- (NSDictionary*)toDictionary {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (self.object) [dict setValue:[self.object toDictionary] forKey:PCFObject];
    if (self.force) [dict setValue:[NSString stringWithFormat:@"%d", self.force] forKey:PCFForce];
    if (self.object) [dict setValue:NSStringFromClass([self.object class]) forKey:PCFType];
    if (self.fallback) [dict setValue:[self.fallback toDictionary] forKey:PCFFallback];
    return dict;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"PCFRequest: {Object=%@, Force=%d}", self.object, self.force];
}

- (NSString *)accessToken {
    return [PCFData provideTokenWithUserPrompt];
}

@end
