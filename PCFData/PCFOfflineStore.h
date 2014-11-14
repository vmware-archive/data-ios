//
//  PCFOfflineStore.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-30.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFDataStore.h"

@class PCFRemoteStore, PCFLocalStore;

@interface PCFOfflineStore : NSObject <PCFDataStore>

- (instancetype)initWithCollection:(NSString *)collection;

- (instancetype)initWithCollection:(NSString *)collection remoteStore:(PCFRemoteStore *)remoteStore localStore:(PCFLocalStore *)localStore;

@end
