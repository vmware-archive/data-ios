//
//  PCFKeyValue.h
//  PCFData
//
//  Created by DX122-XL on 2015-01-15.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFMappable.h"

@class PCFKeyValue;

@interface PCFKeyValue : NSObject <PCFMappable>

@property NSString *collection;
@property NSString *key;
@property NSString *value;

- (instancetype)initWithKeyValue:(PCFKeyValue *)keyValue;

- (instancetype)initWithCollection:(NSString *)collection key:(NSString *)key value:(NSString *)value;

@end
