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

- (NSString *)getWithUrl:(NSURL *)url force:(BOOL)force error:(NSError *__autoreleasing *)error;

- (NSString *)putWithUrl:(NSURL *)url body:(NSString *)body force:(BOOL)force error:(NSError *__autoreleasing *)error;

- (NSString *)deleteWithUrl:(NSURL *)url force:(BOOL)force error:(NSError *__autoreleasing *)error;

@end
