//
//  PCFRequestCache.m
//  PCFData
//
//  Created by DX122-XL on 2014-11-21.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFRequestCache.h"

@interface PCFRequestCache ()

@property (strong, readonly) NSUserDefaults *defaults;

@end

@implementation PCFRequestCache

static int const HTTP_GET = 0;
static int const HTTP_PUT = 1;
static int const HTTP_DELETE = 2;

static NSString* const PCFDataRequestCache = @"PCFDataRequestCache";

- (instancetype)init {
    return [self initWithDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults {
    _defaults = defaults;
    return self;
}

- (void)queueGetWithToken:(NSString *)accessToken collection:(NSString *)collection key:(NSString *)key {
    PCFPendingRequest *request = [[PCFPendingRequest alloc] initWithMethod:HTTP_GET accessToken:accessToken collection:collection key:key value:nil fallback:nil];
    [self queuePending:request];
}

- (void)queuePutWithToken:(NSString *)accessToken collection:(NSString *)collection key:(NSString *)key value:(NSString *)value fallback:(NSString *)fallback {
    PCFPendingRequest *request = [[PCFPendingRequest alloc] initWithMethod:HTTP_PUT accessToken:accessToken collection:collection key:key value:value fallback:fallback];
    [self queuePending:request];
}

- (void)queueDeleteWithToken:(NSString *)accessToken collection:(NSString *)collection key:(NSString *)key fallback:(NSString *)fallback {
    PCFPendingRequest *request = [[PCFPendingRequest alloc] initWithMethod:HTTP_DELETE accessToken:accessToken collection:collection key:key value:nil fallback:fallback];
    [self queuePending:request];
}

- (void)queuePending:(PCFPendingRequest *)request {
    @synchronized(self) {
        NSMutableArray *array = [self.defaults objectForKey:PCFDataRequestCache];
        [array addObject:request.values];
    
        [self.defaults setObject:array forKey:PCFDataRequestCache];
    }
}

@end


@implementation PCFPendingRequest

- (instancetype)initWithDictionary:(NSDictionary *)values {
    _values = values;
    return self;
}

- (instancetype)initWithMethod:(int)method accessToken:(NSString *)accessToken collection:(NSString *)collection key:(NSString *)key value:(NSString *)value fallback:(NSString *)fallback {
    _values = [[NSMutableDictionary alloc] init];
    [_values setValue:[NSNumber numberWithInt:method] forKey:@"method"];
    [_values setValue:accessToken forKey:@"accessToken"];
    [_values setValue:collection forKey:@"collection"];
    [_values setValue:key forKey:@"key"];
    [_values setValue:value forKey:@"value"];
    [_values setValue:fallback forKey:@"fallback"];
    return self;
}

@end