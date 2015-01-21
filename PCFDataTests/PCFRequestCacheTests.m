//
//  PCFRequestCacheTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-11-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>
#import "PCFRequestCache.h"
#import "PCFRequestCacheExecutor.h"
#import "PCFRequestCacheQueue.h"
#import "PCFPendingRequest.h"

@interface PCFRequestCacheTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *token;
@property NSString *collection;
@property NSString *fallback;
@property int method;
@property BOOL force;

@end

@implementation PCFRequestCacheTests

- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
    self.collection = [NSUUID UUID].UUIDString;
    self.fallback = [NSUUID UUID].UUIDString;
    self.method = arc4random_uniform(3) + 1;
    self.force = arc4random_uniform(2);
}

- (PCFRequest *)createRequest {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    return [[PCFRequest alloc] initWithAccessToken:self.token object:keyValue force:self.force];
}

- (void)testQueueGet {
    PCFRequest *request = [self createRequest];
    id pending = OCMClassMock([PCFPendingRequest class]);
    PCFRequestCacheQueue *queue = OCMClassMock([PCFRequestCacheQueue class]);
    
    OCMStub([pending alloc]).andReturn(pending);
    OCMStub([pending initWithRequest:[OCMArg any] method:PCF_HTTP_GET]).andReturn(pending);
    
    PCFRequestCache *cache = [[PCFRequestCache alloc] initWithRequestQueue:queue executor:nil];
    
    [cache queueGetWithRequest:request];
    
    OCMVerify([pending initWithRequest:request method:PCF_HTTP_GET]);
    OCMVerify([queue addRequest:pending]);
    
    [pending stopMocking];
}

- (void)testQueuePut {
    PCFRequest *request = [self createRequest];
    id pending = OCMClassMock([PCFPendingRequest class]);
    PCFRequestCacheQueue *queue = OCMClassMock([PCFRequestCacheQueue class]);
    
    OCMStub([pending alloc]).andReturn(pending);
    OCMStub([pending initWithRequest:[OCMArg any] method:PCF_HTTP_PUT]).andReturn(pending);
    
    PCFRequestCache *cache = [[PCFRequestCache alloc] initWithRequestQueue:queue executor:nil];
    
    [cache queuePutWithRequest:request];
    
    OCMVerify([pending initWithRequest:request method:PCF_HTTP_PUT]);
    OCMVerify([queue addRequest:pending]);
    
    [pending stopMocking];
}

- (void)testQueueDelete {
    PCFRequest *request = [self createRequest];
    id pending = OCMClassMock([PCFPendingRequest class]);
    PCFRequestCacheQueue *queue = OCMClassMock([PCFRequestCacheQueue class]);
    
    OCMStub([pending alloc]).andReturn(pending);
    OCMStub([pending initWithRequest:[OCMArg any] method:PCF_HTTP_DELETE]).andReturn(pending);
    
    PCFRequestCache *cache = [[PCFRequestCache alloc] initWithRequestQueue:queue executor:nil];
    
    [cache queueDeleteWithRequest:request];
    
    OCMVerify([pending initWithRequest:request method:PCF_HTTP_DELETE]);
    OCMVerify([queue addRequest:pending]);
    
    [pending stopMocking];
}

- (void)testExecutePendingRequestsWithTokenAndHandlerNewData {
    NSArray *requestArray = OCMClassMock([NSArray class]);
    OCMStub([requestArray count]).andReturn(1);
    
    PCFRequestCacheQueue *queue = OCMClassMock([PCFRequestCacheQueue class]);
    OCMStub([queue empty]).andReturn(requestArray);
    
    PCFRequestCache *cache = [[PCFRequestCache alloc] initWithRequestQueue:queue executor:nil];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [cache executePendingRequestsWithToken:self.token completionHandler:^(UIBackgroundFetchResult arg){
        XCTAssertEqual(arg, UIBackgroundFetchResultNewData);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testExecutePendingRequestsWithTokenAndHandlerNoData {
    NSArray *requestArray = OCMClassMock([NSArray class]);
    OCMStub([requestArray count]).andReturn(0);
    
    PCFRequestCacheQueue *queue = OCMClassMock([PCFRequestCacheQueue class]);
    OCMStub([queue empty]).andReturn(requestArray);
    
    PCFRequestCache *cache = [[PCFRequestCache alloc] initWithRequestQueue:queue executor:nil];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [cache executePendingRequestsWithToken:self.token completionHandler:^(UIBackgroundFetchResult arg){
        XCTAssertEqual(arg, UIBackgroundFetchResultNoData);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testExecutePendingRequests {
    NSDictionary *dict = [[NSDictionary alloc] init];
    NSArray *requestArray = [[NSArray alloc] initWithObjects:dict, nil];
    OCMStub([requestArray count]).andReturn(1);
    
    PCFRequestCacheExecutor *executor = OCMClassMock([PCFRequestCacheExecutor class]);
    id pending = OCMClassMock([PCFPendingRequest class]);
    
    OCMStub([pending alloc]).andReturn(pending);
    OCMStub([pending initWithDictionary:[OCMArg any]]).andReturn(pending);
    
    PCFRequestCache *cache = [[PCFRequestCache alloc] initWithRequestQueue:nil executor:executor];
    
    [cache executePendingRequests:requestArray];
    
    OCMVerify([pending initWithDictionary:dict]);
    OCMVerify([executor executeRequest:pending]);
    
    [pending stopMocking];
}

@end
