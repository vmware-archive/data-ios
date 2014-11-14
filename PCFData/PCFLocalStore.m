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

@property NSString *collection;
@property (strong, readonly) NSUserDefaults *defaults;

@end

@implementation PCFLocalStore

- (instancetype)initWithCollection:(NSString *)collection {
    return [self initWithCollection:collection defaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithCollection:(NSString *)collection defaults:(NSUserDefaults *)defaults {
    _collection = collection;
    _defaults = defaults;
    [_defaults addObserver:self forKeyPath:PCFDataDefaultsKey options:NSKeyValueObservingOptionNew context:0];
    return self;
}

- (void)dealloc {
    [_defaults removeObserver:self forKeyPath:PCFDataDefaultsKey];
}

- (NSMutableDictionary *)values {
    return [NSMutableDictionary dictionaryWithDictionary:[_defaults objectForKey:PCFDataDefaultsKey]];
}

- (PCFResponse *)getWithKey:(NSString *)key accessToken:(NSString *)accessToken {
    NSMutableDictionary *values = self.values;
    NSString *value = values[key] ? values[key] : @"";
    return [[PCFResponse alloc] initWithKey:key value:value];
}

- (PCFResponse *)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken {
    NSMutableDictionary *values = self.values;
    values[key] = value ? value : @"";
    [_defaults setObject:values forKey:PCFDataDefaultsKey];
    return [[PCFResponse alloc] initWithKey:key value:self.values[key]];
}

- (PCFResponse *)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken {
    [self.values removeObjectForKey:key];
    [_defaults setObject:self.values forKey:PCFDataDefaultsKey];
    return [[PCFResponse alloc] initWithKey:key value:@""];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // any change from nsuserdefaults
}

@end
