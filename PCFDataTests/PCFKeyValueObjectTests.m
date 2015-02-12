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

- (PCFDataRequest *)createRequestWithValue:(NSString *)value;

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

- (void)testForceGetInvokesDataStore {
    PCFDataResponse *response = OCMClassMock([PCFDataResponse class]);
    PCFDataRequest *request = OCMClassMock([PCFDataRequest class]);
    PCFKeyValueStore *dataStore = OCMClassMock([PCFKeyValueStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithValue:[OCMArg any]]).andReturn(request);
    OCMStub([dataStore getWithRequest:[OCMArg any]]).andReturn(response);
    
    XCTAssertEqual([object get], response);
    
    OCMVerify([dataStore getWithRequest:request]);
}

- (void)testAsyncGetInvokesDataStore {
    void (^block)(PCFDataResponse *) = ^(PCFDataResponse *response) {};
    PCFDataRequest *request = OCMClassMock([PCFDataRequest class]);
    PCFKeyValueStore *dataStore = OCMClassMock([PCFKeyValueStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithValue:[OCMArg any]]).andReturn(request);
    OCMStub([dataStore getWithRequest:[OCMArg any] completionBlock:[OCMArg any]]);
    
    [object getWithCompletionBlock:block];
    
    OCMVerify([dataStore getWithRequest:request completionBlock:block]);
}

- (void)testPutInvokesDataStore {
    PCFDataResponse *response = OCMClassMock([PCFDataResponse class]);
    PCFDataRequest *request = OCMClassMock([PCFDataRequest class]);
    PCFKeyValueStore *dataStore = OCMClassMock([PCFKeyValueStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithValue:[OCMArg any]]).andReturn(request);
    OCMStub([dataStore putWithRequest:[OCMArg any]]).andReturn(response);
    
    XCTAssertEqual([object putWithValue:self.value], response);
    
    OCMVerify([dataStore putWithRequest:request]);
}

- (void)testAsyncPutInvokesDataStore {
    void (^block)(PCFDataResponse *) = ^(PCFDataResponse *response) {};
    PCFDataRequest *request = OCMClassMock([PCFDataRequest class]);
    PCFKeyValueStore *dataStore = OCMClassMock([PCFKeyValueStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithValue:[OCMArg any]]).andReturn(request);
    OCMStub([dataStore putWithRequest:[OCMArg any] completionBlock:[OCMArg any]]);
    
    [object putWithValue:self.value completionBlock:block];
    
    OCMVerify([dataStore putWithRequest:request completionBlock:block]);
}

- (void)testDeleteInvokesDataStore {
    PCFDataResponse *response = OCMClassMock([PCFDataResponse class]);
    PCFDataRequest *request = OCMClassMock([PCFDataRequest class]);
    PCFKeyValueStore *dataStore = OCMClassMock([PCFKeyValueStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithValue:[OCMArg any]]).andReturn(request);
    OCMStub([dataStore deleteWithRequest:[OCMArg any]]).andReturn(response);
    
    XCTAssertEqual([object delete], response);
    
    OCMVerify([dataStore deleteWithRequest:request]);
}

- (void)testAsyncDeleteInvokesDataStore {
    void (^block)(PCFDataResponse *) = ^(PCFDataResponse *response) {};
    PCFDataRequest *request = OCMClassMock([PCFDataRequest class]);
    PCFKeyValueStore *dataStore = OCMClassMock([PCFKeyValueStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithValue:[OCMArg any]]).andReturn(request);
    OCMStub([dataStore deleteWithRequest:[OCMArg any] completionBlock:[OCMArg any]]);
    
    [object deleteWithCompletionBlock:block];
    
    OCMVerify([dataStore deleteWithRequest:request completionBlock:block]);
}

@end
