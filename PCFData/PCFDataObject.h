//
//  PCFDataObject.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFDataStore.h"

@interface PCFDataObject : NSObject

- (instancetype)initWithCollection:(NSString *)collection key:(NSString *)key;

- (instancetype)initWithDataStore:(id<PCFDataStore>)dataStore key:(NSString *)key;

- (PCFResponse *)getWithAccessToken:(NSString *)accessToken;

- (PCFResponse *)getWithAccessToken:(NSString *)accessToken force:(BOOL)force;

- (void)getWithAccessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock;

- (void)getWithAccessToken:(NSString *)accessToken force:(BOOL)force completionBlock:(PCFResponseBlock)completionBlock;

- (PCFResponse *)putWithAccessToken:(NSString *)accessToken value:(NSString *)value;

- (PCFResponse *)putWithAccessToken:(NSString *)accessToken value:(NSString *)value force:(BOOL)force;

- (void)putWithAccessToken:(NSString *)accessToken value:(NSString *)value completionBlock:(PCFResponseBlock)completionBlock;

- (void)putWithAccessToken:(NSString *)accessToken value:(NSString *)value force:(BOOL)force completionBlock:(PCFResponseBlock)completionBlock;

- (PCFResponse *)deleteWithAccessToken:(NSString *)accessToken;

- (PCFResponse *)deleteWithAccessToken:(NSString *)accessToken force:(BOOL)force;

- (void)deleteWithAccessToken:(NSString *)accessToken completionBlock:(PCFResponseBlock)completionBlock;

- (void)deleteWithAccessToken:(NSString *)accessToken  force:(BOOL)force completionBlock:(PCFResponseBlock)completionBlock;

@end
