//
//  PCFDataObjectTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-11-19.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "PCFLocalStore.h"
#import "PCFDataObject.h"
#import "PCFResponse.h"


@interface PCFDataObjectTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *token;

@end

@implementation PCFDataObjectTests


- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
}


- (void)testGetInvokesDataStore {
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:self.key];
    
    OCMStub([dataStore getWithKey:self.key accessToken:self.token]).andReturn(response);
    
    XCTAssertEqual([object getWithAccessToken:self.token], response);
    
    OCMVerify([dataStore getWithKey:self.key accessToken:self.token]);
}

- (void)testAsyncGetInvokesDataStore {
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:self.key];
    
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    
    [object getWithAccessToken:self.token completionBlock:block];
    
    OCMVerify([dataStore getWithKey:self.key accessToken:self.token completionBlock:block]);
}

- (void)testPutInvokesDataStore {
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:self.key];
    
    OCMStub([dataStore putWithKey:self.key value:self.value accessToken:self.token]).andReturn(response);
    
    XCTAssertEqual([object putWithAccessToken:self.token value:self.value], response);
    
    OCMVerify([dataStore putWithKey:self.key value:self.value accessToken:self.token]);
}

- (void)testAsyncPutInvokesDataStore {
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:self.key];
    
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    
    [object putWithAccessToken:self.token value:self.value completionBlock:block];
    
    OCMVerify([dataStore putWithKey:self.key value:self.value accessToken:self.token completionBlock:block]);
}

- (void)testDeleteInvokesDataStore {
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:self.key];
    
    OCMStub([dataStore deleteWithKey:self.key accessToken:self.token]).andReturn(response);
    
    XCTAssertEqual([object deleteWithAccessToken:self.token], response);
    
    OCMVerify([dataStore deleteWithKey:self.key accessToken:self.token]);
}

- (void)testAsyncDeleteInvokesDataStore {
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:self.key];
    
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    
    [object deleteWithAccessToken:self.token completionBlock:block];
    
    OCMVerify([dataStore deleteWithKey:self.key accessToken:self.token completionBlock:block]);
}

@end
