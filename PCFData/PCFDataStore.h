//
//  PCFDataStore.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCFResponse;

typedef void(^PCFResponseBlock)(PCFResponse *response);

@protocol PCFDataStore <NSObject>

- (PCFResponse *)getWithKey:(NSString *)key accessToken:(NSString *)accessToken;

- (PCFResponse *)getWithKey:(NSString *)key accessToken:(NSString *)accessToken force:(BOOL)force;

- (void)getWithKey:(NSString *)key accessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock;

- (void)getWithKey:(NSString *)key accessToken:(NSString *)accessToken force:(BOOL)force completionBlock:(PCFResponseBlock)completionBlock;

- (PCFResponse *)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken;

- (PCFResponse *)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken force:(BOOL)force;

- (void)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock;

- (void)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken force:(BOOL)force completionBlock:(PCFResponseBlock)completionBlock;

- (PCFResponse *)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken;

- (PCFResponse *)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken force:(BOOL)force;

- (void)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock;

- (void)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken force:(BOOL)force completionBlock:(PCFResponseBlock)completionBlock;

@end


