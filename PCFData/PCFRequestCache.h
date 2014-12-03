//
//  PCFRequestCache.h
//  PCFData
//
//  Created by DX122-XL on 2014-11-21.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCFPendingRequest;

@interface PCFRequestCache : NSObject

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults;

- (void)queueGetWithToken:(NSString *)accessToken collection:(NSString *)collection key:(NSString *)key;

- (void)queuePutWithToken:(NSString *)accessToken collection:(NSString *)collection key:(NSString *)key value:(NSString *)value fallback:(NSString *)fallback;

- (void)queueDeleteWithToken:(NSString *)accessToken collection:(NSString *)collection key:(NSString *)key fallback:(NSString *)fallback;

- (void)queuePending:(PCFPendingRequest *)request;

@end


@interface PCFPendingRequest : NSObject

@property NSDictionary *values;

- (instancetype)initWithDictionary:(NSDictionary *)values;

- (instancetype)initWithMethod:(int)method accessToken:(NSString *)accessToken collection:(NSString *)collection key:(NSString *)key value:(NSString *)value fallback:(NSString *)fallback;

@end