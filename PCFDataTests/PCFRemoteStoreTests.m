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
#import <PCFData/PCFRemoteStore.h>
#import <PCFData/PCFResponse.h>
#import <PCFData/PCFRemoteClient.h>

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
    
    OCMStub([dataStore urlForKey:self.key]).andReturn(self.url);
    OCMStub([client getWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef]]).andReturn(self.value);
    
    PCFResponse *response = [dataStore getWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.value, self.value);
    
    OCMVerify([client getWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef]]);
}

- (void)testGetInvokesRemoteClientWithError {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:self.key]).andReturn(self.url);
    OCMStub([client getWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
        NSError *__autoreleasing *errorPtrPtr;
        [invocation getArgument:&errorPtrPtr atIndex:4];
        *errorPtrPtr = self.error;
    });
    
    PCFResponse *response = [dataStore getWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.error, self.error);
    
    OCMVerify([client getWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef]]);
}

- (void)testAsyncGetInvokesRemoteClient {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:self.key]).andReturn(self.url);
    OCMStub([client getWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef]]).andReturn(self.value);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    [dataStore getWithKey:self.key accessToken:self.token completionBlock:^(PCFResponse *response) {
        XCTAssertEqual(response.key, self.key);
        XCTAssertEqual(response.value, self.value);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OCMVerify([client getWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef]]);
}

- (void)testAsyncGetInvokesRemoteClientWithError {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:self.key]).andReturn(self.url);
    OCMStub([client getWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
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
    
    OCMVerify([client getWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef]]);
}


- (void)testPutInvokesRemoteClient {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:self.key]).andReturn(self.url);
    OCMStub([client putWithAccessToken:self.token url:self.url value:self.value error:[OCMArg anyObjectRef]]).andReturn(self.value);
    
    PCFResponse *response = [dataStore putWithKey:self.key value:self.value accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.value, self.value);
    
    OCMVerify([client putWithAccessToken:self.token url:self.url value:self.value error:[OCMArg anyObjectRef]]);
}

- (void)testPutInvokesRemoteClientWithError {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:self.key]).andReturn(self.url);
    OCMStub([client putWithAccessToken:self.token url:self.url value:self.value error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
        NSError *__autoreleasing *errorPtrPtr;
        [invocation getArgument:&errorPtrPtr atIndex:5];
        *errorPtrPtr = self.error;
    });
    
    PCFResponse *response = [dataStore putWithKey:self.key value:self.value accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.error, self.error);
    
    OCMVerify([client putWithAccessToken:self.token url:self.url value:self.value error:[OCMArg anyObjectRef]]);
}

- (void)testAsyncPutInvokesRemoteClient {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:self.key]).andReturn(self.url);
    OCMStub([client putWithAccessToken:self.token url:self.url value:self.value error:[OCMArg anyObjectRef]]).andReturn(self.value);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    [dataStore putWithKey:self.key value:self.value accessToken:self.token completionBlock:^(PCFResponse *response) {
        XCTAssertEqual(response.key, self.key);
        XCTAssertEqual(response.value, self.value);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OCMVerify([client putWithAccessToken:self.token url:self.url value:self.value error:[OCMArg anyObjectRef]]);
}

- (void)testAsyncPutInvokesRemoteClientWithError {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:self.key]).andReturn(self.url);
    OCMStub([client putWithAccessToken:self.token url:self.url value:self.value error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
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
    
    OCMVerify([client putWithAccessToken:self.token url:self.url value:self.value error:[OCMArg anyObjectRef]]);
}


- (void)testDeleteInvokesRemoteClient {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:self.key]).andReturn(self.url);
    OCMStub([client deleteWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef]]).andReturn(self.value);
    
    PCFResponse *response = [dataStore deleteWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.value, self.value);
    
    OCMVerify([client deleteWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef]]);
}

- (void)testDeleteInvokesRemoteClientWithError {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:self.key]).andReturn(self.url);
    OCMStub([client deleteWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
        NSError *__autoreleasing *errorPtrPtr;
        [invocation getArgument:&errorPtrPtr atIndex:4];
        *errorPtrPtr = self.error;
    });
    
    PCFResponse *response = [dataStore deleteWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.error, self.error);
    
    OCMVerify([client deleteWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef]]);
}

- (void)testAsyncDeleteInvokesRemoteClient {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:self.key]).andReturn(self.url);
    OCMStub([client deleteWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef]]).andReturn(self.value);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    [dataStore deleteWithKey:self.key accessToken:self.token completionBlock:^(PCFResponse *response) {
        XCTAssertEqual(response.key, self.key);
        XCTAssertEqual(response.value, self.value);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OCMVerify([client deleteWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef]]);
}

- (void)testAsyncDeleteInvokesRemoteClientWithError {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = OCMPartialMock([[PCFRemoteStore alloc] initWithCollection:self.collection client:client]);
    
    OCMStub([dataStore urlForKey:self.key]).andReturn(self.url);
    OCMStub([client deleteWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
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
    
    OCMVerify([client deleteWithAccessToken:self.token url:self.url error:[OCMArg anyObjectRef]]);
}


@end