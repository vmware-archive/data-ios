//
//  PCFDataPersistence.h
//  PCFData
//
//  Created by DX122-XL on 2015-01-13.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCFDataPersistence : NSObject

- (instancetype)initWithDomainName:(NSString *)domainName;
    
- (NSString *)getValueForKey:(NSString *)key;

- (NSString *)putValue:(NSString *)value forKey:(NSString *)key;

- (NSString *)deleteValueForKey:(NSString *)key;

- (void)clear;

@end
