//
//  PCFKeyValueObject.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFKeyValueObject.h"
#import "PCFOfflineStore.h"
#import "PCFResponse.h"
#import "PCFRequest.h"
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

- (PCFResponse *)get {
    PCFRequest *request = [self createRequestWithValue:nil];
    return [self.dataStore getWithRequest:request];
}

- (void)getWithCompletionBlock:(PCFResponseBlock)completionBlock {
    PCFRequest *request = [self createRequestWithValue:nil];
    [self.dataStore getWithRequest:request completionBlock:completionBlock];
}

- (PCFResponse *)putWithValue:(NSString *)value {
    PCFRequest *request = [self createRequestWithValue:value];
    return [self.dataStore putWithRequest:request];
}

- (void)putWithValue:(NSString *)value completionBlock:(PCFResponseBlock)completionBlock {
    PCFRequest *request = [self createRequestWithValue:value];
    [self.dataStore putWithRequest:request completionBlock:completionBlock];
}

- (PCFResponse *)delete {
    PCFRequest *request = [self createRequestWithValue:nil];
    return [self.dataStore deleteWithRequest:request];
}

- (void)deleteWithCompletionBlock:(PCFResponseBlock)completionBlock {
    PCFRequest *request = [self createRequestWithValue:nil];
    [self.dataStore deleteWithRequest:request completionBlock:completionBlock];
}

- (PCFRequest *)createRequestWithValue:(NSString *)value {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:value];
    PCFRequest *request = [[PCFRequest alloc] initWithObject:keyValue fallback:nil force:self.force];
    return request;
}

@end
