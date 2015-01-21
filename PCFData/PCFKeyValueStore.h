//
//  PCFLocalStore.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFDataStore.h"

@class PCFDataPersistence;

@interface PCFKeyValueStore : NSObject <PCFDataStore>

- (instancetype)initWithPersistence:(PCFDataPersistence *)persistence;

@end