//
//  PCFTestMappable.h
//  PCFData
//
//  Created by DX122-XL on 2015-01-20.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFMappable.h"

@interface PCFTestMappable : NSObject <PCFMappable>

@property NSString *value;

- (instancetype)initWithValue:(NSString *)value;

@end
