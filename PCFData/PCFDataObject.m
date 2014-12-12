//
//  PCFDataObject.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFDataObject.h"
#import "PCFOfflineStore.h"

@interface PCFDataObject ()

@property id<PCFDataStore> dataStore;

@property NSString *key;
@property NSString *collection;

@end

@implementation PCFDataObject

- (instancetype)initWithCollection:(NSString *)collection key:(NSString *)key {
    PCFOfflineStore *dataStore = [[PCFOfflineStore alloc] initWithCollection:collection];
    return [self initWithDataStore:dataStore key:key];
}

- (instancetype)initWithDataStore:(id<PCFDataStore>)dataStore key:(NSString *)key {
    _key = key;
    _dataStore = dataStore;
    return self;
}

- (PCFResponse *)getWithAccessToken:(NSString *)accessToken {
    return [self getWithAccessToken:accessToken force:false];
}

- (PCFResponse *)getWithAccessToken:(NSString *)accessToken force:(BOOL)force {
    return [self.dataStore getWithKey:self.key accessToken:accessToken force:force];
}

- (void)getWithAccessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock {
    [self getWithAccessToken:accessToken force:false completionBlock:completionBlock];
}

- (void)getWithAccessToken:(NSString *)accessToken force:(BOOL)force completionBlock:(PCFResponseBlock)completionBlock {
    [self.dataStore getWithKey:self.key accessToken:accessToken force:force completionBlock:completionBlock];
}

- (PCFResponse *)putWithAccessToken:(NSString *)accessToken value:(NSString *)value {
    return [self putWithAccessToken:accessToken value:value force:false];
}

- (PCFResponse *)putWithAccessToken:(NSString *)accessToken value:(NSString *)value force:(BOOL)force {
    return [self.dataStore putWithKey:self.key value:value accessToken:accessToken force:force];
}

- (void)putWithAccessToken:(NSString *)accessToken value:(NSString *)value completionBlock:(PCFResponseBlock)completionBlock {
    [self putWithAccessToken:accessToken value:value force:false completionBlock:completionBlock];
}

- (void)putWithAccessToken:(NSString *)accessToken value:(NSString *)value force:(BOOL)force completionBlock:(PCFResponseBlock)completionBlock {
    [self.dataStore putWithKey:self.key value:value accessToken:accessToken force:force completionBlock:completionBlock];
}

- (PCFResponse *)deleteWithAccessToken:(NSString *)accessToken {
    return [self deleteWithAccessToken:accessToken force:false];
}

- (PCFResponse *)deleteWithAccessToken:(NSString *)accessToken force:(BOOL)force {
    return [self.dataStore deleteWithKey:self.key accessToken:accessToken force:force];
}

- (void)deleteWithAccessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock {
    [self deleteWithAccessToken:accessToken force:false completionBlock:completionBlock];
}

- (void)deleteWithAccessToken:(NSString *)accessToken force:(BOOL)force completionBlock:(PCFResponseBlock)completionBlock {
    [self.dataStore deleteWithKey:self.key accessToken:accessToken force:force completionBlock:completionBlock];
}

@end
