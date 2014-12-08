//
//  PCFRemoteClient.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-29.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFRemoteClient.h"
#import "PCFEtagStore.h"

@interface PCFRemoteClient ()

@property PCFEtagStore *etagStore;

@end

@implementation PCFRemoteClient

static NSString* const PCFBearerPrefix = @"Bearer ";

- (instancetype)init {
    return [self initWithEtagStore:[[PCFEtagStore alloc] init]];
}

- (instancetype)initWithEtagStore:(PCFEtagStore *)etagStore {
    _etagStore = etagStore;
    return self;
}

- (NSString *)getWithAccessToken:(NSString *)accessToken url:(NSURL *)url error:(NSError *__autoreleasing *)error {
    NSHTTPURLResponse *response;
    NSURLRequest *request = [self requestWithMethod:@"GET" accessToken:accessToken url:url value:nil];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    return [self handleResponse:response error:error data:data];
}

- (NSString *)putWithAccessToken:(NSString *)accessToken url:(NSURL *)url value:(NSString *)value error:(NSError *__autoreleasing *)error {
    NSHTTPURLResponse *response;
    NSURLRequest *request = [self requestWithMethod:@"PUT" accessToken:accessToken url:url value:value];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    return [self handleResponse:response error:error data:data];
}

- (NSString *)deleteWithAccessToken:(NSString *)accessToken url:(NSURL *)url error:(NSError *__autoreleasing *)error {
    NSHTTPURLResponse *response;
    NSURLRequest *request = [self requestWithMethod:@"DELETE" accessToken:accessToken url:url value:nil];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    return [self handleResponse:response error:error data:data];
}

- (NSURLRequest *)requestWithMethod:(NSString*)method accessToken:(NSString *)accessToken url:(NSURL *)url value:(NSString *)value {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = method;

    if (accessToken) {
        NSString *token = [PCFBearerPrefix stringByAppendingString:accessToken];
        [request addValue:token forHTTPHeaderField:@"Authorization"];
    }
    
    NSString *etag = [self.etagStore getEtagForUrl:[url absoluteString]];
    
    if (etag) {
        [request addValue:etag forHTTPHeaderField:@"Etag"];
    }
    
    if (value) {
        request.HTTPBody = [value dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return request;
}

- (NSString *)handleResponse:(NSHTTPURLResponse *)response error:(NSError *__autoreleasing *)error data:(NSData *)data {
    if (error && *error) {
        return nil;
    } else if (response && (response.statusCode < 200 || response.statusCode >= 300)) {
        *error = [[NSError alloc] initWithDomain:response.description code:response.statusCode userInfo:response.allHeaderFields];
        return nil;
    } else {
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
}

@end
