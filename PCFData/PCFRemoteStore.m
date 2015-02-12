//
//  PCFRemoteStore.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-29.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFRemoteStore.h"
#import "PCFRemoteClient.h"
#import "PCFDataResponse.h"
#import "PCFDataConfig.h"
#import "PCFDataLogger.h"

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

- (PCFDataResponse *)getWithRequest:(PCFDataRequest *)request {
    LogInfo(@"PCFRemoteStore getWithRequest: %@", request);
    return [self.client getWithRequest:request];
}

- (void)getWithRequest:(PCFDataRequest *)request completionBlock:(PCFDataResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFDataResponse *response = [self getWithRequest:request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFDataResponse *)putWithRequest:(PCFDataRequest *)request {
    LogInfo(@"PCFRemoteStore putWithRequest: %@", request);
    return [self.client putWithRequest:request];
}

- (void)putWithRequest:request completionBlock:(PCFDataResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFDataResponse *response = [self putWithRequest:request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFDataResponse *)deleteWithRequest:(PCFDataRequest *)request {
    LogInfo(@"PCFRemoteStore deleteWithRequest: %@", request);
    return [self.client deleteWithRequest:request];
}

- (void)deleteWithRequest:(PCFDataRequest *)request completionBlock:(PCFDataResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFDataResponse *response = [self deleteWithRequest:request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

@end
