//
//  Mappable.h
//  PCFData
//
//  Created by DX122-XL on 2015-01-15.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PCFMappable <NSObject>

- (NSDictionary *)toDictionary;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end