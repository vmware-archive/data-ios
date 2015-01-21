//
//  PCFKeyValueObjectTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-11-19.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>


@interface PCFKeyValueObject ()

- (PCFRequest *)createRequestWithAccessToken:(NSString *)accessToken value:(NSString *)value force:(BOOL)force;

@end

@interface PCFKeyValueObjectTests : XCTestCase

@property NSString *key;
@property NSString *collection;
@property NSString *value;
@property NSString *token;
@property BOOL force;

@end

@implementation PCFKeyValueObjectTests


- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.collection = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
    self.force = arc4random_uniform(2);
}


- (void)testGet {
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:nil collection:self.collection key:self.key]);
    
    OCMStub([object getWithAccessToken:[OCMArg any] force:false]).andReturn(response);
    
    XCTAssertEqual([object getWithAccessToken:self.token], response);
    
    OCMVerify([object getWithAccessToken:self.token force:false]);
}

- (void)testForceGetInvokesDataStore {
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFRequest *request = OCMClassMock([PCFRequest class]);
    PCFKeyValueStore *dataStore = OCMClassMock([PCFKeyValueStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithAccessToken:[OCMArg any] value:[OCMArg any] force:self.force]).andReturn(request);
    OCMStub([dataStore getWithRequest:[OCMArg any]]).andReturn(response);
    
    XCTAssertEqual([object getWithAccessToken:self.token force:self.force], response);
    
    OCMVerify([dataStore getWithRequest:request]);
}

- (void)testAsyncGet {
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:nil collection:self.collection key:self.key]);
    
    OCMStub([object getWithAccessToken:[OCMArg any] force:false completionBlock:[OCMArg any]]);
    
    [object getWithAccessToken:self.token completionBlock:block];
    
    OCMVerify([object getWithAccessToken:self.token force:false completionBlock:block]);
}

- (void)testForceAsyncGetInvokesDataStore {
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    PCFRequest *request = OCMClassMock([PCFRequest class]);
    PCFKeyValueStore *dataStore = OCMClassMock([PCFKeyValueStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithAccessToken:[OCMArg any] value:[OCMArg any] force:self.force]).andReturn(request);
    OCMStub([dataStore getWithRequest:[OCMArg any] completionBlock:[OCMArg any]]);
    
    [object getWithAccessToken:self.token force:self.force completionBlock:block];
    
    OCMVerify([dataStore getWithRequest:request completionBlock:block]);
}

- (void)testPut {
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:nil collection:self.collection key:self.key]);
    
    OCMStub([object putWithAccessToken:[OCMArg any] value:[OCMArg any] force:false]).andReturn(response);
    
    XCTAssertEqual([object putWithAccessToken:self.token value:self.value], response);
    
    OCMVerify([object putWithAccessToken:self.token value:self.value force:false]);
}

- (void)testForcePutInvokesDataStore {
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFRequest *request = OCMClassMock([PCFRequest class]);
    PCFKeyValueStore *dataStore = OCMClassMock([PCFKeyValueStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithAccessToken:[OCMArg any] value:[OCMArg any] force:self.force]).andReturn(request);
    OCMStub([dataStore putWithRequest:[OCMArg any]]).andReturn(response);
    
    XCTAssertEqual([object putWithAccessToken:self.token value:self.value force:self.force], response);
    
    OCMVerify([dataStore putWithRequest:request]);
}

- (void)testAsyncPut {
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:nil collection:self.collection key:self.key]);
    
    OCMStub([object putWithAccessToken:[OCMArg any] value:[OCMArg any] force:false completionBlock:[OCMArg any]]);
    
    [object putWithAccessToken:self.token value:self.value completionBlock:block];
    
    OCMVerify([object putWithAccessToken:self.token value:self.value force:false completionBlock:block]);
}

- (void)testForceAsyncPutInvokesDataStore {
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    PCFRequest *request = OCMClassMock([PCFRequest class]);
    PCFKeyValueStore *dataStore = OCMClassMock([PCFKeyValueStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithAccessToken:[OCMArg any] value:[OCMArg any] force:self.force]).andReturn(request);
    OCMStub([dataStore putWithRequest:[OCMArg any] completionBlock:[OCMArg any]]);
    
    [object putWithAccessToken:self.token value:self.value force:self.force completionBlock:block];
    
    OCMVerify([dataStore putWithRequest:request completionBlock:block]);
}

- (void)testDelete {
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:nil collection:self.collection key:self.key]);
    
    OCMStub([object deleteWithAccessToken:[OCMArg any] force:false]).andReturn(response);
    
    XCTAssertEqual([object deleteWithAccessToken:self.token], response);
    
    OCMVerify([object deleteWithAccessToken:self.token force:false]);
}

- (void)testForceDeleteInvokesDataStore {
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFRequest *request = OCMClassMock([PCFRequest class]);
    PCFKeyValueStore *dataStore = OCMClassMock([PCFKeyValueStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithAccessToken:[OCMArg any] value:[OCMArg any] force:self.force]).andReturn(request);
    OCMStub([dataStore deleteWithRequest:[OCMArg any]]).andReturn(response);
    
    XCTAssertEqual([object deleteWithAccessToken:self.token force:self.force], response);
    
    OCMVerify([dataStore deleteWithRequest:request]);
}

- (void)testAsyncDelete {
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:nil collection:self.collection key:self.key]);
    
    OCMStub([object deleteWithAccessToken:[OCMArg any] force:false completionBlock:[OCMArg any]]);
    
    [object deleteWithAccessToken:self.token completionBlock:block];
    
    OCMVerify([object deleteWithAccessToken:self.token force:false completionBlock:block]);
}

- (void)testForceAsyncDeleteInvokesDataStore {
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    PCFRequest *request = OCMClassMock([PCFRequest class]);
    PCFKeyValueStore *dataStore = OCMClassMock([PCFKeyValueStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithAccessToken:[OCMArg any] value:[OCMArg any] force:self.force]).andReturn(request);
    OCMStub([dataStore deleteWithRequest:[OCMArg any] completionBlock:[OCMArg any]]);
    
    [object deleteWithAccessToken:self.token force:self.force completionBlock:block];
    
    OCMVerify([dataStore deleteWithRequest:request completionBlock:block]);
}

@end
