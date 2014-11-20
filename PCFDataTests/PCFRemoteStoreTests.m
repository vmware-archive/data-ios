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
#import "PCFRemoteStore.h"

@interface PCFRemoteStoreTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *token;
@property NSString *collection;
@property NSError *error;

@end

@implementation PCFRemoteStoreTests

- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
    self.collection = [NSUUID UUID].UUIDString;
    
    self.error = [[NSError alloc] init];
}

- (void)testGetInvokesRemoteClient {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = [[PCFRemoteStore alloc] initWithCollection:self.collection client:client];
    
    OCMStub([client getWithAccessToken:self.token url:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(self.value);
    
    PCFResponse *response = [dataStore getWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.value, self.value);
    
    OCMVerify([client getWithAccessToken:self.token url:[OCMArg any] error:[OCMArg anyObjectRef]]);
}

- (void)testGetInvokesRemoteClientWithError {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = [[PCFRemoteStore alloc] initWithCollection:self.collection client:client];
    
    OCMStub([client getWithAccessToken:self.token url:[OCMArg any] error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
        NSError *__autoreleasing *errorPtrPtr;
        [invocation getArgument:&errorPtrPtr atIndex:4];
        *errorPtrPtr = self.error;
    });
    
    PCFResponse *response = [dataStore getWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.error, self.error);
    
    OCMVerify([client getWithAccessToken:self.token url:[OCMArg any] error:[OCMArg anyObjectRef]]);
}

- (void)testPutInvokesRemoteClient {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = [[PCFRemoteStore alloc] initWithCollection:self.collection client:client];
    
    OCMStub([client putWithAccessToken:self.token url:[OCMArg any] value:self.value error:[OCMArg anyObjectRef]]).andReturn(self.value);
    
    PCFResponse *response = [dataStore putWithKey:self.key value:self.value accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.value, self.value);
    
    OCMVerify([client putWithAccessToken:self.token url:[OCMArg any] value:self.value error:[OCMArg anyObjectRef]]);
}

- (void)testPutInvokesRemoteClientWithError {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = [[PCFRemoteStore alloc] initWithCollection:self.collection client:client];
    
    OCMStub([client putWithAccessToken:self.token url:[OCMArg any] value:self.value error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
        NSError *__autoreleasing *errorPtrPtr;
        [invocation getArgument:&errorPtrPtr atIndex:5];
        *errorPtrPtr = self.error;
    });
    
    PCFResponse *response = [dataStore putWithKey:self.key value:self.value accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.error, self.error);
    
    OCMVerify([client putWithAccessToken:self.token url:[OCMArg any] value:self.value error:[OCMArg anyObjectRef]]);
}

- (void)testDeleteInvokesRemoteClient {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = [[PCFRemoteStore alloc] initWithCollection:self.collection client:client];
    
    OCMStub([client deleteWithAccessToken:self.token url:[OCMArg any] error:[OCMArg anyObjectRef]]).andReturn(self.value);
    
    PCFResponse *response = [dataStore deleteWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.value, self.value);
    
    OCMVerify([client deleteWithAccessToken:self.token url:[OCMArg any] error:[OCMArg anyObjectRef]]);
}

- (void)testDeleteInvokesRemoteClientWithError {
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = [[PCFRemoteStore alloc] initWithCollection:self.collection client:client];
    
    OCMStub([client deleteWithAccessToken:self.token url:[OCMArg any] error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
        NSError *__autoreleasing *errorPtrPtr;
        [invocation getArgument:&errorPtrPtr atIndex:4];
        *errorPtrPtr = self.error;
    });
    
    PCFResponse *response = [dataStore deleteWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.error, self.error);
    
    OCMVerify([client deleteWithAccessToken:self.token url:[OCMArg any] error:[OCMArg anyObjectRef]]);
}



- (NSURL *)url {
    return [NSURL URLWithString:@"http://test.com"];
}


@end