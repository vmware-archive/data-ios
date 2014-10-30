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
    return [self initWithRemoteStore:[PCFRemoteStore new] localStore:[PCFLocalStore new] collection:collection];
}

- (instancetype)initWithRemoteStore:(id<PCFDataStore>)remoteStore localStore:(id<PCFDataStore>)localStore collection:(NSString *)collection {
    _collection = collection;
    _remoteStore = remoteStore;
    _localStore = localStore;
    return self;
}

- (PCFResponse *)getWithKey:(NSString *)key accessToken:(NSString *)accessToken {
    if ([self isConnected]) {
        [_remoteStore getWithKey:key accessToken:accessToken completionBlock:^(PCFResponse *response) {
            if (response.error) {
                // tell observers about error; maybe through a state change?
            } else {
                // tell observers about change
                [_localStore putWithKey:key value:response.value accessToken:accessToken];
            }
        }];
    }
    return [PCFPendingResponse pendingResponse:[_localStore getWithKey:key accessToken:accessToken]];
}

- (PCFResponse *)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken {
    if ([self isConnected]) {
        [_remoteStore putWithKey:key value:value accessToken:accessToken completionBlock:^(PCFResponse *response) {
            if (response.error) {
                // tell observers/retry?
            } else {
                // should we re-update? What if the network call changes the new value somehow?
            }
        }];
    }
    return [PCFPendingResponse pendingResponse:[_localStore putWithKey:key value:value accessToken:accessToken]];
}

- (PCFResponse *)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken {
    if ([self isConnected]) {
        [_remoteStore deleteWithKey:key accessToken:accessToken completionBlock:^(PCFResponse *response) {
            if (response.error) {
                // tell observers/retry? maybe when the offline request queue is inplace, we can add it there for later
                // are there a class of errors where we should retry? next time someone does a get the value will return otherwise
            }
        }];
    }
    return [PCFPendingResponse pendingResponse:[_localStore deleteWithKey:key accessToken:accessToken]];
}

// TODO real connectivityz
- (BOOL)isConnected {
    return true;
}

@end
