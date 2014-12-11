//
//  PCFRemoteClient.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-29.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFRemoteClient.h"
#import "PCFEtagStore.h"
#import "PCFLogger.h"
#import "PCFConfig.h"

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
    
    return [self handleResponse:response data:data error:error];
}

- (NSString *)putWithAccessToken:(NSString *)accessToken url:(NSURL *)url value:(NSString *)value error:(NSError *__autoreleasing *)error {
    NSHTTPURLResponse *response;
    NSURLRequest *request = [self requestWithMethod:@"PUT" accessToken:accessToken url:url value:value];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    
    return [self handleResponse:response data:data error:error];
}

- (NSString *)deleteWithAccessToken:(NSString *)accessToken url:(NSURL *)url error:(NSError *__autoreleasing *)error {
    NSHTTPURLResponse *response;
    NSURLRequest *request = [self requestWithMethod:@"DELETE" accessToken:accessToken url:url value:nil];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    
    return [self handleResponse:response data:data error:error];
}

- (NSURLRequest *)requestWithMethod:(NSString*)method accessToken:(NSString *)accessToken url:(NSURL *)url value:(NSString *)value {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    request.HTTPMethod = method;

    if (accessToken) {
        NSString *token = [PCFBearerPrefix stringByAppendingString:accessToken];
        [request addValue:token forHTTPHeaderField:@"Authorization"];
    }

    LogInfo(@"Request: [%@] %@", method, request.URL);
    
    if ([PCFConfig collisionStrategy] == PCFCollisionStrategyOptimisticLocking) {
        NSString *etag = [self.etagStore etagForUrl:url];
        
        if (etag) {
            NSString *header = [method isEqual:@"GET"] ? @"If-None-Match" : @"If-Match";
            [request addValue:etag forHTTPHeaderField:header];
        }
        
        LogInfo(@"Request Etag: %@", etag ? etag : @"None");
    }
    
    if (value) {
        request.HTTPBody = [value dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    
    return request;
}

- (NSString *)handleResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    if (error && *error) {
        LogInfo(@"Response Error");
        return nil;
        
    } else if (response && (response.statusCode < 200 || response.statusCode >= 300)) {
        LogInfo(@"Response Error: HTTP Status Code %ld", (long) response.statusCode);
        *error = [[NSError alloc] initWithDomain:response.description code:response.statusCode userInfo:response.allHeaderFields];
        return nil;
        
    } else {
        if ([PCFConfig collisionStrategy] == PCFCollisionStrategyOptimisticLocking) {
            NSString *etag = [response.allHeaderFields valueForKey:@"Etag"];

            [self.etagStore putEtagForUrl:response.URL etag:etag];
            
            LogInfo(@"Response Etag: %@", etag ? etag : @"None");
        }
        
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        LogInfo(@"Response Body: %@", result);
        
        return result;
    }
}

@end
