//
//  PCFRequest.h
//  PCFData
//
//  Created by DX122-XL on 2015-01-12.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFMappable.h"

@interface PCFRequest : NSObject <PCFMappable>

@property id<PCFMappable> object;
@property id<PCFMappable> fallback;
@property BOOL force;

- (instancetype)initWithRequest:(PCFRequest *)request;

- (instancetype)initWithObject:(id<PCFMappable>)object;

- (instancetype)initWithObject:(id<PCFMappable>)object fallback:(id<PCFMappable>)fallback force:(BOOL)force;

- (NSString *)accessToken;

@end
