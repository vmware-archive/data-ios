//
//  PCFKeyValueStore.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFKeyValueLocalStore.h"
#import "PCFDataResponse.h"
#import "PCFDataRequest.h"
#import "PCFDataLogger.h"
#import "PCFKeyValue.h"
#import "PCFDataPersistence.h"

@interface PCFKeyValueLocalStore ()

@property (readonly) PCFDataPersistence *persistence;

@end

@implementation PCFKeyValueLocalStore

- (instancetype)init {
    return [self initWithPersistence:[[PCFDataPersistence alloc] initWithDomainName:PCFDataPrefix]];
}

- (instancetype)initWithPersistence:(PCFDataPersistence *)persistence {
    self = [super init];
    _persistence = persistence;
//    [_defaults addObserver:self forKeyPath:PCFDataDefaultsKey options:NSKeyValueObservingOptionNew context:0];
    return self;
}

//- (void)dealloc {
//    [_defaults removeObserver:self forKeyPath:PCFDataDefaultsKey];
//}

+ (NSString *)identifierWithKeyValue:(PCFKeyValue *)keyValue {
    return [keyValue.collection stringByAppendingFormat:@":%@", keyValue.key];
}

- (PCFDataResponse *)executeRequest:(PCFDataRequest *)request {
    LogInfo(@"PCFKeyValueLocalStore executeRequest: %@", request);
    
    @try {
        PCFKeyValue *requestObject = (PCFKeyValue *)request.object;
        
        PCFKeyValue *response = [[PCFKeyValue alloc] initWithKeyValue:requestObject];
        response.value = [self executeRequestForMethod:request];
        
        return [[PCFDataResponse alloc] initWithObject:response];
    }
    
    @catch (NSException *exception) {
        NSError *error = [[NSError alloc] initWithDomain:exception.reason code:-1 userInfo:nil];
        return [[PCFDataResponse alloc] initWithObject:nil error:error];
    }
}

- (NSString *)executeRequestForMethod:(PCFDataRequest *)request {
    
    PCFKeyValue *requestObject = (PCFKeyValue *)request.object;
    NSString *identifier = [PCFKeyValueLocalStore identifierWithKeyValue:requestObject];
    
    switch (request.method) {
        case PCF_HTTP_GET:
            LogInfo(@"PCFKeyValueLocalStore getWithRequest: %@", request);
            return [self.persistence getValueForKey:identifier];
            
        case PCF_HTTP_PUT:
            LogInfo(@"PCFKeyValueLocalStore putWithRequest: %@", request);
            return [self.persistence putValue:requestObject.value forKey:identifier];
            
        case PCF_HTTP_DELETE:
            LogInfo(@"PCFKeyValueLocalStore deleteWithRequest: %@", request);
            return [self.persistence deleteValueForKey:identifier];
            
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

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    // any change from nsuserdefaults
//}

@end
