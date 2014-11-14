//
//  PCFRemoteStore.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-29.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFDataStore.h"
#import "PCFRemoteClient.h"

@interface PCFRemoteStore : NSObject <PCFDataStore>

- (instancetype)initWithCollection:(NSString *)collection;

- (instancetype)initWithCollection:(NSString *)collection client:(PCFRemoteClient *)client;

- (void)getWithKey:(NSString *)key accessToken:(NSString *)accessToken completionBlock:(void (^)(PCFResponse *))completionBlock;

- (void)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken completionBlock:(void (^)(PCFResponse *))completionBlock;

- (void)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken completionBlock:(void (^)(PCFResponse *))completionBlock;

@end
