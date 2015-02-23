//
//  PCFDataPersistence.m
//  PCFData
//
//  Created by DX122-XL on 2015-01-13.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "PCFDataPersistence.h"

@interface PCFDataPersistence ()

@property (strong, readonly) NSUserDefaults *defaults;

@end

@implementation PCFDataPersistence

- (instancetype)init {
    _defaults = [NSUserDefaults standardUserDefaults];
    return self;
}

- (NSString *)getValueForKey:(NSString *)key {
    return [self.defaults objectForKey:key];
}

- (NSString *)putValue:(NSString *)value forKey:(NSString *)key {
    [self.defaults setObject:value forKey:key];
    return value;
}

- (NSString *)deleteValueForKey:(NSString *)key {
    [self.defaults removeObjectForKey:key];
    return @"";
}

@end
