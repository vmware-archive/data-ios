//
//  PCFRemoteStore.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-29.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFRemoteStore.h"

@interface PCFRemoteStore ()

@property PCFRemoteClient *client;
@property NSString *collection;

@end

@implementation PCFRemoteStore

- (instancetype)init {
    return [self initWithClient:[[PCFRemoteClient alloc] init] collection:@""];
}

- (instancetype)initWithClient:(PCFRemoteClient *)client collection:(NSString *)collection {
    _client = client;
    _collection = collection;
    return self;
}

- (PCFResponse *)getWithKey:(NSString *)key accessToken:(NSString *)accessToken {
    NSError *error;
    NSString *result = [_client getWithAccessToken:accessToken url:[self urlForKey:key] error:&error];
    if (error) {
        return [[PCFResponse alloc] initWithKey:key error:error];
    } else {
        return [[PCFResponse alloc] initWithKey:key value:result];
    }
}

- (void)getWithKey:(NSString *)key accessToken:(NSString *)accessToken completionBlock:(void (^)(PCFResponse *))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self getWithKey:key accessToken:accessToken];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFResponse *)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken {
    NSError *error;
    NSString *result = [_client putWithAccessToken:accessToken value:value url:[self urlForKey:key] error:&error];
    if (error) {
        return [[PCFResponse alloc] initWithKey:key error:error];
    } else {
        return [[PCFResponse alloc] initWithKey:key value:result];
    }
}

- (void)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken completionBlock:(void (^)(PCFResponse *))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self putWithKey:key value:value accessToken:accessToken];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFResponse *)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken {
    NSError *error;
    NSString *result = [_client deleteWithAccessToken:accessToken url:[self urlForKey:key] error:&error];
    if (error) {
        return [[PCFResponse alloc] initWithKey:key error:error];
    } else {
        return [[PCFResponse alloc] initWithKey:key value:result];
    }
}

- (void)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken completionBlock:(void (^)(PCFResponse *))completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self deleteWithKey:key accessToken:accessToken];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (NSURL *)urlForKey:(NSString *)key {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@/", @"serviceBaseUrl", _collection, key]];
}

@end
