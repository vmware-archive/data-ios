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

- (instancetype)initWithDataStore:(id<PCFDataStore>)dataStore key:(NSString *)key;

- (PCFResponse *)getWithAccessToken:(NSString *)accessToken;

- (void)getWithAccessToken:(NSString *)accessToken completionBlock:(void (^)(PCFResponse *))completionBlock;

- (PCFResponse *)putWithAccessToken:(NSString *)acccessToken value:(NSString *)value;

- (void)putWithAccessToken:(NSString *)accessToken value:(NSString *)value completionBlock:(void (^)(PCFResponse *))completionBlock;

- (PCFResponse *)deleteWithAccessToken:(NSString *)accessToken;

- (void)deleteWithAccessToken:(NSString *)accessToken completionBlock:(void (^)(PCFResponse *))completionBlock;

@end
