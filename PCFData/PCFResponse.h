//
//  PCFResponse.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCFResponse : NSObject

@property NSError *error;
@property NSString *value;
@property NSString *key;

- (instancetype)initWithKey:(NSString *)key value:(NSString *)value;

- (instancetype)initWithKey:(NSString *)key error:(NSError *)error;

@end

@interface PCFFailureResponse : PCFResponse

+ (PCFFailureResponse *)failureResponse:(PCFResponse *)response;

@end