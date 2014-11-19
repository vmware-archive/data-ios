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


//typedef PCFResponse* (^PCFResponseBlock)(PCFResponse *);

@interface PCFDataObjectTests : XCTestCase

@end

@implementation PCFDataObjectTests

- (void)testGetInvokesDataStore {
    NSString *key = [NSUUID UUID].UUIDString;
    NSString *token = [NSUUID UUID].UUIDString;
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:key];
    
    OCMStub([dataStore getWithKey:key accessToken:token]).andReturn(response);
    
    XCTAssertEqual([object getWithAccessToken:token], response);
    
    OCMVerify([dataStore getWithKey:key accessToken:token]);
}

- (void)testAsyncGetInvokesDataStore {
    NSString *key = [NSUUID UUID].UUIDString;
    NSString *token = [NSUUID UUID].UUIDString;
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:key];
    
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    
    [object getWithAccessToken:token completionBlock:block];
    
    OCMVerify([dataStore getWithKey:key accessToken:token completionBlock:block]);
}

- (void)testPutInvokesDataStore {
    NSString *key = [NSUUID UUID].UUIDString;
    NSString *value = [NSUUID UUID].UUIDString;
    NSString *token = [NSUUID UUID].UUIDString;
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:key];
    
    OCMStub([dataStore putWithKey:key value:value accessToken:token]).andReturn(response);
    
    XCTAssertEqual([object putWithAccessToken:token value:value], response);
    
    OCMVerify([dataStore putWithKey:key value:value accessToken:token]);
}

- (void)testAsyncPutInvokesDataStore {
    NSString *key = [NSUUID UUID].UUIDString;
    NSString *value = [NSUUID UUID].UUIDString;
    NSString *token = [NSUUID UUID].UUIDString;
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:key];
    
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    
    [object putWithAccessToken:token value:value completionBlock:block];
    
    OCMVerify([dataStore putWithKey:key value:value accessToken:token completionBlock:block]);
}

- (void)testDeleteInvokesDataStore {
    NSString *key = [NSUUID UUID].UUIDString;
    NSString *token = [NSUUID UUID].UUIDString;
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:key];
    
    OCMStub([dataStore deleteWithKey:key accessToken:token]).andReturn(response);
    
    XCTAssertEqual([object deleteWithAccessToken:token], response);
    
    OCMVerify([dataStore deleteWithKey:key accessToken:token]);
}

- (void)testAsyncDeleteInvokesDataStore {
    NSString *key = [NSUUID UUID].UUIDString;
    NSString *token = [NSUUID UUID].UUIDString;
    PCFLocalStore *dataStore = OCMClassMock([PCFLocalStore class]);
    PCFDataObject *object = [[PCFDataObject alloc] initWithDataStore:dataStore key:key];
    
    void (^block)(PCFResponse *) = ^(PCFResponse *response) {};
    
    [object deleteWithAccessToken:token completionBlock:block];
    
    OCMVerify([dataStore deleteWithKey:key accessToken:token completionBlock:block]);
}

@end
