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
#import <PCFData/PCFData.h>


@interface PCFDataObjectTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *token;
@property BOOL force;

@end

@implementation PCFDataObjectTests


- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
    self.force = arc4random_uniform(1);
}


- (void)testGet {
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFDataObject *object = OCMPartialMock([[PCFDataObject alloc] initWithDataStore:nil key:self.key]);
    
    OCMStub([object getWithAccessToken:[OCMArg any] force:false]).andReturn(response);
    
    XCTAssertEqual([object getWithAccessToken:self.token], response);
    
    OCMVerify([object getWithAccessToken:self.token force:false]);
}

- (void)testForceGetInvokesDataStore {
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:self.key];
    
    OCMStub([dataStore getWithKey:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(response);
    
    XCTAssertEqual([object getWithAccessToken:self.token force:self.force], response);
    
    OCMVerify([dataStore getWithKey:self.key accessToken:self.token force:self.force]);
}

- (void)testAsyncGet {
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    PCFDataObject *object = OCMPartialMock([[PCFDataObject alloc] initWithDataStore:nil key:self.key]);
    
    OCMStub([object getWithAccessToken:[OCMArg any] force:false completionBlock:[OCMArg any]]);
    
    [object getWithAccessToken:self.token completionBlock:block];
    
    OCMVerify([object getWithAccessToken:self.token force:false completionBlock:block]);
}

- (void)testForceAsyncGetInvokesDataStore {
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:self.key];
    
    OCMStub([dataStore getWithKey:[OCMArg any] accessToken:[OCMArg any] force:self.force completionBlock:[OCMArg any]]);
    
    [object getWithAccessToken:self.token force:self.force completionBlock:block];
    
    OCMVerify([dataStore getWithKey:self.key accessToken:self.token force:self.force completionBlock:block]);
}

- (void)testPut {
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFDataObject *object = OCMPartialMock([[PCFDataObject alloc] initWithDataStore:nil key:self.key]);
    
    OCMStub([object putWithAccessToken:[OCMArg any] value:[OCMArg any] force:false]).andReturn(response);
    
    XCTAssertEqual([object putWithAccessToken:self.token value:self.value], response);
    
    OCMVerify([object putWithAccessToken:self.token value:self.value force:false]);
}

- (void)testForcePutInvokesDataStore {
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:self.key];
    
    OCMStub([dataStore putWithKey:[OCMArg any] value:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(response);
    
    XCTAssertEqual([object putWithAccessToken:self.token value:self.value force:self.force], response);
    
    OCMVerify([dataStore putWithKey:self.key value:self.value accessToken:self.token force:self.force]);
}

- (void)testAsyncPut {
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    PCFDataObject *object = OCMPartialMock([[PCFDataObject alloc] initWithDataStore:nil key:self.key]);
    
    OCMStub([object putWithAccessToken:[OCMArg any] value:[OCMArg any] force:false completionBlock:[OCMArg any]]);
    
    [object putWithAccessToken:self.token value:self.value completionBlock:block];
    
    OCMVerify([object putWithAccessToken:self.token value:self.value force:false completionBlock:block]);
}

- (void)testForceAsyncPutInvokesDataStore {
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:self.key];
    
    OCMStub([dataStore putWithKey:[OCMArg any] value:[OCMArg any] accessToken:[OCMArg any] force:self.force completionBlock:[OCMArg any]]);
    
    [object putWithAccessToken:self.token value:self.value force:self.force completionBlock:block];
    
    OCMVerify([dataStore putWithKey:self.key value:self.value accessToken:self.token force:self.force completionBlock:block]);
}

- (void)testDelete {
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFDataObject *object = OCMPartialMock([[PCFDataObject alloc] initWithDataStore:nil key:self.key]);
    
    OCMStub([object deleteWithAccessToken:[OCMArg any] force:false]).andReturn(response);
    
    XCTAssertEqual([object deleteWithAccessToken:self.token], response);
    
    OCMVerify([object deleteWithAccessToken:self.token force:false]);
}

- (void)testForceDeleteInvokesDataStore {
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:self.key];
    
    OCMStub([dataStore deleteWithKey:[OCMArg any] accessToken:[OCMArg any] force:self.force]).andReturn(response);
    
    XCTAssertEqual([object deleteWithAccessToken:self.token force:self.force], response);
    
    OCMVerify([dataStore deleteWithKey:self.key accessToken:self.token force:self.force]);
}

- (void)testAsyncDelete {
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    PCFDataObject *object = OCMPartialMock([[PCFDataObject alloc] initWithDataStore:nil key:self.key]);
    
    OCMStub([object deleteWithAccessToken:[OCMArg any] force:false completionBlock:[OCMArg any]]);
    
    [object deleteWithAccessToken:self.token completionBlock:block];
    
    OCMVerify([object deleteWithAccessToken:self.token force:false completionBlock:block]);
}

- (void)testForceAsyncDeleteInvokesDataStore {
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:self.key];
    
    OCMStub([dataStore deleteWithKey:[OCMArg any] accessToken:[OCMArg any] force:self.force completionBlock:[OCMArg any]]);
    
    [object deleteWithAccessToken:self.token force:self.force completionBlock:block];
    
    OCMVerify([dataStore deleteWithKey:self.key accessToken:self.token force:self.force completionBlock:block]);
}

@end
