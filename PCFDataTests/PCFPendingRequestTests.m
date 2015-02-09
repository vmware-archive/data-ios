//
//  PCFPendingRequestTests.m
//  PCFData
//
//  Created by DX122-XL on 2015-01-20.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>
#import "PCFPendingRequest.h"
#import "PCFTestMappable.h"


@interface PCFData ()

+ (NSString*)provideToken;

@end

@interface PCFPendingRequestTests : XCTestCase

@property NSString *token;
@property id<PCFMappable> object;
@property id<PCFMappable> fallback;
@property int method;
@property BOOL force;

@end

@implementation PCFPendingRequestTests

static NSString* const PCFMethod = @"method";
static NSString* const PCFObject = @"object";
static NSString* const PCFFallback = @"fallback";
static NSString* const PCFForce = @"force";
static NSString* const PCFType = @"type";

- (void)setUp {
    [super setUp];
    
    self.token = [NSUUID UUID].UUIDString;
    self.object = [[PCFTestMappable alloc] init];
    self.fallback = [[PCFTestMappable alloc] init];
    self.method = arc4random_uniform(3) + 1;
    self.force = arc4random_uniform(2);
}


- (void)testInitWithRequestAndMethod {
    PCFRequest *request = [[PCFRequest alloc] initWithObject:self.object fallback:self.fallback force:self.force];
    PCFPendingRequest *pendingRequest = [[PCFPendingRequest alloc] initWithRequest:request method:self.method];
    
    XCTAssertEqual(self.method, pendingRequest.method);
    XCTAssertEqual(self.fallback, pendingRequest.fallback);
    XCTAssertEqual(self.object, pendingRequest.object);
    XCTAssertEqual(self.force, pendingRequest.force);
}

- (void)testInitWithDictionary {
    NSDictionary *dict = @{
       PCFMethod: [NSString stringWithFormat:@"%d", self.method],
       PCFType: NSStringFromClass([self.object class]),
       PCFObject: [self.object toDictionary],
       PCFFallback: [self.fallback toDictionary],
       PCFForce: [NSString stringWithFormat:@"%d", self.force]
    };
   
    PCFPendingRequest *pendingRequest = [[PCFPendingRequest alloc] initWithDictionary:dict];
    XCTAssertEqual(self.method, pendingRequest.method);
    XCTAssertEqual(((PCFTestMappable *)self.fallback).value, ((PCFTestMappable *)pendingRequest.fallback).value);
    XCTAssertEqual(((PCFTestMappable *)self.object).value, ((PCFTestMappable *)pendingRequest.object).value);
    XCTAssertEqual(self.force, pendingRequest.force);
}

- (void)testToDictionary {
    PCFRequest *request = [[PCFRequest alloc] initWithObject:self.object fallback:self.fallback force:self.force];
    PCFPendingRequest *pendingRequest = [[PCFPendingRequest alloc] initWithRequest:request method:self.method];
    
    NSDictionary *dict = [pendingRequest toDictionary];
    
    Class klass = NSClassFromString([dict objectForKey:PCFType]);
    PCFTestMappable *requestObject = [[klass alloc] initWithDictionary:[dict objectForKey:PCFObject]];
    PCFTestMappable *requestFallback = [[klass alloc] initWithDictionary:[dict objectForKey:PCFFallback]];
    
    XCTAssertEqual(self.method, [[dict objectForKey:PCFMethod] intValue]);
    XCTAssertEqual(self.force, [[dict objectForKey:PCFForce] boolValue]);
    XCTAssertEqual(((PCFTestMappable *)self.object).value, requestObject.value);
    XCTAssertEqual(((PCFTestMappable *)self.fallback).value, requestFallback.value);
}

- (void)testAccessToken {
    id pcfData = OCMClassMock([PCFData class]);
    PCFRequest *request = [[PCFRequest alloc] initWithObject:self.object];
    PCFPendingRequest *pending = [[PCFPendingRequest alloc] initWithRequest:request];
    
    OCMStub([pcfData provideToken]).andReturn(self.token);
    
    NSString *accessToken = [pending accessToken];
    
    XCTAssertEqual(self.token, accessToken);
    
    OCMVerify([pcfData provideToken]);
    
    [pcfData stopMocking];
}

@end
