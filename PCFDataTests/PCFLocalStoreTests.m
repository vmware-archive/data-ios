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

@interface PCFLocalStoreTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *token;
@property NSString *collection;

@end

@implementation PCFLocalStoreTests

static NSString* const PCFDataPrefix = @"PCFData:Data:";

- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
    self.collection = [NSUUID UUID].UUIDString;
}

- (void)testGetInvokesUserDefaults {
    NSUserDefaults *defaults = OCMClassMock([NSUserDefaults class]);
    PCFLocalStore *dataStore = [[PCFLocalStore alloc] initWithCollection:self.collection defaults:defaults];

    OCMStub([defaults objectForKey:[OCMArg any]]).andReturn(self.value);
    
    PCFResponse *response = [dataStore getWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.value, self.value);
    
    OCMVerify([defaults objectForKey:self.prefixedKey]);
}

- (void)testAsyncGetInvokesUserDefaultsAndCompletionBlock {
    NSUserDefaults *defaults = OCMClassMock([NSUserDefaults class]);
    PCFLocalStore *dataStore = [[PCFLocalStore alloc] initWithCollection:self.collection defaults:defaults];
    
    OCMStub([defaults objectForKey:[OCMArg any]]).andReturn(self.value);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [dataStore getWithKey:self.key accessToken:self.token completionBlock:^(PCFResponse *response) {
        XCTAssertEqual(response.key, self.key);
        XCTAssertEqual(response.value, self.value);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OCMVerify([defaults objectForKey:[OCMArg any]]);
}

- (void)testPutInvokesUserDefaults {
    NSUserDefaults *defaults = OCMClassMock([NSUserDefaults class]);
    PCFLocalStore *dataStore = [[PCFLocalStore alloc] initWithCollection:self.collection defaults:defaults];
    PCFResponse *response = [dataStore putWithKey:self.key value:self.value accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.value, self.value);
    
    OCMVerify([defaults setObject:self.value forKey:self.prefixedKey]);
}

- (void)testAsyncPutInvokesUserDefaultsAndCompletionBlock {
    NSUserDefaults *defaults = OCMClassMock([NSUserDefaults class]);
    PCFLocalStore *dataStore = [[PCFLocalStore alloc] initWithCollection:self.collection defaults:defaults];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [dataStore putWithKey:self.key value:self.value accessToken:self.token completionBlock:^(PCFResponse *response) {
        XCTAssertEqual(response.key, self.key);
        XCTAssertEqual(response.value, self.value);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OCMVerify([defaults setObject:self.value forKey:[OCMArg any]]);
}

- (void)testDeleteInvokesUserDefaults {
    NSUserDefaults *defaults = OCMClassMock([NSUserDefaults class]);
    PCFLocalStore *dataStore = [[PCFLocalStore alloc] initWithCollection:self.collection defaults:defaults];
    PCFResponse *response = [dataStore deleteWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertNil(response.value);
    
    OCMVerify([defaults removeObjectForKey:self.prefixedKey]);
}

- (void)testAsyncDeleteInvokesUserDefaultsAndCompletionBlock {
    NSUserDefaults *defaults = OCMClassMock([NSUserDefaults class]);
    PCFLocalStore *dataStore = [[PCFLocalStore alloc] initWithCollection:self.collection defaults:defaults];

    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [dataStore deleteWithKey:self.key accessToken:self.token completionBlock:^(PCFResponse *response) {
        XCTAssertEqual(response.key, self.key);
        XCTAssertNil(response.value);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OCMVerify([defaults removeObjectForKey:[OCMArg any]]);
}


- (NSString *)prefixedKey {
    return [PCFDataPrefix stringByAppendingString:self.key];
}

@end
