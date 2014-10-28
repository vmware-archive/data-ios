//
//  PCFDataStore.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCFResponse.h"

@protocol PCFDataStore <NSObject>

- (PCFResponse *)getWithKey:(NSString *)key accessToken:(NSString *)accessToken;

- (PCFResponse *)putWithKey:(NSString *)key value:(NSString *)value accessToken:(NSString *)accessToken;

- (PCFResponse *)deleteWithKey:(NSString *)key accessToken:(NSString *)accessToken;

@end
