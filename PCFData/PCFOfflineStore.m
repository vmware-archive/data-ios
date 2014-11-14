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
    PCFResponse *response = [_localStore getWithKey:key accessToken:accessToken];
    
    if ([self isConnected]) {
        [_remoteStore getWithKey:key accessToken:accessToken completionBlock:^(PCFResponse *response) {
            if (response.error) {
                // tell observers/retry?
            } else {
                [_localStore putWithKey:key value:response.value accessToken:accessToken];
            }
        }];
    }
    
    return [PCFPendingResponse pendingResponse:response];
}

- (PCFResponse *)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken {
    PCFResponse *response = [_localStore putWithKey:key value:value accessToken:accessToken];
    
    if ([self isConnected]) {
        [_remoteStore putWithKey:key value:value accessToken:accessToken completionBlock:^(PCFResponse *response) {
            if (response.error) {
                // tell observers/retry?
            } else {
                [_localStore putWithKey:key value:response.value accessToken:accessToken];
            }
        }];
    }
    
    return [PCFPendingResponse pendingResponse:response];
}

- (PCFResponse *)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken {
    PCFResponse *response = [_localStore deleteWithKey:key accessToken:accessToken];
    
    if ([self isConnected]) {
        [_remoteStore deleteWithKey:key accessToken:accessToken completionBlock:^(PCFResponse *response) {
            if (response.error) {
                // tell observers/retry?
            } else {
                [_localStore deleteWithKey:key accessToken:accessToken];
            }
        }];
    }
    
    return [PCFPendingResponse pendingResponse:response];
}

@end