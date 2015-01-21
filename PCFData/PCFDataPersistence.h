//
//  PCFDataPersistence.h
//  PCFData
//
//  Created by DX122-XL on 2015-01-13.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCFDataPersistence : NSObject

- (NSString *)getValueForKey:(NSString *)key;

- (void)putValue:(NSString *)value forKey:(NSString *)key;

- (void)deleteValueForKey:(NSString *)key;

@end
