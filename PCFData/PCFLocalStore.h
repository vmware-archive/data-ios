//
//  PCFLocalStore.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFDataStore.h"

@interface PCFLocalStore : NSObject <PCFDataStore>

- (instancetype)initWithValues:(NSMutableDictionary *)values;

@end