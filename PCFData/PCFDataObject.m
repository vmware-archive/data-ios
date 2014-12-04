//
//  PCFDataObject.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFDataObject.h"

@interface PCFDataObject ()

@property id<PCFDataStore> dataStore;

@property NSString *key;
@property NSString *collection;

@end

@implementation PCFDataObject

- (instancetype)initWithDataStore:(id<PCFDataStore>)dataStore key:(NSString *)key {
    _key = key;
    _dataStore = dataStore;
    return self;
}

- (PCFResponse *)getWithAccessToken:(NSString *)accessToken {
    return [self.dataStore getWithKey:self.key accessToken:accessToken];
}

- (void)getWithAccessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock {
    [self.dataStore getWithKey:self.key accessToken:accessToken completionBlock:completionBlock];
}

- (PCFResponse *)putWithAccessToken:(NSString *)accessToken value:(NSString *)value {
    return [self.dataStore putWithKey:self.key value:value accessToken:accessToken];
}

- (void)putWithAccessToken:(NSString *)accessToken value:(NSString *)value completionBlock:(PCFResponseBlock)completionBlock {
    [self.dataStore putWithKey:self.key value:value accessToken:accessToken completionBlock:completionBlock];
}

- (PCFResponse *)deleteWithAccessToken:(NSString *)accessToken {
    return [self.dataStore deleteWithKey:self.key accessToken:accessToken];
}

- (void)deleteWithAccessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock {
    [self.dataStore deleteWithKey:self.key accessToken:accessToken completionBlock:completionBlock];
}

@end
