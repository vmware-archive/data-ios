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
#import "PCFConfig.h"
#import "PCFLogger.h"

@interface PCFRemoteStore ()

@property NSString *collection;
@property (readonly) PCFRemoteClient *client;

- (instancetype)initWithCollection:(NSString *)collection client:(PCFRemoteClient *)client;

- (NSURL *)urlForKey:(NSString *)key;

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
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", [PCFConfig serviceUrl], self.collection, key]];
}

- (PCFResponse *)getWithKey:(NSString *)key accessToken:(NSString *)accessToken {
    return [self getWithKey:key accessToken:accessToken force:false];
}

- (PCFResponse *)getWithKey:(NSString *)key accessToken:(NSString *)accessToken force:(BOOL)force {
    LogInfo(@"PCFRemoteStore getWithKey: %@", key);
    NSError *error;
    NSString *result = [self.client getWithAccessToken:accessToken url:[self urlForKey:key] error:&error force:force];

    return [self handleResult:result key:key error:error];
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
    LogInfo(@"PCFRemoteStore putWithKey: %@ value: %@", key, value);
    NSError *error;
    NSString *result = [self.client putWithAccessToken:accessToken url:[self urlForKey:key] value:value error:&error force:force];
    
    return [self handleResult:result key:key error:error];
}

- (void)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock {
    [self putWithKey:key value:value accessToken:accessToken force:false completionBlock:completionBlock];
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
    LogInfo(@"PCFRemoteStore deleteWithKey: %@", key);
    NSError *error;
    NSString *result = [self.client deleteWithAccessToken:accessToken url:[self urlForKey:key] error:&error force:force];
    
    return [self handleResult:result key:key error:error];
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

- (PCFResponse *)handleResult:(NSString *)result key:(NSString *)key error:(NSError *)error {
    if (error) {
        return [[PCFResponse alloc] initWithKey:key error:error];
    } else {
        return [[PCFResponse alloc] initWithKey:key value:result];
    }
}

@end
