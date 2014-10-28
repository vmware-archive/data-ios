//
//  PCFLocalStore.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFLocalStore.h"

static NSString *const PCFDataDefaultsKey = @"PCFData";

@interface PCFLocalStore ()

@property (strong) NSMutableDictionary *values;

@end

@implementation PCFLocalStore

- (instancetype)init {
    return [[PCFLocalStore alloc] initWithValues:[[NSUserDefaults standardUserDefaults] objectForKey:PCFDataDefaultsKey]];
}

- (instancetype)initWithValues:(NSMutableDictionary *)values {
    _values = values;
    return self;
}

- (PCFResponse *)getWithKey:(NSString *)key accessToken:(NSString *)accessToken {
    NSString *value = self.values[key] ? self.values[key] : @"";
    return [[PCFResponse alloc] initWithKey:key value:value];
}

- (PCFResponse *)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken {
    self.values[key] = value ? value : @"";
    [[NSUserDefaults standardUserDefaults] setObject:self.values forKey:PCFDataDefaultsKey];
    return [[PCFResponse alloc] initWithKey:key value:self.values[key]];
}

- (PCFResponse *)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken {
    [self.values removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:self.values forKey:PCFDataDefaultsKey];
    return [[PCFResponse alloc] initWithKey:key value:nil];
}

@end
