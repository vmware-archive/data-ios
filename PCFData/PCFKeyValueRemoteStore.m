//
//  PCFRemoteStore.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-29.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFKeyValueRemoteStore.h"
#import "PCFRemoteClient.h"
#import "PCFDataResponse.h"
#import "PCFDataConfig.h"
#import "PCFDataLogger.h"

@interface PCFKeyValueRemoteStore ()

@property (readonly) PCFRemoteClient *client;

- (instancetype)initWithClient:(PCFRemoteClient *)client;

@end

@implementation PCFKeyValueRemoteStore

- (instancetype)init {
    return [self initWithClient:[[PCFRemoteClient alloc] init]];
}

- (instancetype)initWithClient:(PCFRemoteClient *)client {
    self = [super init];
    _client = client;
    return self;
}

- (NSURL *)urlForKeyValue:(PCFKeyValue *)keyValue {
    NSString *url = [[PCFDataConfig serviceUrl] stringByAppendingFormat:@"/%@/%@", keyValue.collection, keyValue.key];
    return [NSURL URLWithString:url];
}

- (PCFDataResponse *)executeRequest:(PCFDataRequest *)request {
    LogInfo(@"PCFKeyValueRemoteStore executeRequest: %@", request);
    
    PCFKeyValue *requestObject = (PCFKeyValue *)request.object;
    
    @try {
        NSError *error;
        PCFKeyValue *response = [[PCFKeyValue alloc] initWithKeyValue:requestObject];
        response.value = [self executeRequestForMethod:request error:&error];
        
        return [[PCFDataResponse alloc] initWithObject:response error:error];
    }
    
    @catch (NSException *exception) {
        NSError *error = [[NSError alloc] initWithDomain:exception.reason code:-1 userInfo:nil];
        return [[PCFDataResponse alloc] initWithObject:nil error:error];
    }
}

- (NSString *)executeRequestForMethod:(PCFDataRequest *)request error:(NSError *__autoreleasing *)error {
    
    PCFKeyValue *requestObject = (PCFKeyValue *)request.object;
    NSURL *url = [self urlForKeyValue:requestObject];
    
    switch (request.method) {
        case PCF_HTTP_GET:
            LogInfo(@"PCFKeyValueRemoteStore getWithRequest: %@", request);
            return [self.client getWithUrl:url force:request.force error:error];
            
        case PCF_HTTP_PUT:
            LogInfo(@"PCFKeyValueRemoteStore putWithRequest: %@", request);
            return [self.client putWithUrl:url body:requestObject.value force:request.force error:error];
            
        case PCF_HTTP_DELETE:
            LogInfo(@"PCFKeyValueRemoteStore deleteWithRequest: %@", request);
            return [self.client deleteWithUrl:url force:request.force error:error];
            
        default:
            @throw [NSException exceptionWithName:PCFExecutionError reason:PCFUnsupportedOperation userInfo:nil];
    }
}

- (void)executeRequest:(PCFDataRequest *)request completionBlock:(PCFDataResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFDataResponse *response = [self executeRequest:request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(response);
            }
        });
    });
}

@end
