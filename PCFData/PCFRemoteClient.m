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
    NSURLRequest *request = [self requestWithMethod:@"GET" accessToken:accessToken url:url value:nil];
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
    NSHTTPURLResponse *response;
    NSURLRequest *request = [self requestWithMethod:@"PUT" accessToken:accessToken url:url value:value];
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

- (NSString *)deleteWithAccessToken:(NSString *)accessToken url:(NSURL *)url error:(NSError *__autoreleasing *)error {
    NSHTTPURLResponse *response;
    NSURLRequest *request = [self requestWithMethod:@"DELETE" accessToken:accessToken url:url value:nil];
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

- (NSURLRequest *)requestWithMethod:(NSString*)method accessToken:(NSString *)accessToken url:(NSURL *)url value:(NSString *)value {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = method;

    if (accessToken) {
        NSString *token = [@"Bearer " stringByAppendingString:accessToken];
        [request addValue:token forHTTPHeaderField:@"Authorization"];
    }

    if (value) {
        request.HTTPBody = [value dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return request;
}

@end
