//
//  PCFRemoteClient.m
//  PCFData
//
//  Created by DX122-XL on 2014-10-29.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFRemoteClient.h"
#import "PCFEtagStore.h"
#import "PCFDataLogger.h"
#import "PCFDataConfig.h"
#import "PCFKeyValue.h"
#import "PCFRequest.h"
#import "PCFResponse.h"

@interface PCFRemoteClient ()

@property PCFEtagStore *etagStore;

- (instancetype)initWithEtagStore:(PCFEtagStore *)etagStore;

@end

@implementation PCFRemoteClient

static NSString* const PCFBearerPrefix = @"Bearer ";

- (instancetype)init {
    return [self initWithEtagStore:[[PCFEtagStore alloc] init]];
}

- (instancetype)initWithEtagStore:(PCFEtagStore *)etagStore {
    self = [super init];
    _etagStore = etagStore;
    return self;
}

- (PCFResponse *)getWithRequest:(PCFRequest *)request {
    if ([request.object isKindOfClass:PCFKeyValue.class]) {

        NSError *error;
        PCFKeyValue *object = request.object;
        NSURLRequest *urlRequest = [self requestWithMethod:@"GET" accessToken:request.accessToken url:object.url value:nil force:request.force];

        PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithKeyValue:object];
        keyValue.value = [self execute:urlRequest error:&error];
        
        PCFResponse *response = [[PCFResponse alloc] initWithObject:keyValue];
        response.error = error;
        return response;
    } else {
        return nil;
    }
}

- (PCFResponse *)putWithRequest:(PCFRequest *)request {
    if ([request.object isKindOfClass:PCFKeyValue.class]) {
        
        NSError *error;
        PCFKeyValue *object = request.object;
        NSURLRequest *urlRequest = [self requestWithMethod:@"PUT" accessToken:request.accessToken url:object.url value:object.value force:request.force];

        NSString *result = [self execute:urlRequest error:&error];
        
        PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithKeyValue:object];
        keyValue.value = result.length > 0 ? result : object.value;
        
        PCFResponse *response = [[PCFResponse alloc] initWithObject:keyValue];
        response.error = error;
        return response;
    } else {
        return nil;
    }
}

- (PCFResponse *)deleteWithRequest:(PCFRequest *)request {
    if ([request.object isKindOfClass:PCFKeyValue.class]) {
        
        NSError *error;
        PCFKeyValue *object = request.object;
        NSURLRequest *urlRequest = [self requestWithMethod:@"DELETE" accessToken:request.accessToken url:object.url value:nil force:request.force];
        
        PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithKeyValue:object];
        keyValue.value = [self execute:urlRequest error:&error];
        
        PCFResponse *response = [[PCFResponse alloc] initWithObject:keyValue];
        response.error = error;
        return response;
    } else {
        return nil;
    }
}

- (NSURLRequest *)requestWithMethod:(NSString*)method accessToken:(NSString *)accessToken url:(NSURL *)url value:(NSString *)value force:(BOOL)force {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    request.HTTPMethod = method;

    if (accessToken) {
        NSString *token = [PCFBearerPrefix stringByAppendingString:accessToken];
        [request addValue:token forHTTPHeaderField:@"Authorization"];
    }

    LogInfo(@"Request: [%@] %@", method, request.URL);
    
    if (!force && [PCFDataConfig areEtagsEnabled]) {
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

- (NSString *)execute:(NSURLRequest *)request error:(NSError *__autoreleasing *)error {
    NSHTTPURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    
    return [self handleResponse:response data:data error:error];
}

- (NSString *)handleResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
    if (error && *error) {
        LogInfo(@"Response Error");
        return nil;
        
    } else if (response && (response.statusCode < 200 || response.statusCode >= 300)) {
        LogInfo(@"Response Error: HTTP Status Code %ld", (long) response.statusCode);
        
        if (error) {
            *error = [[NSError alloc] initWithDomain:response.description code:response.statusCode userInfo:response.allHeaderFields];
        }
        
        if (response.statusCode == 404) {
            if ([PCFDataConfig areEtagsEnabled]) {
                [self.etagStore putEtagForUrl:response.URL etag:@""];
                
                LogInfo(@"Response 404 NotFound clearing ETag.");
            }
        }
        
        return nil;
    } else {
        
        if ([PCFDataConfig areEtagsEnabled]) {
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
