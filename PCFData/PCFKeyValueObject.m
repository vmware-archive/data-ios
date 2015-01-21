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

@end

@implementation PCFKeyValueObject

- (instancetype)initWithCollection:(NSString *)collection key:(NSString *)key {
    PCFOfflineStore *dataStore = [[PCFOfflineStore alloc] init];
    return [self initWithDataStore:dataStore collection:collection key:key];
}

- (instancetype)initWithDataStore:(id<PCFDataStore>)dataStore collection:(NSString *)collection key:(NSString *)key {
    _collection = collection;
    _key = key;
    _dataStore = dataStore;
    return self;
}

- (PCFResponse *)getWithAccessToken:(NSString *)accessToken {
    return [self getWithAccessToken:accessToken force:false];
}

- (PCFResponse *)getWithAccessToken:(NSString *)accessToken force:(BOOL)force {
    PCFRequest *request = [self createRequestWithAccessToken:accessToken value:nil force:force];
    return [self.dataStore getWithRequest:request];
}

- (void)getWithAccessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock {
    [self getWithAccessToken:accessToken force:false completionBlock:completionBlock];
}

- (void)getWithAccessToken:(NSString *)accessToken force:(BOOL)force completionBlock:(PCFResponseBlock)completionBlock {
    PCFRequest *request = [self createRequestWithAccessToken:accessToken value:nil force:force];
    [self.dataStore getWithRequest:request completionBlock:completionBlock];
}

- (PCFResponse *)putWithAccessToken:(NSString *)accessToken value:(NSString *)value {
    return [self putWithAccessToken:accessToken value:value force:false];
}

- (PCFResponse *)putWithAccessToken:(NSString *)accessToken value:(NSString *)value force:(BOOL)force {
    PCFRequest *request = [self createRequestWithAccessToken:accessToken value:value force:force];
    return [self.dataStore putWithRequest:request];
}

- (void)putWithAccessToken:(NSString *)accessToken value:(NSString *)value completionBlock:(PCFResponseBlock)completionBlock {
    [self putWithAccessToken:accessToken value:value force:false completionBlock:completionBlock];
}

- (void)putWithAccessToken:(NSString *)accessToken value:(NSString *)value force:(BOOL)force completionBlock:(PCFResponseBlock)completionBlock {
    PCFRequest *request = [self createRequestWithAccessToken:accessToken value:value force:force];
    [self.dataStore putWithRequest:request completionBlock:completionBlock];
}

- (PCFResponse *)deleteWithAccessToken:(NSString *)accessToken {
    return [self deleteWithAccessToken:accessToken force:false];
}

- (PCFResponse *)deleteWithAccessToken:(NSString *)accessToken force:(BOOL)force {
    PCFRequest *request = [self createRequestWithAccessToken:accessToken value:nil force:force];
    return [self.dataStore deleteWithRequest:request];
}

- (void)deleteWithAccessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock {
    [self deleteWithAccessToken:accessToken force:false completionBlock:completionBlock];
}

- (void)deleteWithAccessToken:(NSString *)accessToken force:(BOOL)force completionBlock:(PCFResponseBlock)completionBlock {
    PCFRequest *request = [self createRequestWithAccessToken:accessToken value:nil force:force];
    [self.dataStore deleteWithRequest:request completionBlock:completionBlock];
}

- (PCFRequest *)createRequestWithAccessToken:(NSString *)accessToken value:(NSString *)value force:(BOOL)force {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:value];
    PCFRequest *request = [[PCFRequest alloc] initWithAccessToken:accessToken object:keyValue force:force];
    return request;
}

@end
