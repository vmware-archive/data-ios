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

- (instancetype)initWithEtagStore:(PCFEtagStore *)etagStore;

- (NSString *)execute:(NSURLRequest *)request error:(NSError *__autoreleasing *)error;

- (NSURLRequest *)requestWithMethod:(NSString*)method accessToken:(NSString *)accessToken url:(NSURL *)url value:(NSString *)value force:(BOOL)force;

- (NSString *)handleResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error;

@end

@interface PCFRemoteClientTests : XCTestCase

@property NSString *token;
@property NSString *result;
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
    
    self.error = [[NSError alloc] init];
    self.url = [NSURL URLWithString:@"http://test.com"];
    
    self.httpErrorCode = 300 + (arc4random() % 200);
    self.etag = [NSUUID UUID].UUIDString;
    self.force = arc4random_uniform(2);
}

- (PCFRequest *)createRequest {
    PCFKeyValue *keyValue = OCMClassMock([PCFKeyValue class]);
    OCMStub([keyValue url]).andReturn(self.url);
    OCMStub([keyValue value]).andReturn(self.result);
    return [[PCFRequest alloc] initWithAccessToken:self.token object:keyValue force:self.force];
}

- (void)testGetWithKeyValue {
    PCFRequest *request = [self createRequest];
    NSURLRequest *urlRequest = OCMClassMock([NSURLRequest class]);
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] initWithEtagStore:nil]);

    OCMStub([client requestWithMethod:[OCMArg any] accessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any] force:self.force]).andReturn(urlRequest);
    OCMStub([client execute:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(self.result);

    PCFResponse *response = [client getWithRequest:request];
    PCFKeyValue *responseObject = (PCFKeyValue *) response.object;

    XCTAssertEqualObjects(responseObject.value, self.result);

    OCMVerify([client requestWithMethod:@"GET" accessToken:self.token url:self.url value:nil force:self.force]);
    OCMVerify([client execute:urlRequest error:[OCMArg anyObjectRef]]);
}

- (void)testPutWithKeyValue {
    PCFRequest *request = [self createRequest];
    NSURLRequest *urlRequest = OCMClassMock([NSURLRequest class]);
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] initWithEtagStore:nil]);

    OCMStub([client requestWithMethod:[OCMArg any] accessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any] force:self.force]).andReturn(urlRequest);
    OCMStub([client execute:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(self.result);
    
    PCFResponse *response = [client putWithRequest:request];
    PCFKeyValue *responseObject = (PCFKeyValue *) response.object;

    XCTAssertEqualObjects(responseObject.value, self.result);

    OCMVerify([client requestWithMethod:@"PUT" accessToken:self.token url:self.url value:self.result force:self.force]);
    OCMVerify([client execute:urlRequest error:[OCMArg anyObjectRef]]);
}

- (void)testDeleteWithKeyValue {
    PCFRequest *request = [self createRequest];
    NSURLRequest *urlRequest = OCMClassMock([NSURLRequest class]);
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] initWithEtagStore:nil]);
    
    OCMStub([client requestWithMethod:[OCMArg any] accessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any] force:self.force]).andReturn(urlRequest);
    OCMStub([client execute:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(self.result);
    
    PCFResponse *response = [client deleteWithRequest:request];
    PCFKeyValue *responseObject = (PCFKeyValue *) response.object;
    
    XCTAssertEqualObjects(responseObject.value, self.result);
    
    OCMVerify([client requestWithMethod:@"DELETE" accessToken:self.token url:self.url value:nil force:self.force]);
    OCMVerify([client execute:urlRequest error:[OCMArg anyObjectRef]]);
}

- (void)testRequestWithMethodWithAccessTokenAndValue {
    PCFRemoteClient *client = [[PCFRemoteClient alloc] init];
    
    NSString *method = [NSUUID UUID].UUIDString;
    NSURLRequest *request = [client requestWithMethod:method accessToken:self.token url:self.url value:self.result force:self.force];
    
    NSString *token = [@"Bearer " stringByAppendingString:self.token];
    NSString *authHeader = [request.allHTTPHeaderFields valueForKey:@"Authorization"];
    NSString *decodedBody = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    
    XCTAssertEqualObjects(method, request.HTTPMethod);
    XCTAssertEqualObjects(token, authHeader);
    XCTAssertEqualObjects(self.url, request.URL);
    XCTAssertEqualObjects(self.result, decodedBody);
}

- (void)testRequestWithMethodSetsEtagWhenExistsForGet {
    id config = OCMClassMock([PCFDataConfig class]);
    PCFEtagStore *etagStore = OCMClassMock([PCFEtagStore class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] initWithEtagStore:etagStore];
    
    OCMStub([config sharedInstance]).andReturn(config);
    OCMStub([config collisionStrategy]).andReturn(PCFCollisionStrategyOptimisticLocking);
    OCMStub([etagStore etagForUrl:[OCMArg any]]).andReturn(self.etag);
    
    NSURLRequest *request = [client requestWithMethod:@"GET" accessToken:nil url:self.url value:nil force:false];
    
    XCTAssertEqual(self.etag, [request.allHTTPHeaderFields valueForKey:@"If-None-Match"]);
    
    OCMVerify([etagStore etagForUrl:self.url]);
    
    [config stopMocking];
}

- (void)testRequestWithMethodSetsEtagWhenExistsForPut {
    id config = OCMClassMock([PCFDataConfig class]);
    PCFEtagStore *etagStore = OCMClassMock([PCFEtagStore class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] initWithEtagStore:etagStore];
    
    OCMStub([config sharedInstance]).andReturn(config);
    OCMStub([config collisionStrategy]).andReturn(PCFCollisionStrategyOptimisticLocking);
    OCMStub([etagStore etagForUrl:[OCMArg any]]).andReturn(self.etag);
    
    NSURLRequest *request = [client requestWithMethod:@"PUT" accessToken:nil url:self.url value:nil force:false];
    
    XCTAssertEqual(self.etag, [request.allHTTPHeaderFields valueForKey:@"If-Match"]);
    
    OCMVerify([etagStore etagForUrl:self.url]);
    
    [config stopMocking];
}

- (void)testRequestWithMethodSetsEtagWhenExistsForDelete {
    id config = OCMClassMock([PCFDataConfig class]);
    PCFEtagStore *etagStore = OCMClassMock([PCFEtagStore class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] initWithEtagStore:etagStore];

    OCMStub([config sharedInstance]).andReturn(config);
    OCMStub([config collisionStrategy]).andReturn(PCFCollisionStrategyOptimisticLocking);
    OCMStub([etagStore etagForUrl:[OCMArg any]]).andReturn(self.etag);
    
    NSURLRequest *request = [client requestWithMethod:@"DELETE" accessToken:nil url:self.url value:nil force:false];
    
    XCTAssertEqual(self.etag, [request.allHTTPHeaderFields valueForKey:@"If-Match"]);
    
    OCMVerify([etagStore etagForUrl:self.url]);
    
    [config stopMocking];
}

- (void)testRequestWithMethodDoesntSetEtagForForceRequest {
    id config = OCMClassMock([PCFDataConfig class]);
    PCFEtagStore *etagStore = OCMStrictClassMock([PCFEtagStore class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] initWithEtagStore:etagStore];
    
    OCMStub([config sharedInstance]).andReturn(config);
    OCMStub([config collisionStrategy]).andReturn(PCFCollisionStrategyOptimisticLocking);
    
    NSURLRequest *request = [client requestWithMethod:@"GET" accessToken:nil url:self.url value:nil force:true];
    
    XCTAssertNil([request.allHTTPHeaderFields valueForKey:@"If-None-Match"]);
    XCTAssertNil([request.allHTTPHeaderFields valueForKey:@"If-Match"]);
    
    [config stopMocking];
}

- (void)testExecuteInvokesNSURLConnection {
    NSError *error = OCMClassMock([NSError class]);
    NSURLRequest *request = [[NSURLRequest alloc] init];
    NSData *data = [self.result dataUsingEncoding:NSUTF8StringEncoding];
    
    id connection = OCMClassMock([NSURLConnection class]);
    
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] initWithEtagStore:nil]);

    OCMStub([connection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andReturn(data);
    OCMStub([client handleResponse:[OCMArg any] data:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(self.result);
    
    NSString *value = [client execute:request error:&error];
    
    XCTAssertEqualObjects(value, self.result);
    
    OCMVerify([connection sendSynchronousRequest:request returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]);
    OCMVerify([client handleResponse:[OCMArg any] data:data error:[OCMArg anyObjectRef]]);
    
    [connection stopMocking];
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
