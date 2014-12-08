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

@interface PCFRemoteClientTests : XCTestCase

@property NSString *token;
@property NSString *result;
@property NSError *error;
@property NSURL *url;
@property int httpErrorCode;
@property NSString *etag;

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
}

- (void)testGetSucceeds {
    NSData *data = [self.result dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = OCMClassMock([NSURLRequest class]);
    id connection = OCMClassMock([NSURLConnection class]);

    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] init]);

    OCMStub([client requestWithMethod:[OCMArg any] accessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any]]).andReturn(request);
    OCMStub([connection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andReturn(data);
    
    NSString *value = [client getWithAccessToken:self.token url:self.url error:nil];

    XCTAssertEqualObjects(value, self.result);
    
    OCMVerify([client requestWithMethod:@"GET" accessToken:self.token url:self.url value:nil]);
    OCMVerify([connection sendSynchronousRequest:request returningResponse:[OCMArg anyObjectRef] error:nil]);
    
    [connection stopMocking];
}

- (void)testGetFailsWithHttpErrorCode {
    NSURLRequest *request = OCMClassMock([NSURLRequest class]);
    id connection = OCMClassMock([NSURLConnection class]);
    
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] init]);
    
    OCMStub([client requestWithMethod:[OCMArg any] accessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any]]).andReturn(request);
    OCMStub([connection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
        NSHTTPURLResponse *__autoreleasing *responsePtrPtr;
        [invocation getArgument:&responsePtrPtr atIndex:3];
        (*responsePtrPtr) = [[NSHTTPURLResponse alloc] initWithURL:self.url statusCode:self.httpErrorCode HTTPVersion:nil headerFields:nil];
    });
    
    NSError *error;
    NSString *value = [client getWithAccessToken:self.token url:self.url error:&error];

    XCTAssertNil(value);
    XCTAssertEqual(error.code, self.httpErrorCode);
    
    OCMVerify([client requestWithMethod:@"GET" accessToken:self.token url:self.url value:nil]);
    OCMVerify([connection sendSynchronousRequest:request returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]);
    
    [connection stopMocking];
}

- (void)testGetFailsWithError {
    NSURLRequest *request = OCMClassMock([NSURLRequest class]);
    id connection = OCMClassMock([NSURLConnection class]);
    
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] init]);
    
    OCMStub([client requestWithMethod:[OCMArg any] accessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any]]).andReturn(request);
    OCMStub([connection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
        NSError *__autoreleasing *errorPtrPtr;
        [invocation getArgument:&errorPtrPtr atIndex:4];
        *errorPtrPtr = self.error;
    });
    
    NSError *error;
    NSString *value = [client getWithAccessToken:self.token url:self.url error:&error];
    
    XCTAssertNil(value);
    XCTAssertEqual(error, self.error);
    
    OCMVerify([client requestWithMethod:@"GET" accessToken:self.token url:self.url value:nil]);
    OCMVerify([connection sendSynchronousRequest:request returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]);
    
    [connection stopMocking];
}

- (void)testPutSucceeds {
    NSData *data = [self.result dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = OCMClassMock([NSURLRequest class]);
    id connection = OCMClassMock([NSURLConnection class]);
    
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] init]);
    
    OCMStub([client requestWithMethod:[OCMArg any] accessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any]]).andReturn(request);
    OCMStub([connection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andReturn(data);
    
    NSString *value = [client putWithAccessToken:self.token url:self.url value:self.result error:nil];
    
    XCTAssertEqualObjects(value, self.result);
    
    OCMVerify([client requestWithMethod:@"PUT" accessToken:self.token url:self.url value:self.result]);
    OCMVerify([connection sendSynchronousRequest:request returningResponse:[OCMArg anyObjectRef] error:nil]);
    
    [connection stopMocking];
}

- (void)testPutFailsWithHttpErrorCode {
    NSURLRequest *request = OCMClassMock([NSURLRequest class]);
    id connection = OCMClassMock([NSURLConnection class]);
    
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] init]);
    
    OCMStub([client requestWithMethod:[OCMArg any] accessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any]]).andReturn(request);
    OCMStub([connection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
        NSHTTPURLResponse *__autoreleasing *responsePtrPtr;
        [invocation getArgument:&responsePtrPtr atIndex:3];
        (*responsePtrPtr) = [[NSHTTPURLResponse alloc] initWithURL:self.url statusCode:self.httpErrorCode HTTPVersion:nil headerFields:nil];
    });
    
    NSError *error;
    NSString *value = [client putWithAccessToken:self.token url:self.url value:self.result error:&error];
    
    XCTAssertNil(value);
    XCTAssertEqual(error.code, self.httpErrorCode);
    
    OCMVerify([client requestWithMethod:@"PUT" accessToken:self.token url:self.url value:self.result]);
    OCMVerify([connection sendSynchronousRequest:request returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]);
    
    [connection stopMocking];
}

- (void)testPutFailsWithError {
    NSURLRequest *request = OCMClassMock([NSURLRequest class]);
    id connection = OCMClassMock([NSURLConnection class]);
    
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] init]);
    
    OCMStub([client requestWithMethod:[OCMArg any] accessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any]]).andReturn(request);
    OCMStub([connection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
        NSError *__autoreleasing *errorPtrPtr;
        [invocation getArgument:&errorPtrPtr atIndex:4];
        *errorPtrPtr = self.error;
    });
    
    NSError *error;
    NSString *value = [client putWithAccessToken:self.token url:self.url value:self.result error:&error];
    
    XCTAssertNil(value);
    XCTAssertEqual(error, self.error);
    
    OCMVerify([client requestWithMethod:@"PUT" accessToken:self.token url:self.url value:self.result]);
    OCMVerify([connection sendSynchronousRequest:request returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]);
    
    [connection stopMocking];
}

- (void)testDeleteSucceeds {
    NSData *data = [self.result dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = OCMClassMock([NSURLRequest class]);
    id connection = OCMClassMock([NSURLConnection class]);
    
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] init]);
    
    OCMStub([client requestWithMethod:[OCMArg any] accessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any]]).andReturn(request);
    OCMStub([connection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andReturn(data);
    
    NSString *value = [client deleteWithAccessToken:self.token url:self.url error:nil];
    
    XCTAssertEqualObjects(value, self.result);
    
    OCMVerify([client requestWithMethod:@"DELETE" accessToken:self.token url:self.url value:nil]);
    OCMVerify([connection sendSynchronousRequest:request returningResponse:[OCMArg anyObjectRef] error:nil]);
    
    [connection stopMocking];
}

- (void)testDeleteFailsWithHttpErrorCode {
    NSURLRequest *request = OCMClassMock([NSURLRequest class]);
    id connection = OCMClassMock([NSURLConnection class]);
    
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] init]);
    
    OCMStub([client requestWithMethod:[OCMArg any] accessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any]]).andReturn(request);
    OCMStub([connection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
        NSHTTPURLResponse *__autoreleasing *responsePtrPtr;
        [invocation getArgument:&responsePtrPtr atIndex:3];
        (*responsePtrPtr) = [[NSHTTPURLResponse alloc] initWithURL:self.url statusCode:self.httpErrorCode HTTPVersion:nil headerFields:nil];
    });
    
    NSError *error;
    NSString *value = [client deleteWithAccessToken:self.token url:self.url error:&error];
    
    XCTAssertNil(value);
    XCTAssertEqual(error.code, self.httpErrorCode);
    
    OCMVerify([client requestWithMethod:@"DELETE" accessToken:self.token url:self.url value:nil]);
    OCMVerify([connection sendSynchronousRequest:request returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]);
    
    [connection stopMocking];
}

- (void)testDeleteFailsWithError {
    NSURLRequest *request = OCMClassMock([NSURLRequest class]);
    id connection = OCMClassMock([NSURLConnection class]);
    
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] init]);
    
    OCMStub([client requestWithMethod:[OCMArg any] accessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any]]).andReturn(request);
    OCMStub([connection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
        NSError *__autoreleasing *errorPtrPtr;
        [invocation getArgument:&errorPtrPtr atIndex:4];
        *errorPtrPtr = self.error;
    });
    
    NSError *error;
    NSString *value = [client deleteWithAccessToken:self.token url:self.url error:&error];
    
    XCTAssertNil(value);
    XCTAssertEqual(error, self.error);
    
    OCMVerify([client requestWithMethod:@"DELETE" accessToken:self.token url:self.url value:nil]);
    OCMVerify([connection sendSynchronousRequest:request returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]);
    
    [connection stopMocking];
}

- (void)testRequestWithMethodWithAccessTokenAndValue {
    PCFRemoteClient *client = [[PCFRemoteClient alloc] init];
    
    NSString *method = [NSUUID UUID].UUIDString;
    NSURLRequest *request = [client requestWithMethod:method accessToken:self.token url:self.url value:self.result];
    
    NSString *token = [@"Bearer " stringByAppendingString:self.token];
    NSString *authHeader = [request.allHTTPHeaderFields valueForKey:@"Authorization"];
    NSString *decodedBody = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
    
    XCTAssertEqualObjects(method, request.HTTPMethod);
    XCTAssertEqualObjects(token, authHeader);
    XCTAssertEqualObjects(self.url, request.URL);
    XCTAssertEqualObjects(self.result, decodedBody);
}

- (void)testRequestWithMethodSetsEtagWhenExists {
    PCFEtagStore *etagStore = OCMClassMock([PCFEtagStore class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] initWithEtagStore:etagStore];
    
    OCMStub([etagStore getEtagForUrl:[OCMArg any]]).andReturn(self.etag);
    
    NSURLRequest *request = [client requestWithMethod:nil accessToken:nil url:self.url value:nil];
    
    XCTAssertEqual(self.etag, [request.allHTTPHeaderFields valueForKey:@"Etag"]);
    
    OCMVerify([etagStore getEtagForUrl:[self.url absoluteString]]);
}

@end
