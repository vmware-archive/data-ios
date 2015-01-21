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

@property NSString *accessToken;
@property id<PCFMappable> object;
@property id<PCFMappable> fallback;
@property BOOL force;

- (instancetype)initWithRequest:(PCFRequest *)request;

- (instancetype)initWithAccessToken:(NSString *)accessToken object:(id<PCFMappable>)object;

- (instancetype)initWithAccessToken:(NSString *)accessToken object:(id<PCFMappable>)object force:(BOOL)force;

@end
