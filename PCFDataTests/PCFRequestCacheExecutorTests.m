//
//  PCFRequestCacheExecutorTests.m
//  PCFData
//
//  Created by DX122-XL on 2015-01-19.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>
#import "PCFRequestCache.h"
#import "PCFRequestCacheExecutor.h"
#import "PCFPendingRequest.h"

@interface PCFRequestCacheExecutor ()

- (void)executeGet:(PCFPendingRequest *)request;

- (void)executePut:(PCFPendingRequest *)request;

- (void)executeDelete:(PCFPendingRequest *)request;

@end

@interface PCFRequestCacheExecutorTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *token;
@property NSString *collection;
@property int method;
@property BOOL force;

@end

@implementation PCFRequestCacheExecutorTests


- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
    self.collection = [NSUUID UUID].UUIDString;
    self.method = arc4random_uniform(3) + 1;
    self.force = arc4random_uniform(2);
}

- (PCFRequest *)createRequest {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    return [[PCFRequest alloc] initWithObject:keyValue fallback:nil force:self.force];
}

- (void)testExecuteRequestWithGet {
    PCFPendingRequest *request = [[PCFPendingRequest alloc] initWithRequest:self.createRequest method:PCF_HTTP_GET];
    PCFRequestCacheExecutor *executor = OCMPartialMock([[PCFRequestCacheExecutor alloc] initWithOfflineStore:nil fallbackStore:nil]);
    
    OCMStub([executor executeGet:[OCMArg any]]).andDo(nil);
    
    [executor executeRequest:request];
    
    OCMVerify([executor executeGet:request]);
}

- (void)testExecuteRequestWithPut {
    PCFPendingRequest *request = [[PCFPendingRequest alloc] initWithRequest:self.createRequest method:PCF_HTTP_PUT];
    PCFRequestCacheExecutor *executor = OCMPartialMock([[PCFRequestCacheExecutor alloc] initWithOfflineStore:nil fallbackStore:nil]);
    
    OCMStub([executor executePut:[OCMArg any]]).andDo(nil);
    
    [executor executeRequest:request];
    
    OCMVerify([executor executePut:request]);
}

- (void)testExecuteRequestWithDelete {
    PCFPendingRequest *request = [[PCFPendingRequest alloc] initWithRequest:self.createRequest method:PCF_HTTP_DELETE];
    PCFRequestCacheExecutor *executor = OCMPartialMock([[PCFRequestCacheExecutor alloc] initWithOfflineStore:nil fallbackStore:nil]);
    
    OCMStub([executor executeDelete:[OCMArg any]]).andDo(nil);
    
    [executor executeRequest:request];
    
    OCMVerify([executor executeDelete:request]);
}

- (void)testExecuteGet {
    PCFOfflineStore *offlineStore = OCMClassMock([PCFOfflineStore class]);
    PCFRequestCacheExecutor *executor = [[PCFRequestCacheExecutor alloc] initWithOfflineStore:offlineStore fallbackStore:nil];

    PCFPendingRequest *request = [[PCFPendingRequest alloc] initWithRequest:self.createRequest];
    
    [executor executeGet:request];
    
    OCMVerify([offlineStore getWithRequest:request]);
}

- (void)testExecutePut {
    PCFOfflineStore *offlineStore = OCMClassMock([PCFOfflineStore class]);
    PCFKeyValueStore *fallbackStore = OCMStrictClassMock([PCFKeyValueStore class]);
    PCFRequestCacheExecutor *executor = [[PCFRequestCacheExecutor alloc] initWithOfflineStore:offlineStore fallbackStore:fallbackStore];
    
    PCFPendingRequest *request = [[PCFPendingRequest alloc] initWithRequest:self.createRequest];
    
    [executor executePut:request];
    
    OCMVerify([offlineStore putWithRequest:request]);
}

- (void)testExecutePutWithError {
    PCFOfflineStore *offlineStore = OCMClassMock([PCFOfflineStore class]);
    PCFKeyValueStore *fallbackStore = OCMClassMock([PCFKeyValueStore class]);
    PCFRequestCacheExecutor *executor = [[PCFRequestCacheExecutor alloc] initWithOfflineStore:offlineStore fallbackStore:fallbackStore];
    
    PCFPendingRequest *request = [[PCFPendingRequest alloc] initWithRequest:self.createRequest];
    PCFResponse *response = [[PCFResponse alloc] initWithObject:request.object error:[[NSError alloc] init]];
    id pendingRequest = OCMClassMock([PCFPendingRequest class]);
    
    OCMStub([offlineStore putWithRequest:[OCMArg any]]).andReturn(response);
    OCMStub([pendingRequest alloc]).andReturn(pendingRequest);
    OCMStub([pendingRequest initWithRequest:[OCMArg any]]).andReturn(pendingRequest);
    
    [executor executePut:request];
    
    XCTAssertEqual(request.fallback, [pendingRequest object]);
    OCMVerify([offlineStore putWithRequest:request]);
    OCMVerify([fallbackStore putWithRequest:pendingRequest]);
    
    [pendingRequest stopMocking];
}

- (void)testExecuteDelete {
    PCFOfflineStore *offlineStore = OCMClassMock([PCFOfflineStore class]);
    PCFKeyValueStore *fallbackStore = OCMStrictClassMock([PCFKeyValueStore class]);
    PCFRequestCacheExecutor *executor = [[PCFRequestCacheExecutor alloc] initWithOfflineStore:offlineStore fallbackStore:fallbackStore];
    PCFPendingRequest *request = [[PCFPendingRequest alloc] initWithRequest:self.createRequest];
    
    [executor executeDelete:request];
    
    OCMVerify([offlineStore deleteWithRequest:request]);
}

- (void)testExecuteDeleteWithError {
    PCFOfflineStore *offlineStore = OCMClassMock([PCFOfflineStore class]);
    PCFKeyValueStore *fallbackStore = OCMClassMock([PCFKeyValueStore class]);
    PCFRequestCacheExecutor *executor = [[PCFRequestCacheExecutor alloc] initWithOfflineStore:offlineStore fallbackStore:fallbackStore];
    
    PCFPendingRequest *request = [[PCFPendingRequest alloc] initWithRequest:self.createRequest];
    PCFResponse *response = [[PCFResponse alloc] initWithObject:request.object error:[[NSError alloc] init]];
    id pendingRequest = OCMClassMock([PCFPendingRequest class]);
    
    OCMStub([offlineStore deleteWithRequest:[OCMArg any]]).andReturn(response);
    OCMStub([pendingRequest alloc]).andReturn(pendingRequest);
    OCMStub([pendingRequest initWithRequest:[OCMArg any]]).andReturn(pendingRequest);
    
    [executor executeDelete:request];
    
    XCTAssertEqual(request.fallback, [pendingRequest object]);
    OCMVerify([offlineStore deleteWithRequest:request]);
    OCMVerify([fallbackStore putWithRequest:pendingRequest]);
    
    [pendingRequest stopMocking];
}

@end
