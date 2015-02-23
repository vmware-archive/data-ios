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

- (void)executeWithFallback:(PCFPendingRequest *)request;

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

- (PCFDataRequest *)createRequestWithMethod:(int)method {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    return [[PCFDataRequest alloc] initWithMethod:method object:keyValue fallback:nil force:self.force];
}

- (void)testExecuteRequestWithGet {
    PCFPendingRequest *pendingRequest = OCMClassMock([PCFPendingRequest class]);
    PCFKeyValueOfflineStore *offlineStore = OCMClassMock([PCFKeyValueOfflineStore class]);
    PCFRequestCacheExecutor *executor = OCMPartialMock([[PCFRequestCacheExecutor alloc] initWithOfflineStore:offlineStore fallbackStore:nil]);
    
    OCMStub([pendingRequest method]).andReturn(PCF_HTTP_GET);
    OCMStub([offlineStore executeRequest:[OCMArg any]]).andDo(nil);
    
    [executor executeRequest:pendingRequest];
    
    OCMVerify([offlineStore executeRequest:pendingRequest]);
}

- (void)testExecuteRequestWithPut {
    PCFPendingRequest *pendingRequest = OCMClassMock([PCFPendingRequest class]);
    PCFRequestCacheExecutor *executor = OCMPartialMock([[PCFRequestCacheExecutor alloc] initWithOfflineStore:nil fallbackStore:nil]);
    
    OCMStub([pendingRequest method]).andReturn(PCF_HTTP_PUT);
    OCMStub([executor executeWithFallback:[OCMArg any]]).andDo(nil);
    
    [executor executeRequest:pendingRequest];
    
    OCMVerify([executor executeWithFallback:pendingRequest]);
}

- (void)testExecuteRequestWithDelete {
    PCFPendingRequest *pendingRequest = OCMClassMock([PCFPendingRequest class]);
    PCFRequestCacheExecutor *executor = OCMPartialMock([[PCFRequestCacheExecutor alloc] initWithOfflineStore:nil fallbackStore:nil]);
    
    OCMStub([pendingRequest method]).andReturn(PCF_HTTP_DELETE);
    OCMStub([executor executeWithFallback:[OCMArg any]]).andDo(nil);
    
    [executor executeRequest:pendingRequest];
    
    OCMVerify([executor executeWithFallback:pendingRequest]);
}


- (void)testExecutePut {
    PCFPendingRequest *request = OCMClassMock([PCFPendingRequest class]);
    PCFKeyValueOfflineStore *offlineStore = OCMClassMock([PCFKeyValueOfflineStore class]);
    PCFRequestCacheExecutor *executor = [[PCFRequestCacheExecutor alloc] initWithOfflineStore:offlineStore fallbackStore:nil];
    
    [executor executeWithFallback:request];
    
    OCMVerify([offlineStore executeRequest:request]);
}

- (void)testExecutePutWithError {
    PCFPendingRequest *request = OCMClassMock([PCFPendingRequest class]);
    PCFDataResponse *response = OCMClassMock([PCFDataResponse class]);
    PCFKeyValueOfflineStore *offlineStore = OCMClassMock([PCFKeyValueOfflineStore class]);
    PCFKeyValueLocalStore *fallbackStore = OCMClassMock([PCFKeyValueLocalStore class]);
    PCFRequestCacheExecutor *executor = [[PCFRequestCacheExecutor alloc] initWithOfflineStore:offlineStore fallbackStore:fallbackStore];
    
    id pendingRequest = OCMClassMock([PCFPendingRequest class]);
    
    OCMStub([offlineStore executeRequest:[OCMArg any]]).andReturn(response);
    OCMStub([response error]).andReturn([[NSError alloc] init]);
    OCMStub([pendingRequest alloc]).andReturn(pendingRequest);
    OCMStub([pendingRequest initWithRequest:[OCMArg any]]).andReturn(pendingRequest);
    
    [executor executeWithFallback:request];
    
    XCTAssertEqual(request.fallback, [pendingRequest object]);
    
    OCMVerify([offlineStore executeRequest:request]);
    OCMVerify([fallbackStore executeRequest:pendingRequest]);
    
    [pendingRequest stopMocking];
}

@end
