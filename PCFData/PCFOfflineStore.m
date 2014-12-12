//
//  PCFOfflineStore.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-30.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFOfflineStore.h"
#import "PCFRemoteStore.h"
#import "PCFLocalStore.h"
#import "PCFRequestCache.h"
#import "PCFResponse.h"
#import "PCFReachability.h"
#import "PCFConfig.h"
#import "PCFLogger.h"


@interface PCFOfflineStore ()

@property NSString *collection;
@property PCFRemoteStore *remoteStore;
@property PCFLocalStore *localStore;

@end

@implementation PCFOfflineStore

- (instancetype)initWithCollection:(NSString *)collection {
    PCFRemoteStore *remoteStore = [[PCFRemoteStore alloc] initWithCollection:collection];
    PCFLocalStore *localStore = [[PCFLocalStore alloc] initWithCollection:collection];
    return [self initWithCollection:collection localStore:localStore remoteStore:remoteStore];
}

- (instancetype)initWithCollection:(NSString *)collection localStore:(PCFLocalStore *)localStore remoteStore:(PCFRemoteStore *)remoteStore {
    _collection = collection;
    _remoteStore = remoteStore;
    _localStore = localStore;
    return self;
}

- (PCFRequestCache *)requestCache {
    return [PCFRequestCache sharedInstance];
}

- (PCFResponse *)getWithKey:(NSString *)key accessToken:(NSString *)accessToken {
    return [self getWithKey:key accessToken:accessToken force:false];
}

- (PCFResponse *)getWithKey:(NSString *)key accessToken:(NSString *)accessToken force:(BOOL)force {
    LogInfo(@"PCFOfflineStore getWithKey: %@", key);

    if ([self isConnected]) {
        PCFResponse *response = [self.remoteStore getWithKey:key accessToken:accessToken force:force];
        
        if (!response.error) {
            return [self.localStore putWithKey:key value:response.value accessToken:accessToken force:force];
            
        } else if (response.error.code == 304) {
            return [self.localStore getWithKey:key accessToken:accessToken force:force];
            
        } else {
            return response;
        }
        
    } else {
        PCFResponse *response = [self.localStore getWithKey:key accessToken:accessToken force:force];
        
        if ([self isSyncSupported]) {
            [self.requestCache queueGetWithToken:accessToken collection:self.collection key:key];
        }
        
        return response;
    }
}

- (void)getWithKey:(NSString *)key accessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock {
    [self getWithKey:key accessToken:accessToken force:false completionBlock:completionBlock];
}

- (void)getWithKey:(NSString *)key accessToken:(NSString *)accessToken force:(BOOL)force completionBlock:(PCFResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self getWithKey:key accessToken:accessToken force:force];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFResponse *)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken {
    return [self putWithKey:key value:value accessToken:accessToken force:false];
}

- (PCFResponse *)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken force:(BOOL)force {
    LogInfo(@"PCFOfflineStore putWithKey: %@ value: %@", key, value);
    
    if ([self isConnected]) {
        PCFResponse *response = [self.remoteStore putWithKey:key value:value accessToken:accessToken force:force];
        
        if (!response.error) {
            return [self.localStore putWithKey:key value:value accessToken:accessToken force:force];
        } else {
            return response;
        }
        
    } else if ([self isSyncSupported]) {
        PCFResponse *fallback = [self.localStore getWithKey:key accessToken:accessToken force:force];
        PCFResponse *response = [self.localStore putWithKey:key value:value accessToken:accessToken force:force];
        
        [self.requestCache queuePutWithToken:accessToken collection:self.collection key:key value:value fallback:fallback.value];
        
        return response;
        
    } else {
        return [self errorNoConnectionWithKey:key];
    }
}

- (void)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock {
    return [self putWithKey:key value:value accessToken:accessToken force:false completionBlock:completionBlock];
}

- (void)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken force:(BOOL)force completionBlock:(PCFResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self putWithKey:key value:value accessToken:accessToken force:force];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFResponse *)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken {
    return [self deleteWithKey:key accessToken:accessToken force:false];
}

- (PCFResponse *)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken force:(BOOL)force {
    LogInfo(@"PCFOfflineStore deleteWithKey: %@", key);
    
    if ([self isConnected]) {
        PCFResponse *response = [self.remoteStore deleteWithKey:key accessToken:accessToken force:force];
        
        if (!response.error) {
            return [self.localStore deleteWithKey:key accessToken:accessToken force:force];
        } else {
            return response;
        }
        
    } else if ([self isSyncSupported]) {
        PCFResponse *fallback = [self.localStore getWithKey:key accessToken:accessToken force:force];
        PCFResponse *response = [self.localStore deleteWithKey:key accessToken:accessToken force:force];
        
        [self.requestCache queueDeleteWithToken:accessToken collection:self.collection key:key fallback:fallback.value];
        
        return response;
        
    } else {
        return [self errorNoConnectionWithKey:key];
    }
}

- (void)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock {
    [self deleteWithKey:key accessToken:accessToken force:false completionBlock:completionBlock];
}

- (void)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken force:(BOOL)force completionBlock:(PCFResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self deleteWithKey:key accessToken:accessToken force:force];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFResponse *)errorNoConnectionWithKey:(NSString *)key {
    NSError *error = [[NSError alloc] initWithDomain:kNoConnectionErrorDomain code:kNoConnectionErrorCode userInfo:nil];
    return [[PCFResponse alloc] initWithKey:key error:error];
}

- (BOOL)isConnected {
    NSURL* url = [NSURL URLWithString:[PCFConfig serviceUrl]];
    PCFReachability *reachability = [PCFReachability reachabilityWithHostName:[url host]];
    PCFNetworkStatus netStatus = [reachability currentReachabilityStatus];
    return netStatus != NotReachable;
}

- (BOOL)isSyncSupported {
    return true;
}

@end