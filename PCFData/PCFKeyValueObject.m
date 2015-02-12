//
//  PCFKeyValueObject.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFKeyValueObject.h"
#import "PCFOfflineStore.h"
#import "PCFDataResponse.h"
#import "PCFDataRequest.h"
#import "PCFKeyValue.h"

@interface PCFKeyValueObject ()

@property id<PCFDataStore> dataStore;

@property NSString *key;
@property NSString *collection;
@property BOOL force;

@end

@implementation PCFKeyValueObject

+ (instancetype)objectWithCollection:(NSString *)collection key:(NSString *)key {
    return [[PCFKeyValueObject alloc] initWithCollection:collection key:key];
}

- (instancetype)initWithCollection:(NSString *)collection key:(NSString *)key {
    PCFOfflineStore *dataStore = [[PCFOfflineStore alloc] init];
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
    PCFDataRequest *request = [self createRequestWithValue:nil];
    return [self.dataStore getWithRequest:request];
}

- (void)getWithCompletionBlock:(PCFDataResponseBlock)completionBlock {
    PCFDataRequest *request = [self createRequestWithValue:nil];
    [self.dataStore getWithRequest:request completionBlock:completionBlock];
}

- (PCFDataResponse *)putWithValue:(NSString *)value {
    PCFDataRequest *request = [self createRequestWithValue:value];
    return [self.dataStore putWithRequest:request];
}

- (void)putWithValue:(NSString *)value completionBlock:(PCFDataResponseBlock)completionBlock {
    PCFDataRequest *request = [self createRequestWithValue:value];
    [self.dataStore putWithRequest:request completionBlock:completionBlock];
}

- (PCFDataResponse *)delete {
    PCFDataRequest *request = [self createRequestWithValue:nil];
    return [self.dataStore deleteWithRequest:request];
}

- (void)deleteWithCompletionBlock:(PCFDataResponseBlock)completionBlock {
    PCFDataRequest *request = [self createRequestWithValue:nil];
    [self.dataStore deleteWithRequest:request completionBlock:completionBlock];
}

- (PCFDataRequest *)createRequestWithValue:(NSString *)value {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:value];
    PCFDataRequest *request = [[PCFDataRequest alloc] initWithObject:keyValue fallback:nil force:self.force];
    return request;
}

@end
