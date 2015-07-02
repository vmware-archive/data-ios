//
//  PCFSessionHandler.h
//  PCFData
//
//  Created by DX122-XL on 2015-06-29.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCFSessionHandler : NSObject <NSURLSessionTaskDelegate>

- (instancetype)initWithUrlSession:(NSURLSession *)urlSession;

- (NSData *)performRequest:(NSURLRequest *)request response:(NSURLResponse **)response error:(NSError **)error;

@end
