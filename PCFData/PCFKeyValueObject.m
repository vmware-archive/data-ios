//
//  PCFKeyValueObject.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFKeyValueObject.h"
#import "PCFKeyValueOfflineStore.h"
#import "PCFDataResponse.h"
#import "PCFDataRequest.h"
#import "PCFKeyValue.h"

@interface PCFKeyValueObject ()

@property id<PCFDataStore> dataStore;

@property NSString *key;
@property NSString *collection;

@end

@implementation PCFKeyValueObject

+ (instancetype)objectWithCollection:(NSString *)collection key:(NSString *)key {
    return [[PCFKeyValueObject alloc] initWithCollection:collection key:key];
}

- (instancetype)initWithCollection:(NSString *)collection key:(NSString *)key {
    PCFKeyValueOfflineStore *dataStore = [[PCFKeyValueOfflineStore alloc] init];
    return [self initWithDataStore:dataStore collection:collection key:key];
}

- (instancetype)initWithDataStore:(id<PCFDataStore>)dataStore collection:(NSString *)collection key:(NSString *)key {
    self = [super init];
    _dataStore = dataStore;
    _collection = collection;
    _key = key;
    return self;
}

- (PCFDataResponse *)get {
    PCFDataRequest *request = [self createRequestWithMethod:PCF_HTTP_GET value:nil];
    return [self.dataStore executeRequest:request];
}

- (void)getWithCompletionBlock:(PCFDataResponseBlock)completionBlock {
    PCFDataRequest *request = [self createRequestWithMethod:PCF_HTTP_GET value:nil];
    [self.dataStore executeRequest:request completionBlock:completionBlock];
}

- (PCFDataResponse *)putWithValue:(NSString *)value {
    PCFDataRequest *request = [self createRequestWithMethod:PCF_HTTP_PUT value:value];
    return [self.dataStore executeRequest:request];
}

- (void)putWithValue:(NSString *)value completionBlock:(PCFDataResponseBlock)completionBlock {
    PCFDataRequest *request = [self createRequestWithMethod:PCF_HTTP_PUT value:value];
    [self.dataStore executeRequest:request completionBlock:completionBlock];
}

- (PCFDataResponse *)delete {
    PCFDataRequest *request = [self createRequestWithMethod:PCF_HTTP_DELETE value:nil];
    return [self.dataStore executeRequest:request];
}

- (void)deleteWithCompletionBlock:(PCFDataResponseBlock)completionBlock {
    PCFDataRequest *request = [self createRequestWithMethod:PCF_HTTP_DELETE value:nil];
    [self.dataStore executeRequest:request completionBlock:completionBlock];
}

- (PCFDataRequest *)createRequestWithMethod:(int)method value:(NSString *)value {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:value];
    PCFDataRequest *request = [[PCFDataRequest alloc] initWithMethod:method object:keyValue fallback:nil force:self.force];
    return request;
}

@end
