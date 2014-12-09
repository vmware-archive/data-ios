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

- (void)testGet {
    NSData *data = [self.result dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = OCMClassMock([NSURLRequest class]);
    id connection = OCMClassMock([NSURLConnection class]);

    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] init]);

    OCMStub([client requestWithMethod:[OCMArg any] accessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any]]).andReturn(request);
    OCMStub([connection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andReturn(data);
    OCMStub([client handleResponse:[OCMArg any] data:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(self.result);

    NSString *value = [client getWithAccessToken:self.token url:self.url error:nil];

    XCTAssertEqualObjects(value, self.result);

    OCMVerify([client requestWithMethod:@"GET" accessToken:self.token url:self.url value:nil]);
    OCMVerify([connection sendSynchronousRequest:request returningResponse:[OCMArg anyObjectRef] error:nil]);
    OCMVerify([client handleResponse:[OCMArg any] data:data error:nil]);
    
    [connection stopMocking];
}

- (void)testPut {
    NSData *data = [self.result dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = OCMClassMock([NSURLRequest class]);
    id connection = OCMClassMock([NSURLConnection class]);

    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] init]);

    OCMStub([client requestWithMethod:[OCMArg any] accessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any]]).andReturn(request);
    OCMStub([connection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andReturn(data);
    OCMStub([client handleResponse:[OCMArg any] data:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(self.result);
    
    NSString *value = [client putWithAccessToken:self.token url:self.url value:self.result error:nil];

    XCTAssertEqualObjects(value, self.result);

    OCMVerify([client requestWithMethod:@"PUT" accessToken:self.token url:self.url value:self.result]);
    OCMVerify([connection sendSynchronousRequest:request returningResponse:[OCMArg anyObjectRef] error:nil]);
    OCMVerify([client handleResponse:[OCMArg any] data:data error:nil]);
    
    [connection stopMocking];
}

- (void)testDelete {
    NSData *data = [self.result dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = OCMClassMock([NSURLRequest class]);
    id connection = OCMClassMock([NSURLConnection class]);

    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] init]);

    OCMStub([client requestWithMethod:[OCMArg any] accessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any]]).andReturn(request);
    OCMStub([connection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andReturn(data);
    OCMStub([client handleResponse:[OCMArg any] data:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(self.result);

    NSString *value = [client deleteWithAccessToken:self.token url:self.url error:nil];

    XCTAssertEqualObjects(value, self.result);

    OCMVerify([client requestWithMethod:@"DELETE" accessToken:self.token url:self.url value:nil]);
    OCMVerify([connection sendSynchronousRequest:request returningResponse:[OCMArg anyObjectRef] error:nil]);
    OCMVerify([client handleResponse:[OCMArg any] data:data error:nil]);
    
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

- (void)testRequestWithMethodSetsEtagWhenExistsForGet {
    PCFEtagStore *etagStore = OCMClassMock([PCFEtagStore class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] initWithEtagStore:etagStore];
    
    OCMStub([etagStore getEtagForUrl:[OCMArg any]]).andReturn(self.etag);
    
    NSURLRequest *request = [client requestWithMethod:@"GET" accessToken:nil url:self.url value:nil];
    
    XCTAssertEqual(self.etag, [request.allHTTPHeaderFields valueForKey:@"If-None-Match"]);
    
    OCMVerify([etagStore getEtagForUrl:self.url]);
}

- (void)testRequestWithMethodSetsEtagWhenExistsForPut {
    PCFEtagStore *etagStore = OCMClassMock([PCFEtagStore class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] initWithEtagStore:etagStore];
    
    OCMStub([etagStore getEtagForUrl:[OCMArg any]]).andReturn(self.etag);
    
    NSURLRequest *request = [client requestWithMethod:@"PUT" accessToken:nil url:self.url value:nil];
    
    XCTAssertEqual(self.etag, [request.allHTTPHeaderFields valueForKey:@"If-Match"]);
    
    OCMVerify([etagStore getEtagForUrl:self.url]);
}

- (void)testRequestWithMethodSetsEtagWhenExistsForDelete {
    PCFEtagStore *etagStore = OCMClassMock([PCFEtagStore class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] initWithEtagStore:etagStore];
    
    OCMStub([etagStore getEtagForUrl:[OCMArg any]]).andReturn(self.etag);
    
    NSURLRequest *request = [client requestWithMethod:@"DELETE" accessToken:nil url:self.url value:nil];
    
    XCTAssertEqual(self.etag, [request.allHTTPHeaderFields valueForKey:@"If-Match"]);
    
    OCMVerify([etagStore getEtagForUrl:self.url]);
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

- (void)testHandleResponseSuccess {
    NSData *data = [self.result dataUsingEncoding:NSUTF8StringEncoding];
    NSHTTPURLResponse *response = OCMClassMock([NSHTTPURLResponse class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] init];
    
    OCMStub([response statusCode]).andReturn(200);
    
    NSString *result = [client handleResponse:response data:data error:nil];
    
    XCTAssertEqualObjects(result, self.result);
}

- (void)testHandleResponseSuccessWithEtag {
    NSData *data = [self.result dataUsingEncoding:NSUTF8StringEncoding];
    NSHTTPURLResponse *response = OCMClassMock([NSHTTPURLResponse class]);
    NSDictionary *dict = OCMClassMock([NSDictionary class]);
    PCFEtagStore *etagStore = OCMClassMock([PCFEtagStore class]);
    PCFRemoteClient *client = [[PCFRemoteClient alloc] initWithEtagStore:etagStore];
    
    OCMStub([response statusCode]).andReturn(200);
    OCMStub([response allHeaderFields]).andReturn(dict);
    OCMStub([dict valueForKey:@"Etag"]).andReturn(self.etag);
    
    NSString *result = [client handleResponse:response data:data error:nil];
    
    XCTAssertEqualObjects(result, self.result);
    
    OCMVerify([etagStore putEtagForUrl:response.URL etag:self.etag]);
}

@end
