//
//  PCFRemoteClient.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-29.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFRemoteClient.h"

@implementation PCFRemoteClient

- (NSString *)getWithAccessToken:(NSString *)accessToken url:(NSURL *)url error:(NSError *__autoreleasing *)error {
    NSHTTPURLResponse *response;
    NSURLRequest *request = [self requestWithAccessToken:accessToken url:url];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
  
    if (error && *error) {
        return nil;
    } else if (response && (response.statusCode < 200 || response.statusCode >= 300)) {
        *error = [[NSError alloc] initWithDomain:response.description code:response.statusCode userInfo:response.allHeaderFields];
        return nil;
    } else {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
}

- (NSString *)putWithAccessToken:(NSString *)accessToken url:(NSURL *)url value:(NSString *)value error:(NSError *__autoreleasing *)error {
    return nil;
}

- (NSString *)deleteWithAccessToken:(NSString *)accessToken url:(NSURL *)url error:(NSError *__autoreleasing *)error {
    return nil;
}

- (NSURLRequest *)requestWithAccessToken:(NSString *)accessToken url:(NSURL *)url {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    if (accessToken) {
        NSString *token = [@"Bearer " stringByAppendingString:accessToken];
        [request.allHTTPHeaderFields setValue:@"Authorization" forKey:token];
    }
    return request;
}

@end
