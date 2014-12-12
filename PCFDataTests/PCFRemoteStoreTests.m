//
//  PCFRemoteStoreTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-11-20.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>
#import "PCFRemoteClient.h"

@interface PCFRemoteStoreTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *token;
@property NSString *collection;
@property NSError *error;
@property NSURL *url;

@end

@implementation PCFRemoteStoreTests

- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
    self.collection = [NSUUID UUID].UUIDString;
    
    self.error = [[NSError alloc] init];
    self.url = [NSURL URLWithString:@"http://test.com"];
}

- (void)testGetInvokesRemoteClient {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:[OCMArg any]]).andReturn(self.url);
    OCMStub([client getWithAccessToken:[OCMArg any] url:[OCMArg any] error:[OCMArg anyObjectRef] force:false]).andReturn(self.value);
    
    PCFResponse *response = [dataStore getWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.value, self.value);
    
    OCMVerify([dataStore urlForKey:self.key]);
    OCMVerify([client getWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef] force:false]);
}

- (void)testGetInvokesRemoteClientWithError {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:[OCMArg any]]).andReturn(self.url);
    OCMStub([client getWithAccessToken:[OCMArg any] url:[OCMArg any] error:[OCMArg anyObjectRef] force:false]).andDo(^(NSInvocation *invocation) {
        NSError *__autoreleasing *errorPtrPtr;
        [invocation getArgument:&errorPtrPtr atIndex:4];
        *errorPtrPtr = self.error;
    });
    
    PCFResponse *response = [dataStore getWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.error, self.error);
    
    OCMVerify([dataStore urlForKey:self.key]);
    OCMVerify([client getWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef] force:false]);
}

- (void)testAsyncGetInvokesRemoteClient {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:[OCMArg any]]).andReturn(self.url);
    OCMStub([client getWithAccessToken:[OCMArg any] url:[OCMArg any] error:[OCMArg anyObjectRef] force:false]).andReturn(self.value);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    [dataStore getWithKey:self.key accessToken:self.token completionBlock:^(PCFResponse *response) {
        XCTAssertEqual(response.key, self.key);
        XCTAssertEqual(response.value, self.value);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OCMVerify([dataStore urlForKey:self.key]);
    OCMVerify([client getWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef] force:false]);
}

- (void)testAsyncGetInvokesRemoteClientWithError {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:[OCMArg any]]).andReturn(self.url);
    OCMStub([client getWithAccessToken:[OCMArg any] url:[OCMArg any] error:[OCMArg anyObjectRef] force:false]).andDo(^(NSInvocation *invocation) {
        NSError *__autoreleasing *errorPtrPtr;
        [invocation getArgument:&errorPtrPtr atIndex:4];
        *errorPtrPtr = self.error;
    });
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    [dataStore getWithKey:self.key accessToken:self.token completionBlock:^(PCFResponse *response) {
        XCTAssertEqual(response.key, self.key);
        XCTAssertEqual(response.error, self.error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OCMVerify([dataStore urlForKey:self.key]);
    OCMVerify([client getWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef] force:false]);
}


- (void)testPutInvokesRemoteClient {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:[OCMArg any]]).andReturn(self.url);
    OCMStub([client putWithAccessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any] error:[OCMArg anyObjectRef] force:false]).andReturn(self.value);
    
    PCFResponse *response = [dataStore putWithKey:self.key value:self.value accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.value, self.value);
    
    OCMVerify([dataStore urlForKey:self.key]);
    OCMVerify([client putWithAccessToken:self.token url:self.url value:self.value error:[OCMArg anyObjectRef] force:false]);
}

- (void)testPutInvokesRemoteClientWithError {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:[OCMArg any]]).andReturn(self.url);
    OCMStub([client putWithAccessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any] error:[OCMArg anyObjectRef] force:false]).andDo(^(NSInvocation *invocation) {
        NSError *__autoreleasing *errorPtrPtr;
        [invocation getArgument:&errorPtrPtr atIndex:5];
        *errorPtrPtr = self.error;
    });
    
    PCFResponse *response = [dataStore putWithKey:self.key value:self.value accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.error, self.error);
    
    OCMVerify([dataStore urlForKey:self.key]);
    OCMVerify([client putWithAccessToken:self.token url:self.url value:self.value error:[OCMArg anyObjectRef] force:false]);
}

- (void)testAsyncPutInvokesRemoteClient {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:[OCMArg any]]).andReturn(self.url);
    OCMStub([client putWithAccessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any] error:[OCMArg anyObjectRef] force:false]).andReturn(self.value);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    [dataStore putWithKey:self.key value:self.value accessToken:self.token completionBlock:^(PCFResponse *response) {
        XCTAssertEqual(response.key, self.key);
        XCTAssertEqual(response.value, self.value);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OCMVerify([dataStore urlForKey:self.key]);
    OCMVerify([client putWithAccessToken:self.token url:self.url value:self.value error:[OCMArg anyObjectRef] force:false]);
}

- (void)testAsyncPutInvokesRemoteClientWithError {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:[OCMArg any]]).andReturn(self.url);
    OCMStub([client putWithAccessToken:[OCMArg any] url:[OCMArg any] value:[OCMArg any] error:[OCMArg anyObjectRef] force:false]).andDo(^(NSInvocation *invocation) {
        NSError *__autoreleasing *errorPtrPtr;
        [invocation getArgument:&errorPtrPtr atIndex:5];
        *errorPtrPtr = self.error;
    });
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    [dataStore putWithKey:self.key value:self.value accessToken:self.token completionBlock:^(PCFResponse *response) {
        XCTAssertEqual(response.key, self.key);
        XCTAssertEqual(response.error, self.error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OCMVerify([dataStore urlForKey:self.key]);
    OCMVerify([client putWithAccessToken:self.token url:self.url value:self.value error:[OCMArg anyObjectRef] force:false]);
}


- (void)testDeleteInvokesRemoteClient {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:[OCMArg any]]).andReturn(self.url);
    OCMStub([client deleteWithAccessToken:[OCMArg any] url:[OCMArg any] error:[OCMArg anyObjectRef] force:false]).andReturn(self.value);
    
    PCFResponse *response = [dataStore deleteWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.value, self.value);
    
    OCMVerify([dataStore urlForKey:self.key]);
    OCMVerify([client deleteWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef] force:false]);
}

- (void)testDeleteInvokesRemoteClientWithError {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:[OCMArg any]]).andReturn(self.url);
    OCMStub([client deleteWithAccessToken:[OCMArg any] url:[OCMArg any] error:[OCMArg anyObjectRef] force:false]).andDo(^(NSInvocation *invocation) {
        NSError *__autoreleasing *errorPtrPtr;
        [invocation getArgument:&errorPtrPtr atIndex:4];
        *errorPtrPtr = self.error;
    });
    
    PCFResponse *response = [dataStore deleteWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.error, self.error);
    
    OCMVerify([dataStore urlForKey:self.key]);
    OCMVerify([client deleteWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef] force:false]);
}

- (void)testAsyncDeleteInvokesRemoteClient {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:[OCMArg any]]).andReturn(self.url);
    OCMStub([client deleteWithAccessToken:[OCMArg any] url:[OCMArg any] error:[OCMArg anyObjectRef] force:false]).andReturn(self.value);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    [dataStore deleteWithKey:self.key accessToken:self.token completionBlock:^(PCFResponse *response) {
        XCTAssertEqual(response.key, self.key);
        XCTAssertEqual(response.value, self.value);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OCMVerify([dataStore urlForKey:self.key]);
    OCMVerify([client deleteWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef] force:false]);
}

- (void)testAsyncDeleteInvokesRemoteClientWithError {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:[OCMArg any]]).andReturn(self.url);
    OCMStub([client deleteWithAccessToken:[OCMArg any] url:[OCMArg any] error:[OCMArg anyObjectRef] force:false]).andDo(^(NSInvocation *invocation) {
        NSError *__autoreleasing *errorPtrPtr;
        [invocation getArgument:&errorPtrPtr atIndex:4];
        *errorPtrPtr = self.error;
    });
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    [dataStore deleteWithKey:self.key accessToken:self.token completionBlock:^(PCFResponse *response) {
        XCTAssertEqual(response.key, self.key);
        XCTAssertEqual(response.error, self.error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OCMVerify([dataStore urlForKey:self.key]);
    OCMVerify([client deleteWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef] force:false]);
}


@end