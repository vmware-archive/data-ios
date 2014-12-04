//
//  PCFRemoteStore.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-29.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFRemoteStore.h"
#import "PCFRemoteClient.h"
#import "PCFResponse.h"

@interface PCFRemoteStore ()

@property NSString *collection;
@property (strong, readonly) PCFRemoteClient *client;

@end


@implementation PCFRemoteStore

- (instancetype)initWithCollection:(NSString *)collection {
    return [self initWithCollection:collection client:[[PCFRemoteClient alloc] init]];
}

- (instancetype)initWithCollection:(NSString *)collection client:(PCFRemoteClient *)client {
    _client = client;
    _collection = collection;
    return self;
}

- (NSURL *)urlForKey:(NSString *)key {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", kHostUrl, _collection, key]];
}

- (PCFResponse *)getWithKey:(NSString *)key accessToken:(NSString *)accessToken {
    NSError *error;
    NSString *result = [self.client getWithAccessToken:accessToken url:[self urlForKey:key] error:&error];

    if (error) {
        return [[PCFResponse alloc] initWithKey:key error:error];
    } else {
        return [[PCFResponse alloc] initWithKey:key value:result];
    }
}

- (void)getWithKey:(NSString *)key accessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self getWithKey:key accessToken:accessToken];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFResponse *)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken {
    NSError *error;
    NSString *result = [self.client putWithAccessToken:accessToken url:[self urlForKey:key] value:value error:&error];
    
    if (error) {
        return [[PCFResponse alloc] initWithKey:key error:error];
    } else {
        return [[PCFResponse alloc] initWithKey:key value:result];
    }
}

- (void)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self putWithKey:key value:value accessToken:accessToken];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFResponse *)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken {
    NSError *error;
    NSString *result = [self.client deleteWithAccessToken:accessToken url:[self urlForKey:key] error:&error];
    
    if (error) {
        return [[PCFResponse alloc] initWithKey:key error:error];
    } else {
        return [[PCFResponse alloc] initWithKey:key value:result];
    }
}

- (void)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self deleteWithKey:key accessToken:accessToken];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

@end
