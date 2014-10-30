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

- (NSString *)getWithAccessToken:(NSString *)accessToken;

- (NSString *)putWithAccessToken:(NSString *)acccessToken value:(NSString *)value;

- (NSString *)deleteWithAccessToken:(NSString *)accessToken;

@end
