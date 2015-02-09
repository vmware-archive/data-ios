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
@property BOOL force;

@end

@implementation PCFRemoteStoreTests

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

- (PCFRequest *)createRequest {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    return [[PCFRequest alloc] initWithObject:keyValue fallback:nil force:self.force];
}

- (PCFResponse *)createResponseWithError:(NSError *)error {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    return [[PCFResponse alloc] initWithObject:keyValue error:error];
}

- (void)testGetInvokesRemoteClient {
    PCFRequest *request = [self createRequest];
    PCFResponse *response = [self createResponseWithError:nil];
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = [[PCFRemoteStore alloc] initWithClient:client];
    
    OCMStub([client getWithRequest:[OCMArg any]]).andReturn(response);
    
    XCTAssertEqual(response, [dataStore getWithRequest:request]);
    
    OCMVerify([client getWithRequest:request]);
}

- (void)testGetAsyncInvokesRemoteClient {
    PCFRequest *request = [self createRequest];
    PCFResponse *response = [self createResponseWithError:nil];
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = [[PCFRemoteStore alloc] initWithClient:client];
    
    OCMStub([client getWithRequest:[OCMArg any]]).andReturn(response);

    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [dataStore getWithRequest:request completionBlock:^(PCFResponse *resp) {
        XCTAssertEqual(response, resp);

        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
    
    OCMVerify([client getWithRequest:request]);
}

- (void)testPutInvokesRemoteClient {
    PCFRequest *request = [self createRequest];
    PCFResponse *response = [self createResponseWithError:nil];
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = [[PCFRemoteStore alloc] initWithClient:client];
    
    OCMStub([client putWithRequest:[OCMArg any]]).andReturn(response);
    
    XCTAssertEqual(response, [dataStore putWithRequest:request]);
    
    OCMVerify([client putWithRequest:request]);
}

- (void)testPutAsyncInvokesRemoteClient {
    PCFRequest *request = [self createRequest];
    PCFResponse *response = [self createResponseWithError:nil];
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = [[PCFRemoteStore alloc] initWithClient:client];
    
    OCMStub([client putWithRequest:[OCMArg any]]).andReturn(response);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [dataStore putWithRequest:request completionBlock:^(PCFResponse *resp) {
        XCTAssertEqual(response, resp);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
    
    OCMVerify([client putWithRequest:request]);
}

- (void)testDeleteInvokesRemoteClient {
    PCFRequest *request = [self createRequest];
    PCFResponse *response = [self createResponseWithError:nil];
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = [[PCFRemoteStore alloc] initWithClient:client];
    
    OCMStub([client deleteWithRequest:[OCMArg any]]).andReturn(response);
    
    XCTAssertEqual(response, [dataStore deleteWithRequest:request]);
    
    OCMVerify([client deleteWithRequest:request]);
}

- (void)testDeleteAsyncInvokesRemoteClient {
    PCFRequest *request = [self createRequest];
    PCFResponse *response = [self createResponseWithError:nil];
    PCFRemoteClient *client = OCMClassMock([PCFRemoteClient class]);
    PCFRemoteStore *dataStore = [[PCFRemoteStore alloc] initWithClient:client];
    
    OCMStub([client deleteWithRequest:[OCMArg any]]).andReturn(response);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [dataStore deleteWithRequest:request completionBlock:^(PCFResponse *resp) {
        XCTAssertEqual(response, resp);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
    
    OCMVerify([client deleteWithRequest:request]);
}

@end