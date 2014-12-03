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

@interface PCFRequestCacheTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *token;
@property NSString *collection;
@property NSString *fallback;
@property int method;

@end

@implementation PCFRequestCacheTests

static int const HTTP_GET = 0;
static int const HTTP_PUT = 1;
static int const HTTP_DELETE = 2;


static NSString* const PCFDataRequestCache = @"PCFDataRequestCache";

- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
    self.collection = [NSUUID UUID].UUIDString;
    self.fallback = [NSUUID UUID].UUIDString;
    
    self.method = arc4random() % 3;
}

- (void)testQueueGetWithToken {
    id request = OCMClassMock([PCFPendingRequest class]);
    PCFRequestCache *cache = OCMPartialMock([[PCFRequestCache alloc] init]);
    
    OCMStub([cache queuePending:[OCMArg any]]).andDo(nil);
    OCMStub([request alloc]).andReturn(request);
    OCMStub([request initWithMethod:HTTP_GET accessToken:[OCMArg any] collection:[OCMArg any] key:[OCMArg any] value:[OCMArg any] fallback:[OCMArg any]]).andReturn(request);
    
    [cache queueGetWithToken:self.token collection:self.collection key:self.key];
    
    OCMVerify([cache queuePending:request]);
    OCMVerify([request initWithMethod:HTTP_GET accessToken:self.token collection:self.collection key:self.key value:nil fallback:nil]);
    
    [request stopMocking];
}

- (void)testQueuePutWithToken {
    id request = OCMClassMock([PCFPendingRequest class]);
    PCFRequestCache *cache = OCMPartialMock([[PCFRequestCache alloc] init]);
    
    OCMStub([cache queuePending:[OCMArg any]]).andDo(nil);
    OCMStub([request alloc]).andReturn(request);
    OCMStub([request initWithMethod:HTTP_PUT accessToken:[OCMArg any] collection:[OCMArg any] key:[OCMArg any] value:[OCMArg any] fallback:[OCMArg any]]).andReturn(request);
    
    [cache queuePutWithToken:self.token collection:self.collection key:self.key value:self.value fallback:self.fallback];
    
    OCMVerify([cache queuePending:request]);
    OCMVerify([request initWithMethod:HTTP_PUT accessToken:self.token collection:self.collection key:self.key value:self.value fallback:self.fallback]);
    
    [request stopMocking];
}

- (void)testQueueDeleteWithToken {
    id request = OCMClassMock([PCFPendingRequest class]);
    PCFRequestCache *cache = OCMPartialMock([[PCFRequestCache alloc] init]);
    
    OCMStub([cache queuePending:[OCMArg any]]).andDo(nil);
    OCMStub([request alloc]).andReturn(request);
    OCMStub([request initWithMethod:HTTP_DELETE accessToken:[OCMArg any] collection:[OCMArg any] key:[OCMArg any] value:[OCMArg any] fallback:[OCMArg any]]).andReturn(request);
    
    [cache queueDeleteWithToken:self.token collection:self.collection key:self.key fallback:self.fallback];
    
    OCMVerify([cache queuePending:request]);
    OCMVerify([request initWithMethod:HTTP_DELETE accessToken:self.token collection:self.collection key:self.key value:nil fallback:self.fallback]);
    
    [request stopMocking];
}

- (void)testQueuePending {
    NSUserDefaults *userDefaults = OCMClassMock([NSUserDefaults class]);
    NSMutableArray *array = OCMClassMock([NSMutableArray class]);
    PCFPendingRequest *request = OCMClassMock([PCFPendingRequest class]);
    PCFRequestCache *cache = OCMPartialMock([[PCFRequestCache alloc] initWithDefaults:userDefaults]);
    
    OCMStub([userDefaults objectForKey:[OCMArg any]]).andReturn(array);

    [cache queuePending:request];
    
    OCMVerify([array addObject:request.values]);
    OCMVerify([userDefaults objectForKey:PCFDataRequestCache]);
    OCMVerify([userDefaults setObject:array forKey:PCFDataRequestCache]);
}

@end
