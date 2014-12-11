//
//  PCFRequestCache.m
//  PCFData
//
//  Created by DX122-XL on 2014-11-21.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFRequestCache.h"
#import "PCFOfflineStore.h"
#import "PCFLocalStore.h"
#import "PCFResponse.h"
#import "PCFLogger.h"

@interface PCFRequestCache ()

@property (strong, readonly) NSUserDefaults *defaults;

@end

@implementation PCFRequestCache

static int const HTTP_GET = 0;
static int const HTTP_PUT = 1;
static int const HTTP_DELETE = 2;

static NSString* const PCFDataRequestCache = @"PCFData:RequestCache";


+ (PCFRequestCache *)sharedInstance {
    static PCFRequestCache *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PCFRequestCache alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    return [self initWithDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults {
    _defaults = defaults;
    return self;
}

- (PCFOfflineStore *)createOfflineStoreWithCollection:(NSString *)collection {
    return [[PCFOfflineStore alloc] initWithCollection:collection];
}

- (PCFLocalStore *)createLocalStoreWithCollection:(NSString *)collection {
    return [[PCFLocalStore alloc] initWithCollection:collection];
}

- (void)queueGetWithToken:(NSString *)accessToken collection:(NSString *)collection key:(NSString *)key {
    LogInfo(@"PCFLocalStore queueGetWithToken: key: %@", key);
    PCFPendingRequest *request = [[PCFPendingRequest alloc] initWithMethod:HTTP_GET accessToken:accessToken collection:collection key:key value:nil fallback:nil];
    [self queuePendingRequest:request];
}

- (void)queuePutWithToken:(NSString *)accessToken collection:(NSString *)collection key:(NSString *)key value:(NSString *)value fallback:(NSString *)fallback {
    LogInfo(@"PCFLocalStore queuePutWithToken: key: %@ value: %@", key, value);
    PCFPendingRequest *request = [[PCFPendingRequest alloc] initWithMethod:HTTP_PUT accessToken:accessToken collection:collection key:key value:value fallback:fallback];
    [self queuePendingRequest:request];
}

- (void)queueDeleteWithToken:(NSString *)accessToken collection:(NSString *)collection key:(NSString *)key fallback:(NSString *)fallback {
    LogInfo(@"PCFLocalStore queueDeleteWithToken: key: %@", key);
    PCFPendingRequest *request = [[PCFPendingRequest alloc] initWithMethod:HTTP_DELETE accessToken:accessToken collection:collection key:key value:nil fallback:fallback];
    [self queuePendingRequest:request];
}

- (void)queuePendingRequest:(PCFPendingRequest *)request {
    @synchronized(self) {
        NSMutableArray *array = [[self.defaults objectForKey:PCFDataRequestCache] mutableCopy];
        
        if (!array) {
            array = [[NSMutableArray alloc] initWithObjects:request.values, nil];
        } else {
            [array addObject:request.values];
        }
    
        [self.defaults setObject:array forKey:PCFDataRequestCache];
    }
}

- (void)executePendingRequestsWithToken:(NSString *)accessToken {
    [self executePendingRequestsWithToken:accessToken completionHandler:nil];
}

- (void)executePendingRequestsWithToken:(NSString *)accessToken completionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSMutableArray *requests;
    
    @synchronized(self) {
        requests = [self.defaults objectForKey:PCFDataRequestCache];
        [self.defaults setObject:nil forKey:PCFDataRequestCache];
    }
    
    if (requests.count > 0) {
        [self executePendingRequestsWithToken:accessToken requests:requests];
        
        if (completionHandler) {
            completionHandler(UIBackgroundFetchResultNewData);
        }
    } else {
        if (completionHandler) {
            completionHandler(UIBackgroundFetchResultNoData);
        }
    }
}

- (void)executePendingRequestsWithToken:(NSString *)accessToken requests:(NSArray *)requests {
    for (NSDictionary *dictionary in requests) {
        PCFPendingRequest *request  = [[PCFPendingRequest alloc] initWithDictionary:dictionary];
        PCFOfflineStore *offlineStore = [self createOfflineStoreWithCollection:request.collection];
        
        NSString *token = accessToken ? accessToken : request.accessToken;
        
        switch (request.method) {
            case HTTP_GET: {
                [offlineStore getWithKey:request.key accessToken:token];
                break;
            }
                
            case HTTP_PUT: {
                PCFResponse *response = [offlineStore putWithKey:request.key value:request.value accessToken:token];
                if (response.error) {
                    PCFLocalStore *localStore = [self createLocalStoreWithCollection:request.collection];
                    [localStore putWithKey:request.key value:request.fallback accessToken:token];
                }
                break;
            }
                
            case HTTP_DELETE: {
                PCFResponse *response = [offlineStore deleteWithKey:request.key accessToken:token];
                if (response.error) {
                    PCFLocalStore *localStore = [self createLocalStoreWithCollection:request.collection];
                    [localStore putWithKey:request.key value:request.fallback accessToken:token];
                }
                break;
            }

            default:
                break;
        }
    }
}

@end


@implementation PCFPendingRequest

static NSString* const PCFMethod = @"PCFData:method";
static NSString* const PCFKey = @"PCFData:key";
static NSString* const PCFValue = @"PCFData:value";
static NSString* const PCFCollection = @"PCFData:collection";
static NSString* const PCFFallback = @"PCFData:fallback";
static NSString* const PCFAccessToken = @"PCFData:accessToken";


- (instancetype)initWithDictionary:(NSDictionary *)values {
    _values = values;
    return self;
}

- (instancetype)initWithMethod:(int)method accessToken:(NSString *)accessToken collection:(NSString *)collection key:(NSString *)key value:(NSString *)value fallback:(NSString *)fallback {
    _values = [[NSMutableDictionary alloc] init];
    [_values setValue:[NSNumber numberWithInt:method] forKey:PCFMethod];
    [_values setValue:accessToken forKey:PCFAccessToken];
    [_values setValue:collection forKey:PCFCollection];
    [_values setValue:key forKey:PCFKey];
    [_values setValue:value forKey:PCFValue];
    [_values setValue:fallback forKey:PCFFallback];
    return self;
}

- (int)method {
    return [[self.values objectForKey:PCFMethod] intValue];
}

- (NSString *)key {
    return [self.values objectForKey:PCFKey];
}

- (NSString *)value {
    return [self.values objectForKey:PCFValue];
}

- (NSString *)collection {
    return [self.values objectForKey:PCFCollection];
}

- (NSString *)fallback {
    return [self.values objectForKey:PCFFallback];
}

- (NSString *)accessToken {
    return [self.values objectForKey:PCFAccessToken];
}

@end