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
@property (strong, readonly) NSString *domainName;

@end

@implementation PCFDataPersistence

- (instancetype)initWithDomainName:(NSString *)domainName {
    self = [super init];
    _domainName = domainName;
    _defaults = [NSUserDefaults standardUserDefaults];
    return self;
}

- (NSString *)getValueForKey:(NSString *)key {
    @synchronized(self) {
        return [self.values objectForKey:key];
    }
}

- (NSString *)putValue:(NSString *)value forKey:(NSString *)key {
    @synchronized(self) {
        NSMutableDictionary *values = self.values;
        [values setObject:value forKey:key];
        [self.defaults setPersistentDomain:values forName:self.domainName];
        return value;
    }
}

- (NSString *)deleteValueForKey:(NSString *)key {
    @synchronized(self) {
        NSMutableDictionary *values = self.values;
        [values removeObjectForKey:key];
        [self.defaults setPersistentDomain:values forName:self.domainName];
        return @"";
    }
}

- (void)clear {
    @synchronized(self) {
        [self.defaults removePersistentDomainForName:self.domainName];
    }
}

- (NSMutableDictionary *)values {
    NSMutableDictionary *dictionary = (NSMutableDictionary *) [self.defaults persistentDomainForName:self.domainName];
    return dictionary ? dictionary : [NSMutableDictionary new];
}

@end
