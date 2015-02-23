//
//  PCFRemoteClientTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-11-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>
#import "PCFRemoteClient.h"
#import "PCFEtagStore.h"
#import "PCFDataConfig.h"

@interface PCFRemoteClient ()

- (NSMutableURLRequest *)requestWithMethod:(NSString*)method url:(NSURL *)url body:(NSString *)body;

- (NSString *)executeRequest:(NSMutableURLRequest *)request force:(BOOL)force error:(NSError *__autoreleasing *)error;

- (NSData *)executeRequest:(NSMutableURLRequest *)request force:(BOOL)force error:(NSError *__autoreleasing *)error response:(NSHTTPURLResponse *__autoreleasing *)response;

- (NSString *)handleResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error;

- (void)addUserAgentHeader:(NSMutableURLRequest *)request;

- (void)addAuthorizationHeader:(NSMutableURLRequest *)request;

- (void)addEtagHeader:(NSMutableURLRequest *)request url:(NSURL *)url;

@end

@interface PCFData ()

+ (NSString *)provideToken;

+ (void)invalidateToken;

@end

@interface PCFRemoteClientTests : XCTestCase

@property NSString *token;
@property NSString *result;
@property NSString *body;
@property NSError *error;
@property NSURL *url;
@property int httpErrorCode;
@property NSString *etag;
@property BOOL force;

@end

@implementation PCFRemoteClientTests

- (void)setUp {
    [super setUp];
    
    self.token = [NSUUID UUID].UUIDString;
    self.result = [NSUUID UUID].UUIDString;
    self.body = [NSUUID UUID].UUIDString;
    
    self.error = [[NSError alloc] init];
    self.url = [NSURL URLWithString:@"http://test.com"];
    
    self.httpErrorCode = 300 + (arc4random() % 200);
    self.etag = [NSUUID UUID].UUIDString;
    self.force = arc4random_uniform(2);
}

- (void)testGetWithUrl {
    NSMutableURLRequest *request = OCMClassMock([NSMutableURLRequest class]);
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] initWithEtagStore:nil]);
    
    OCMStub([client requestWithMethod:[OCMArg any] url:[OCMArg any] body:[OCMArg any]]).andReturn(request);
    OCMStub([client executeRequest:request force:self.force error:[OCMArg anyObjectRef]]).andDo(nil);
    
    NSError *error;
    [client getWithUrl:self.url force:self.force error:&error];
    
    OCMVerify([client requestWithMethod:@"GET" url:self.url body:nil]);
    OCMVerify([client executeRequest:request force:self.force error:[OCMArg anyObjectRef]]);
}

- (void)testPutWithUrl {
    NSMutableURLRequest *request = OCMClassMock([NSMutableURLRequest class]);
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] initWithEtagStore:nil]);
    
    OCMStub([client requestWithMethod:[OCMArg any] url:[OCMArg any] body:[OCMArg any]]).andReturn(request);
    OCMStub([client executeRequest:request force:self.force error:[OCMArg anyObjectRef]]).andDo(nil);
    
    NSError *error;
    [client putWithUrl:self.url body:self.body force:self.force error:&error];
    
    OCMVerify([client requestWithMethod:@"PUT" url:self.url body:self.body]);
    OCMVerify([client executeRequest:request force:self.force error:[OCMArg anyObjectRef]]);
}

- (void)testDeleteWithUrl {
    NSMutableURLRequest *request = OCMClassMock([NSMutableURLRequest class]);
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] initWithEtagStore:nil]);
    
    OCMStub([client requestWithMethod:[OCMArg any] url:[OCMArg any] body:[OCMArg any]]).andReturn(request);
    OCMStub([client executeRequest:request force:self.force error:[OCMArg anyObjectRef]]).andDo(nil);
    
    NSError *error;
    [client deleteWithUrl:self.url force:self.force error:&error];
    
    OCMVerify([client requestWithMethod:@"DELETE" url:self.url body:nil]);
    OCMVerify([client executeRequest:request force:self.force error:[OCMArg anyObjectRef]]);
}

- (void)testRequestWithMethod {
    NSData *body = [self.body dataUsingEncoding:NSUTF8StringEncoding];
    id mutableRequest = OCMClassMock([NSMutableURLRequest class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] initWithEtagStore:nil];
    
    OCMStub([mutableRequest alloc]).andReturn(mutableRequest);
    OCMStub([mutableRequest initWithURL:[OCMArg any] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10]).andReturn(mutableRequest);
    
    NSString *method = [NSUUID UUID].UUIDString;
    XCTAssertEqual(mutableRequest, [client requestWithMethod:method url:self.url body:self.body]);
    
    OCMVerify([mutableRequest setHTTPMethod:method]);
    OCMVerify([mutableRequest setHTTPBody:body]);
    OCMVerify([mutableRequest initWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10]);
    
    [mutableRequest stopMocking];
}

- (void)testExecuteRequest {
    NSData *body = [self.body dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = OCMClassMock([NSMutableURLRequest class]);
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] initWithEtagStore:nil]);
    id pcfData = OCMClassMock([PCFData class]);
    
    OCMStub([client executeRequest:[OCMArg any] force:self.force error:[OCMArg anyObjectRef] response:[OCMArg anyObjectRef]]).andReturn(body);
    OCMStub([client handleResponse:[OCMArg any] data:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(self.body);
    OCMStub([pcfData invalidateToken]).andDo(^(NSInvocation *invocation){
        XCTFail(@"This method should not be hit");
    });
    
    NSError *error;
    XCTAssertEqual(self.body, [client executeRequest:request force:self.force error:&error]);
    
    OCMVerify([client handleResponse:[OCMArg any] data:body error:[OCMArg anyObjectRef]]);
    OCMVerify([client executeRequest:request force:self.force error:[OCMArg anyObjectRef] response:[OCMArg anyObjectRef]]);
    
    [pcfData stopMocking];
}

- (void)testExecuteRequestWithUserCancelledError {
    NSData *body = [self.body dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = OCMClassMock([NSMutableURLRequest class]);
    id client = OCMPartialMock([[PCFRemoteClient alloc] initWithEtagStore:nil]);
    id pcfData = OCMClassMock([PCFData class]);
    
    OCMStub([client executeRequest:[OCMArg any] force:self.force error:[OCMArg anyObjectRef] response:[OCMArg anyObjectRef]]).andReturn(body);
    OCMStub([client handleResponse:[OCMArg any] data:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(self.body);
    
    NSError *error = [[NSError alloc] initWithDomain:@"" code:kCFURLErrorUserCancelledAuthentication userInfo:nil];
    XCTAssertEqual(self.body, [client executeRequest:request force:self.force error:&error]);
    
    OCMVerify([client handleResponse:[OCMArg any] data:body error:[OCMArg anyObjectRef]]);
    OCMVerify([client executeRequest:request force:self.force error:[OCMArg anyObjectRef] response:[OCMArg anyObjectRef]]);
    OCMVerify([pcfData invalidateToken]);
    
    [pcfData stopMocking];
}

- (void)testExecuteRequestWithResponseWithForce {
    NSData *body = [self.body dataUsingEncoding:NSUTF8StringEncoding];
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] initWithEtagStore:nil]);
    NSMutableURLRequest *request = OCMClassMock([NSMutableURLRequest class]);
    id nsURLConnection = OCMClassMock([NSURLConnection class]);
    
    OCMStub([client addUserAgentHeader:[OCMArg any]]).andDo(nil);
    OCMStub([client addAuthorizationHeader:[OCMArg any]]).andDo(nil);
    OCMStub([client addEtagHeader:[OCMArg any] url:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        XCTFail(@"This method should not be called.");
    });
    OCMStub([nsURLConnection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andReturn(body);
    
    NSError *error;
    NSHTTPURLResponse *response;
    XCTAssertEqual(body, [client executeRequest:request force:true error:&error response:&response]);
    
    OCMVerify([client addUserAgentHeader:request]);
    OCMVerify([client addAuthorizationHeader:request]);

    [nsURLConnection stopMocking];
}

- (void)testExecuteRequestWithResponseWithoutForce {
    NSData *body = [self.body dataUsingEncoding:NSUTF8StringEncoding];
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] initWithEtagStore:nil]);
    NSMutableURLRequest *request = OCMClassMock([NSMutableURLRequest class]);
    id nsURLConnection = OCMClassMock([NSURLConnection class]);
    
    OCMStub([client addUserAgentHeader:[OCMArg any]]).andDo(nil);
    OCMStub([client addAuthorizationHeader:[OCMArg any]]).andDo(nil);
    OCMStub([nsURLConnection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andReturn(body);
    
    NSError *error;
    NSHTTPURLResponse *response;
    XCTAssertEqual(body, [client executeRequest:request force:false error:&error response:&response]);
    
    OCMVerify([client addUserAgentHeader:request]);
    OCMVerify([client addAuthorizationHeader:request]);
    OCMVerify([client addEtagHeader:request url:request.URL]);
    
    [nsURLConnection stopMocking];
}

- (void)testAddUserAgentHeader {
    NSMutableURLRequest *request = OCMClassMock([NSMutableURLRequest class]);
    id nsBundle = OCMClassMock([NSBundle class]);
    NSString *version = [NSUUID UUID].UUIDString;
    NSString *build = [NSUUID UUID].UUIDString;
    id nsProcessInfo = OCMClassMock([NSProcessInfo class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] initWithEtagStore:nil];
    
    OCMStub([nsBundle bundleWithIdentifier:[OCMArg any]]).andReturn(nsBundle);
    OCMStub([nsBundle objectForInfoDictionaryKey:[OCMArg any]]).andReturn(version);
    OCMStub([nsProcessInfo processInfo]).andReturn(nsProcessInfo);
    OCMStub([nsProcessInfo operatingSystemVersionString]).andReturn(build);
    
    [client addUserAgentHeader:request];
    
    NSString *userAgent = [NSString stringWithFormat:@"PCFData/%@; iOS %@", version, build];
    OCMVerify([request addValue:userAgent forHTTPHeaderField:@"User-Agent"]);
    
    [nsBundle stopMocking];
    [nsProcessInfo stopMocking];
}

- (void)testAddAuthorizationHeader {
    id pcfData = OCMClassMock([PCFData class]);
    NSMutableURLRequest *request = OCMClassMock([NSMutableURLRequest class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] initWithEtagStore:nil];
    
    OCMStub([pcfData provideToken]).andReturn(self.token);
    
    [client addAuthorizationHeader:request];
    
    NSString *bearerToken = [@"Bearer " stringByAppendingString:self.token];
    OCMVerify([request addValue:bearerToken forHTTPHeaderField:@"Authorization"]);
    
    [pcfData stopMocking];
}

- (void)testAddEtagHeaderWhenEtagsEnabled {
    id pcfDataConfig = OCMClassMock([PCFDataConfig class]);
    NSMutableURLRequest *request = OCMClassMock([NSMutableURLRequest class]);
    PCFEtagStore *etagStore = OCMClassMock([PCFEtagStore class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] initWithEtagStore:etagStore];
    
    OCMStub([pcfDataConfig areEtagsEnabled]).andReturn(true);
    OCMStub([etagStore etagForUrl:[OCMArg any]]).andReturn(self.etag);
    
    [client addEtagHeader:request url:self.url];
    
    OCMVerify([pcfDataConfig areEtagsEnabled]);
    OCMVerify([etagStore etagForUrl:self.url]);
    OCMVerify([request addValue:self.etag forHTTPHeaderField:@"If-Match"]);
    
    [pcfDataConfig stopMocking];
}

- (void)testAddEtagHeaderWhenEtagsEnabledForGetRequest {
    id pcfDataConfig = OCMClassMock([PCFDataConfig class]);
    NSMutableURLRequest *request = OCMClassMock([NSMutableURLRequest class]);
    PCFEtagStore *etagStore = OCMClassMock([PCFEtagStore class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] initWithEtagStore:etagStore];
    
    OCMStub([request HTTPMethod]).andReturn(@"GET");
    OCMStub([pcfDataConfig areEtagsEnabled]).andReturn(true);
    OCMStub([etagStore etagForUrl:[OCMArg any]]).andReturn(self.etag);
    
    [client addEtagHeader:request url:self.url];
    
    OCMVerify([pcfDataConfig areEtagsEnabled]);
    OCMVerify([etagStore etagForUrl:self.url]);
    OCMVerify([request addValue:self.etag forHTTPHeaderField:@"If-None-Match"]);
    
    [pcfDataConfig stopMocking];
}

- (void)testHandleResponseFailureWithError {
    NSError *error = [[NSError alloc] init];
    PCFRemoteClient *client = [[PCFRemoteClient alloc] init];
    
    NSString *result = [client handleResponse:nil data:nil error:&error];
    
    XCTAssertNil(result);
}

- (void)testHandleResponseFailureWithHttpErrorCode {
    id error = OCMClassMock([NSError class]);
    NSHTTPURLResponse *response = OCMClassMock([NSHTTPURLResponse class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] init];
    
    OCMStub([error alloc]).andReturn(error);
    OCMStub([error initWithDomain:[OCMArg any] code:response.statusCode userInfo:[OCMArg any]]).andReturn(error);
    
    NSError *placeholder;
    NSString *result = [client handleResponse:response data:nil error:&placeholder];
    
    XCTAssertNil(result);
    XCTAssertEqual(error, placeholder);
    
    OCMVerify([error initWithDomain:response.description code:response.statusCode userInfo:response.allHeaderFields]);
    
    [error stopMocking];
}

- (void)testHandleResponseFailureWithHttpNotFoundErrorCode {
    id config = OCMClassMock([PCFDataConfig class]);
    NSHTTPURLResponse *response = OCMClassMock([NSHTTPURLResponse class]);
    PCFEtagStore *etagStore = OCMClassMock([PCFEtagStore class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] initWithEtagStore:etagStore];
    
    OCMStub([config sharedInstance]).andReturn(config);
    OCMStub([config collisionStrategy]).andReturn(PCFCollisionStrategyOptimisticLocking);
    OCMStub([response statusCode]).andReturn(404);
    
    XCTAssertNil([client handleResponse:response data:nil error:nil]);
    
    OCMVerify([etagStore putEtagForUrl:response.URL etag:@""]);
    
    [config stopMocking];
}

- (void)testHandleResponseSuccess {
    NSData *data = [self.result dataUsingEncoding:NSUTF8StringEncoding];
    NSHTTPURLResponse *response = OCMClassMock([NSHTTPURLResponse class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] init];
    
    OCMStub([response statusCode]).andReturn(200);
    
    NSString *result = [client handleResponse:response data:data error:nil];
    
    XCTAssertEqualObjects(result, self.result);
}

- (void)testHandleResponseSuccessWithEtag {
    id config = OCMClassMock([PCFDataConfig class]);
    NSData *data = [self.result dataUsingEncoding:NSUTF8StringEncoding];
    NSHTTPURLResponse *response = OCMClassMock([NSHTTPURLResponse class]);
    NSDictionary *dict = OCMClassMock([NSDictionary class]);
    PCFEtagStore *etagStore = OCMClassMock([PCFEtagStore class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] initWithEtagStore:etagStore];

    OCMStub([config sharedInstance]).andReturn(config);
    OCMStub([config collisionStrategy]).andReturn(PCFCollisionStrategyOptimisticLocking);
    OCMStub([response statusCode]).andReturn(200);
    OCMStub([response allHeaderFields]).andReturn(dict);
    OCMStub([dict valueForKey:@"Etag"]).andReturn(self.etag);
    
    NSString *result = [client handleResponse:response data:data error:nil];
    
    XCTAssertEqualObjects(result, self.result);
    
    OCMVerify([etagStore putEtagForUrl:response.URL etag:self.etag]);
    
    [config stopMocking];
}

@end
