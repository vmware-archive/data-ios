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

@property (readonly) PCFRemoteClient *client;

- (instancetype)initWithClient:(PCFRemoteClient *)client;

@end

@implementation PCFRemoteStore

- (instancetype)init {
    return [self initWithClient:[[PCFRemoteClient alloc] init]];
}

- (instancetype)initWithClient:(PCFRemoteClient *)client {
    self = [super init];
    _client = client;
    return self;
}

- (PCFResponse *)getWithRequest:(PCFRequest *)request {
    LogInfo(@"PCFRemoteStore getWithRequest: %@", request);
    return [self.client getWithRequest:request];
}

- (void)getWithRequest:(PCFRequest *)request completionBlock:(PCFResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self getWithRequest:request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFResponse *)putWithRequest:(PCFRequest *)request {
    LogInfo(@"PCFRemoteStore putWithRequest: %@", request);
    return [self.client putWithRequest:request];
}

- (void)putWithRequest:request completionBlock:(PCFResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self putWithRequest:request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFResponse *)deleteWithRequest:(PCFRequest *)request {
    LogInfo(@"PCFRemoteStore deleteWithRequest: %@", request);
    return [self.client deleteWithRequest:request];
}

- (void)deleteWithRequest:(PCFRequest *)request completionBlock:(PCFResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self deleteWithRequest:request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

@end
