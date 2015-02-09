//
//  PCFKeyValueObject.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFDataStore.h"

@interface PCFKeyValueObject : NSObject

+ (instancetype)objectWithCollection:(NSString *)collection key:(NSString *)key;

- (instancetype)initWithCollection:(NSString *)collection key:(NSString *)key;

- (instancetype)initWithDataStore:(id<PCFDataStore>)dataStore collection:(NSString *)collection key:(NSString *)key;

- (PCFResponse *)get;

- (void)getWithCompletionBlock:(PCFResponseBlock)completionBlock;

- (PCFResponse *)putWithValue:(NSString *)value;

- (void)putWithValue:(NSString *)value completionBlock:(PCFResponseBlock)completionBlock;

- (PCFResponse *)delete;

- (void)deleteWithCompletionBlock:(PCFResponseBlock)completionBlock;

@end
