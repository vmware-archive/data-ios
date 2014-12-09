//
//  PCFRemoteClient.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-29.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PCFEtagStore;

@interface PCFRemoteClient : NSObject

- (instancetype)initWithEtagStore:(PCFEtagStore *)etagStore;

- (NSString *)getWithAccessToken:(NSString *)accessToken url:(NSURL *)url error:(NSError *__autoreleasing *)error;

- (NSString *)putWithAccessToken:(NSString *)accessToken url:(NSURL *)url value:(NSString *)value error:(NSError *__autoreleasing *)error;

- (NSString *)deleteWithAccessToken:(NSString *)accessToken url:(NSURL *)url error:(NSError *__autoreleasing *)error;

- (NSURLRequest *)requestWithMethod:(NSString*)method accessToken:(NSString *)accessToken url:(NSURL *)url value:(NSString *)value;

- (NSString *)handleResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error;

@end
