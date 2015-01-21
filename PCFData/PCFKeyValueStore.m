//
//  PCFKeyValueStore.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFKeyValueStore.h"
#import "PCFResponse.h"
#import "PCFRequest.h"
#import "PCFLogger.h"
#import "PCFKeyValue.h"
#import "PCFDataPersistence.h"

@interface PCFKeyValueStore ()

@property (readonly) PCFDataPersistence *persistence;

@end

@implementation PCFKeyValueStore

static NSString* const PCFDataPrefix = @"PCFData:Data:";

- (instancetype)init {
    return [self initWithPersistence:[[PCFDataPersistence alloc] init]];
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
    return [PCFDataPrefix stringByAppendingFormat:@"%@:%@", keyValue.collection, keyValue.key];
}

- (PCFResponse *)getWithRequest:(PCFRequest *)request {
    LogInfo(@"PCFKeyValueStore getWithRequest: %@", request);
    
    PCFKeyValue *requestObject = (PCFKeyValue *)request.object;
    
    NSString *identifier = [PCFKeyValueStore identifierWithKeyValue:requestObject];
    NSString *value = [self.persistence getValueForKey:identifier];
    
    PCFKeyValue *response = [[PCFKeyValue alloc] initWithKeyValue:requestObject];
    response.value = value;
    
    return [[PCFResponse alloc] initWithObject:response];
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
    LogInfo(@"PCFKeyValueStore putWithRequest: %@", request);
    
    PCFKeyValue *requestObject = (PCFKeyValue *)request.object;
    
    NSString *identifier = [PCFKeyValueStore identifierWithKeyValue:requestObject];

    [self.persistence putValue:requestObject.value forKey:identifier];
    
    return [[PCFResponse alloc] initWithObject:requestObject];
}

- (void)putWithRequest:(PCFRequest *)request completionBlock:(PCFResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self putWithRequest:request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFResponse *)deleteWithRequest:(PCFRequest *)request {
    LogInfo(@"PCFKeyValueStore deleteWithRequest: %@", request);
    
    PCFKeyValue *requestObject = (PCFKeyValue *)request.object;
    
    NSString *identifier = [PCFKeyValueStore identifierWithKeyValue:requestObject];
    
    [self.persistence deleteValueForKey:identifier];
    
    PCFKeyValue *response = [[PCFKeyValue alloc] initWithKeyValue:requestObject];
    response.value = nil;
    
    return [[PCFResponse alloc] initWithObject:response];
}

- (void)deleteWithRequest:(PCFRequest *)request completionBlock:(PCFResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self deleteWithRequest:request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    // any change from nsuserdefaults
//}

@end
