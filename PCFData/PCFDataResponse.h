//
//  PCFDataResponse.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCFDataResponse : NSObject

@property NSError *error;
@property id object;

- (instancetype)initWithObject:(id)object;

- (instancetype)initWithObject:(id)object error:(NSError *)error;

@end
