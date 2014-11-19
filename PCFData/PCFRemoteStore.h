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

- (NSURL *)urlForKey:(NSString *)key;

@end
