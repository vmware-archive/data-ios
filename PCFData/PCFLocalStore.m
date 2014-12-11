//
//  PCFLocalStore.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFLocalStore.h"
#import "PCFResponse.h"
#import "PCFLogger.h"

@interface PCFLocalStore ()

@property NSString *collection;
@property (readonly) NSUserDefaults *defaults;

@end

@implementation PCFLocalStore

static NSString* const PCFDataPrefix = @"PCFData:Data:";

- (instancetype)initWithCollection:(NSString *)collection {
    return [self initWithCollection:collection defaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithCollection:(NSString *)collection defaults:(NSUserDefaults *)defaults {
    _collection = collection;
    _defaults = defaults;
//    [_defaults addObserver:self forKeyPath:PCFDataDefaultsKey options:NSKeyValueObservingOptionNew context:0];
    return self;
}

- (void)dealloc {
//    [_defaults removeObserver:self forKeyPath:PCFDataDefaultsKey];
}

- (PCFResponse *)getWithKey:(NSString *)key accessToken:(NSString *)accessToken {
    LogInfo(@"PCFLocalStore getWithKey: %@", key);
    NSString *value = [self.defaults objectForKey:[PCFDataPrefix stringByAppendingString:key]];
    return [[PCFResponse alloc] initWithKey:key value:value];
}

- (void)getWithKey:(NSString *)key accessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self getWithKey:key accessToken:accessToken];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFResponse *)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken {
    LogInfo(@"PCFLocalStore putWithKey: %@ value: %@", key, value);
    [self.defaults setObject:value forKey:[PCFDataPrefix stringByAppendingString:key]];
    return [[PCFResponse alloc] initWithKey:key value:value];
}

- (void)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self putWithKey:key value:value accessToken:accessToken];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

- (PCFResponse *)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken {
    LogInfo(@"PCFLocalStore deleteWithKey: %@", key);
    [self.defaults removeObjectForKey:[PCFDataPrefix stringByAppendingString:key]];
    return [[PCFResponse alloc] initWithKey:key value:nil];
}

- (void)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PCFResponse *response = [self deleteWithKey:key accessToken:accessToken];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(response);
        });
    });
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    // any change from nsuserdefaults
//}

@end
