//
//  PCFLocalStoreTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-11-19.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>
#import "PCFDataPersistence.h"
#import "PCFKeyValue.h"

@interface PCFKeyValueLocalStoreTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *token;
@property NSString *collection;
@property BOOL force;

@end

@implementation PCFKeyValueLocalStoreTests

static NSString* const PCFDataPrefix = @"PCFData:Data:";

- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
    self.collection = [NSUUID UUID].UUIDString;
    self.force = arc4random_uniform(2);
}

- (void)testExecuteRequestWithGetInvokesDataPersistence {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    PCFDataRequest *request = [[PCFDataRequest alloc] initWithMethod:PCF_HTTP_GET object:keyValue fallback:nil force:self.force];
    PCFDataPersistence *persistence = OCMClassMock([PCFDataPersistence class]);
    PCFKeyValueLocalStore *dataStore = [[PCFKeyValueLocalStore alloc] initWithPersistence:persistence];

    OCMStub([persistence getValueForKey:[OCMArg any]]).andReturn(self.value);
    
    PCFDataResponse *response = [dataStore executeRequest:request];
    PCFKeyValue *responseObject = (PCFKeyValue *)response.object;
    
    XCTAssertEqual(responseObject.key, self.key);
    XCTAssertEqual(responseObject.value, self.value);
    XCTAssertEqual(responseObject.collection, self.collection);
    
    OCMVerify([persistence getValueForKey:self.prefixedKey]);
}

- (void)testExecuteRequestWithPutInvokesDataPersistence {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    PCFDataRequest *request = [[PCFDataRequest alloc] initWithMethod:PCF_HTTP_PUT object:keyValue fallback:nil force:self.force];
    PCFDataPersistence *persistence = OCMClassMock([PCFDataPersistence class]);
    PCFKeyValueLocalStore *dataStore = [[PCFKeyValueLocalStore alloc] initWithPersistence:persistence];
    
    OCMStub([persistence putValue:[OCMArg any] forKey:[OCMArg any]]).andReturn(self.value);
    
    PCFDataResponse *response = [dataStore executeRequest:request];
    PCFKeyValue *responseObject = (PCFKeyValue *)response.object;
    
    XCTAssertEqual(responseObject.key, self.key);
    XCTAssertEqual(responseObject.value, self.value);
    XCTAssertEqual(responseObject.collection, self.collection);
    
    OCMVerify([persistence putValue:self.value forKey:self.prefixedKey]);
}

- (void)testExecuteRequestWithDeleteInvokesDataPersistence {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    PCFDataRequest *request = [[PCFDataRequest alloc] initWithMethod:PCF_HTTP_DELETE object:keyValue fallback:nil force:self.force];
    PCFDataPersistence *persistence = OCMClassMock([PCFDataPersistence class]);
    PCFKeyValueLocalStore *dataStore = [[PCFKeyValueLocalStore alloc] initWithPersistence:persistence];

    OCMStub([persistence deleteValueForKey:[OCMArg any]]).andReturn(self.value);
    
    PCFDataResponse *response = [dataStore executeRequest:request];
    PCFKeyValue *responseObject = (PCFKeyValue *)response.object;
    
    XCTAssertEqual(responseObject.key, self.key);
    XCTAssertEqual(responseObject.value, self.value);
    XCTAssertEqual(responseObject.collection, self.collection);
    
    OCMVerify([persistence deleteValueForKey:self.prefixedKey]);
}

- (void)testExecuteRequestWithCompletionHandler {
    PCFDataRequest *request = OCMClassMock([PCFDataRequest class]);
    PCFDataResponse *response = OCMClassMock([PCFDataResponse class]);
    PCFKeyValueLocalStore *dataStore = OCMPartialMock([[PCFKeyValueLocalStore alloc] init]);
    
    OCMStub([dataStore executeRequest:[OCMArg any]]).andReturn(response);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [dataStore executeRequest:request completionBlock:^(PCFDataResponse *resp) {
        XCTAssertEqual(response, resp);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
    
    OCMVerify([dataStore executeRequest:request]);
}

- (NSString *)prefixedKey {
    return [PCFDataPrefix stringByAppendingFormat:@"%@:%@", self.collection, self.key];
}

@end
