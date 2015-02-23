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

@interface PCFKeyValueRemoteStore ()

- (NSURL *)urlForKeyValue:(PCFKeyValue *)keyValue;

@end

@interface PCFKeyValueRemoteStoreTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *token;
@property NSString *collection;
@property NSError *error;
@property NSURL *url;
@property BOOL force;

@end

@implementation PCFKeyValueRemoteStoreTests

- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
    self.collection = [NSUUID UUID].UUIDString;
    self.force = arc4random_uniform(2);
    
    self.error = [[NSError alloc] init];
    self.url = [NSURL URLWithString:@"http://test.com"];
}

- (PCFDataRequest *)createRequestWithMethod:(int)method {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    return [[PCFDataRequest alloc] initWithMethod:method object:keyValue fallback:nil force:self.force];
}

- (void)testGetInvokesRemoteClient {
    PCFDataRequest *request = [self createRequestWithMethod:PCF_HTTP_GET];
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFKeyValueRemoteStore *dataStore = OCMPartialMock([[PCFKeyValueRemoteStore alloc] initWithClient:client]);
    
    OCMStub([dataStore urlForKeyValue:[OCMArg any]]).andReturn(self.url);
    OCMStub([client getWithUrl:[OCMArg any] force:self.force error:[OCMArg anyObjectRef]]).andReturn(self.value);
    
    PCFDataResponse *response = [dataStore executeRequest:request];
    PCFKeyValue *responseObject = (PCFKeyValue *)response.object;
    
    XCTAssertEqual(responseObject.key, self.key);
    XCTAssertEqual(responseObject.value, self.value);
    XCTAssertEqual(responseObject.collection, self.collection);
    
    OCMVerify([client getWithUrl:self.url force:self.force error:[OCMArg anyObjectRef]]);
}

- (void)testPutInvokesRemoteClient {
    PCFDataRequest *request = [self createRequestWithMethod:PCF_HTTP_PUT];
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFKeyValueRemoteStore *dataStore = OCMPartialMock([[PCFKeyValueRemoteStore alloc] initWithClient:client]);
    
    OCMStub([dataStore urlForKeyValue:[OCMArg any]]).andReturn(self.url);
    OCMStub([client putWithUrl:[OCMArg any] body:[OCMArg any] force:self.force error:[OCMArg anyObjectRef]]).andReturn(self.value);
    
    PCFDataResponse *response = [dataStore executeRequest:request];
    PCFKeyValue *responseObject = (PCFKeyValue *)response.object;
    
    XCTAssertEqual(responseObject.key, self.key);
    XCTAssertEqual(responseObject.value, self.value);
    XCTAssertEqual(responseObject.collection, self.collection);
    
    OCMVerify([client putWithUrl:self.url body:self.value force:self.force error:[OCMArg anyObjectRef]]);
}

- (void)testDeleteInvokesRemoteClient {
    PCFDataRequest *request = [self createRequestWithMethod:PCF_HTTP_DELETE];
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFKeyValueRemoteStore *dataStore = OCMPartialMock([[PCFKeyValueRemoteStore alloc] initWithClient:client]);
    
    OCMStub([dataStore urlForKeyValue:[OCMArg any]]).andReturn(self.url);
    OCMStub([client deleteWithUrl:[OCMArg any] force:self.force error:[OCMArg anyObjectRef]]).andReturn(self.value);
    
    PCFDataResponse *response = [dataStore executeRequest:request];
    PCFKeyValue *responseObject = (PCFKeyValue *)response.object;
    
    XCTAssertEqual(responseObject.key, self.key);
    XCTAssertEqual(responseObject.value, self.value);
    XCTAssertEqual(responseObject.collection, self.collection);
    
    OCMVerify([client deleteWithUrl:self.url force:self.force error:[OCMArg anyObjectRef]]);
}

- (void)testExecuteRequestWithCompletionHandler {
    PCFDataRequest *request = OCMClassMock([PCFDataRequest class]);
    PCFDataResponse *response = OCMClassMock([PCFDataResponse class]);
    PCFKeyValueRemoteStore *dataStore = OCMPartialMock([[PCFKeyValueRemoteStore alloc] init]);
    
    OCMStub([dataStore executeRequest:[OCMArg any]]).andReturn(response);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [dataStore executeRequest:request completionBlock:^(PCFDataResponse *resp) {
        XCTAssertEqual(response, resp);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
    
    OCMVerify([dataStore executeRequest:request]);
}

@end