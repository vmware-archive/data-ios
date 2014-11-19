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


@interface PCFOfflineStore ()

@property NSString *collection;
@property PCFRemoteStore *remoteStore;
@property PCFLocalStore *localStore;

@end

@implementation PCFOfflineStore


- (instancetype)initWithCollection:(NSString *)collection {
    PCFRemoteStore *remoteStore = [[PCFRemoteStore alloc] initWithCollection:collection];
    PCFLocalStore *localStore = [[PCFLocalStore alloc] initWithCollection:collection];
    return [self initWithCollection:collection remoteStore:remoteStore localStore:localStore];
}

- (instancetype)initWithCollection:(NSString *)collection remoteStore:(PCFRemoteStore *)remoteStore localStore:(PCFLocalStore *)localStore {
    _collection = collection;
    _remoteStore = remoteStore;
    _localStore = localStore;
    return self;
}

- (BOOL)isConnected {
    return true;
}

- (PCFResponse *)getWithKey:(NSString *)key accessToken:(NSString *)accessToken {

    if ([self isConnected]) {
        PCFResponse *response = [_remoteStore getWithKey:key accessToken:accessToken];
        
        if (!response.error) {
            [_localStore putWithKey:key value:response.value accessToken:accessToken];
        }
        
        return response;
        
    } else {
        return [_localStore getWithKey:key accessToken:accessToken];
    }
}

- (void)getWithKey:(NSString *)key accessToken:(NSString *)accessToken completionBlock:(void (^)(PCFResponse *))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        PCFResponse *response = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFResponse *)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken {

    if ([self isConnected]) {
        PCFResponse *response = [_remoteStore putWithKey:key value:value accessToken:accessToken];
        
        if (!response.error) {
            [_localStore putWithKey:key value:response.value accessToken:accessToken];
        }
        
        return response;
        
    } else {
        return [_localStore putWithKey:key value:value accessToken:accessToken];
    }
}

- (void)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken completionBlock:(void (^)(PCFResponse *))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        PCFResponse *response = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFResponse *)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken {
    
    if ([self isConnected]) {
        PCFResponse *response = [_remoteStore deleteWithKey:key accessToken:accessToken];
        
        if (!response.error) {
            [_localStore deleteWithKey:key accessToken:accessToken];
        }
        
        return response;
        
    } else {
        return [_localStore deleteWithKey:key accessToken:accessToken];
    }
}

- (void)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken completionBlock:(void (^)(PCFResponse *))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        PCFResponse *response = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

@end