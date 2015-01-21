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

@interface PCFKeyValueStoreTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *token;
@property NSString *collection;
@property BOOL force;

@end

@implementation PCFKeyValueStoreTests

static NSString* const PCFDataPrefix = @"PCFData:Data:";

- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
    self.collection = [NSUUID UUID].UUIDString;
    self.force = arc4random_uniform(2);
}

- (void)testGetInvokesDataPersistence {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    PCFRequest *request = [[PCFRequest alloc] initWithAccessToken:self.token object:keyValue force:self.force];
    PCFDataPersistence *persistence = OCMClassMock([PCFDataPersistence class]);
    PCFKeyValueStore *dataStore = [[PCFKeyValueStore alloc] initWithPersistence:persistence];

    OCMStub([persistence getValueForKey:[OCMArg any]]).andReturn(self.value);
    
    PCFResponse *response = [dataStore getWithRequest:request];
    PCFKeyValue *responseObject = (PCFKeyValue *)response.object;
    
    XCTAssertEqual(responseObject.key, self.key);
    XCTAssertEqual(responseObject.value, self.value);
    XCTAssertEqual(responseObject.collection, self.collection);
    
    OCMVerify([persistence getValueForKey:self.prefixedKey]);
}

- (void)testAsyncGetInvokesDataPersistenceAndCompletionBlock {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    PCFRequest *request = [[PCFRequest alloc] initWithAccessToken:self.token object:keyValue force:self.force];
    PCFDataPersistence *persistence = OCMClassMock([PCFDataPersistence class]);
    PCFKeyValueStore *dataStore = [[PCFKeyValueStore alloc] initWithPersistence:persistence];
    
    OCMStub([persistence getValueForKey:[OCMArg any]]).andReturn(self.value);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [dataStore getWithRequest:request completionBlock:^(PCFResponse *response) {
        PCFKeyValue *responseObject = (PCFKeyValue *)response.object;
        
        XCTAssertEqual(responseObject.key, self.key);
        XCTAssertEqual(responseObject.value, self.value);
        XCTAssertEqual(responseObject.collection, self.collection);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
    
    OCMVerify([persistence getValueForKey:[OCMArg any]]);
}

- (void)testPutInvokesDataPersistence {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    PCFRequest *request = [[PCFRequest alloc] initWithAccessToken:self.token object:keyValue force:self.force];
    PCFDataPersistence *persistence = OCMClassMock([PCFDataPersistence class]);
    PCFKeyValueStore *dataStore = [[PCFKeyValueStore alloc] initWithPersistence:persistence];
    
    PCFResponse *response = [dataStore putWithRequest:request];
    PCFKeyValue *responseObject = (PCFKeyValue *)response.object;
    
    XCTAssertEqual(responseObject.key, self.key);
    XCTAssertEqual(responseObject.value, self.value);
    XCTAssertEqual(responseObject.collection, self.collection);
    
    OCMVerify([persistence putValue:self.value forKey:self.prefixedKey]);
}

- (void)testAsyncPutInvokesDataPersistenceAndCompletionBlock {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    PCFRequest *request = [[PCFRequest alloc] initWithAccessToken:self.token object:keyValue force:self.force];
    PCFDataPersistence *persistence = OCMClassMock([PCFDataPersistence class]);
    PCFKeyValueStore *dataStore = [[PCFKeyValueStore alloc] initWithPersistence:persistence];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [dataStore putWithRequest:request completionBlock:^(PCFResponse *response) {
        PCFKeyValue *responseObject = (PCFKeyValue *)response.object;
        
        XCTAssertEqual(responseObject.key, self.key);
        XCTAssertEqual(responseObject.value, self.value);
        XCTAssertEqual(responseObject.collection, self.collection);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
    
    OCMVerify([persistence putValue:self.value forKey:[OCMArg any]]);
}

- (void)testDeleteInvokesDataPersistence {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    PCFRequest *request = [[PCFRequest alloc] initWithAccessToken:self.token object:keyValue force:self.force];
    PCFDataPersistence *persistence = OCMClassMock([PCFDataPersistence class]);
    PCFKeyValueStore *dataStore = [[PCFKeyValueStore alloc] initWithPersistence:persistence];

    PCFResponse *response = [dataStore deleteWithRequest:request];
    PCFKeyValue *responseObject = (PCFKeyValue *)response.object;
    
    XCTAssertEqual(responseObject.key, self.key);
    XCTAssertNil(responseObject.value);
    XCTAssertEqual(responseObject.collection, self.collection);
    
    OCMVerify([persistence deleteValueForKey:self.prefixedKey]);
}

- (void)testAsyncDeleteInvokesDataPersistenceAndCompletionBlock {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    PCFRequest *request = [[PCFRequest alloc] initWithAccessToken:self.token object:keyValue force:self.force];
    PCFDataPersistence *persistence = OCMClassMock([PCFDataPersistence class]);
    PCFKeyValueStore *dataStore = [[PCFKeyValueStore alloc] initWithPersistence:persistence];

    XCTestExpectation *expectation = [self expectationWithDescription:@""]; 
    
    [dataStore deleteWithRequest:request completionBlock:^(PCFResponse *response) {
        PCFKeyValue *responseObject = (PCFKeyValue *)response.object;
        
        XCTAssertEqual(responseObject.key, self.key);
        XCTAssertNil(responseObject.value);
        XCTAssertEqual(responseObject.collection, self.collection);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:100 handler:nil];
    
    OCMVerify([persistence deleteValueForKey:[OCMArg any]]);
}


- (NSString *)prefixedKey {
    return [PCFDataPrefix stringByAppendingFormat:@"%@:%@", self.collection, self.key];
}

@end
