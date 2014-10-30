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

- (NSString *)getWithAccessToken:(NSString *)accessToken {
    return [_dataStore getWithKey:_key accessToken:accessToken].value;
}

- (NSString *)putWithAccessToken:(NSString *)accessToken value:(NSString *)value {
    return [_dataStore putWithKey:_key value:value accessToken:accessToken].value;
}

- (NSString *)deleteWithAccessToken:(NSString *)accessToken {
    return [_dataStore deleteWithKey:_key accessToken:accessToken].value;
}

@end
