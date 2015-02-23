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

- (PCFDataRequest *)createRequestWithMethod:(int)method value:(NSString *)value;

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
    PCFKeyValueLocalStore *dataStore = OCMClassMock([PCFKeyValueLocalStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithMethod:PCF_HTTP_GET value:[OCMArg any]]).andReturn(request);
    OCMStub([dataStore executeRequest:[OCMArg any]]).andReturn(response);
    
    XCTAssertEqual([object get], response);
    
    OCMVerify([dataStore executeRequest:request]);
}

- (void)testAsyncGetInvokesDataStore {
    void (^block)(PCFDataResponse *) = ^(PCFDataResponse *response) {};
    PCFDataRequest *request = OCMClassMock([PCFDataRequest class]);
    PCFKeyValueLocalStore *dataStore = OCMClassMock([PCFKeyValueLocalStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithMethod:PCF_HTTP_GET value:[OCMArg any]]).andReturn(request);
    OCMStub([dataStore executeRequest:[OCMArg any] completionBlock:[OCMArg any]]);
    
    [object getWithCompletionBlock:block];
    
    OCMVerify([dataStore executeRequest:request completionBlock:block]);
}

- (void)testPutInvokesDataStore {
    PCFDataResponse *response = OCMClassMock([PCFDataResponse class]);
    PCFDataRequest *request = OCMClassMock([PCFDataRequest class]);
    PCFKeyValueLocalStore *dataStore = OCMClassMock([PCFKeyValueLocalStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithMethod:PCF_HTTP_PUT value:[OCMArg any]]).andReturn(request);
    OCMStub([dataStore executeRequest:[OCMArg any]]).andReturn(response);
    
    XCTAssertEqual([object putWithValue:self.value], response);
    
    OCMVerify([dataStore executeRequest:request]);
}

- (void)testAsyncPutInvokesDataStore {
    void (^block)(PCFDataResponse *) = ^(PCFDataResponse *response) {};
    PCFDataRequest *request = OCMClassMock([PCFDataRequest class]);
    PCFKeyValueLocalStore *dataStore = OCMClassMock([PCFKeyValueLocalStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithMethod:PCF_HTTP_PUT value:[OCMArg any]]).andReturn(request);
    OCMStub([dataStore executeRequest:[OCMArg any] completionBlock:[OCMArg any]]);
    
    [object putWithValue:self.value completionBlock:block];
    
    OCMVerify([dataStore executeRequest:request completionBlock:block]);
}

- (void)testDeleteInvokesDataStore {
    PCFDataResponse *response = OCMClassMock([PCFDataResponse class]);
    PCFDataRequest *request = OCMClassMock([PCFDataRequest class]);
    PCFKeyValueLocalStore *dataStore = OCMClassMock([PCFKeyValueLocalStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithMethod:PCF_HTTP_DELETE value:[OCMArg any]]).andReturn(request);
    OCMStub([dataStore executeRequest:[OCMArg any]]).andReturn(response);
    
    XCTAssertEqual([object delete], response);
    
    OCMVerify([dataStore executeRequest:request]);
}

- (void)testAsyncDeleteInvokesDataStore {
    void (^block)(PCFDataResponse *) = ^(PCFDataResponse *response) {};
    PCFDataRequest *request = OCMClassMock([PCFDataRequest class]);
    PCFKeyValueLocalStore *dataStore = OCMClassMock([PCFKeyValueLocalStore class]);
    PCFKeyValueObject *object = OCMPartialMock([[PCFKeyValueObject alloc] initWithDataStore:dataStore collection:self.collection key:self.key]);
    
    OCMStub([object createRequestWithMethod:PCF_HTTP_DELETE value:[OCMArg any]]).andReturn(request);
    OCMStub([dataStore executeRequest:[OCMArg any] completionBlock:[OCMArg any]]);
    
    [object deleteWithCompletionBlock:block];
    
    OCMVerify([dataStore executeRequest:request completionBlock:block]);
}

@end
