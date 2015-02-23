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
#import "PCFDataRequest.h"
#import "PCFPendingRequest.h"
#import "PCFDataResponse.h"
#import "PCFData.h"

@interface PCFData ()

+ (NSString *)provideToken;

+ (void)invalidateToken;

@end

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

- (NSString *)getWithUrl:(NSURL *)url force:(BOOL)force error:(NSError *__autoreleasing *)error {
    NSMutableURLRequest *urlRequest = [self requestWithMethod:@"GET" url:url body:nil];
    
    return [self executeRequest:urlRequest force:force error:error];
}

- (NSString *)putWithUrl:(NSURL *)url body:(NSString *)body force:(BOOL)force error:(NSError *__autoreleasing *)error {
    NSMutableURLRequest *urlRequest = [self requestWithMethod:@"PUT" url:url body:body];
    
    return [self executeRequest:urlRequest force:force error:error];
}

- (NSString *)deleteWithUrl:(NSURL *)url  force:(BOOL)force error:(NSError *__autoreleasing *)error {
    NSMutableURLRequest *urlRequest = [self requestWithMethod:@"DELETE" url:url body:nil];
    
    return [self executeRequest:urlRequest force:force error:error];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString*)method url:(NSURL *)url body:(NSString *)body {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    request.HTTPMethod = method;
    
    if (body) {
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return request;
}

- (NSString *)executeRequest:(NSMutableURLRequest *)request force:(BOOL)force error:(NSError *__autoreleasing *)error {
    NSHTTPURLResponse *response;
    NSData *data = [self executeRequest:request force:force error:error response:&response];
 
    LogInfo(@"Response: [%ld] %@", response.statusCode, *error);
    
    if (error && (*error).code == kCFURLErrorUserCancelledAuthentication) {
        LogInfo(@"Response error: invalidating token");
        [PCFData invalidateToken];
    
        LogInfo(@"Response error: retrying");
        
        data = [self executeRequest:request force:force error:error response:&response];
        
        LogInfo(@"Response: [%ld] %@", response.statusCode, *error);
    }
    
    return [self handleResponse:response data:data error:error];
}

- (NSData *)executeRequest:(NSMutableURLRequest *)request force:(BOOL)force error:(NSError *__autoreleasing *)error response:(NSHTTPURLResponse *__autoreleasing *)response {
    
    LogInfo(@"Request: [%@] %@", request.HTTPMethod, request.URL);
    
    [self addUserAgentHeader:request];
    
    [self addAuthorizationHeader:request];
    
    if (!force) {
        [self addEtagHeader:request url:request.URL];
    }
    
    return [NSURLConnection sendSynchronousRequest:request returningResponse:response error:error];
}

- (void)addUserAgentHeader:(NSMutableURLRequest *)request {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"io.pivotal.ios.PCFData"];
    NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *build = [[NSProcessInfo processInfo] operatingSystemVersionString];
    NSString *userAgent = [NSString stringWithFormat:@"PCFData/%@; iOS %@", version, build];
    
    [request addValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    LogInfo(@"Request User-Agent: %@", userAgent);
}

- (void)addAuthorizationHeader:(NSMutableURLRequest *)request {
    
    NSString *accessToken = [PCFData provideToken];
    
    if (accessToken) {
        NSString *token = [PCFBearerPrefix stringByAppendingString:accessToken];
        [request addValue:token forHTTPHeaderField:@"Authorization"];
        
        LogInfo(@"Request Authorization: %@", token);
        
    } else {
        @throw [NSException exceptionWithName:@"TokenException" reason:@"Could not retrieve access token" userInfo:nil];
    }
}

- (void)addEtagHeader:(NSMutableURLRequest *)request url:(NSURL *)url {
    if ([PCFDataConfig areEtagsEnabled]) {
        NSString *etag = [self.etagStore etagForUrl:url];
        
        if (etag) {
            NSString *header = [request.HTTPMethod isEqual:@"GET"] ? @"If-None-Match" : @"If-Match";
            [request addValue:etag forHTTPHeaderField:header];
            
            LogInfo(@"Request %@: %@", header, etag);
        }
        
        LogInfo(@"Request Etag: None");
    }
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
        
        if (response.statusCode == 404 && [PCFDataConfig areEtagsEnabled]) {
            [self.etagStore putEtagForUrl:response.URL etag:@""];
            
            LogInfo(@"Response 404 NotFound clearing Etag.");
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
