//
//  PCFRequestTests.m
//  PCFData
//
//  Created by DX122-XL on 2015-01-14.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>
#import "PCFTestMappable.h"

@interface PCFRequestTests : XCTestCase

@property NSString *token;
@property PCFTestMappable *object;
@property PCFTestMappable *fallback;
@property BOOL force;

@end

@implementation PCFRequestTests

static NSString* const PCFAccessToken = @"accessToken";
static NSString* const PCFMethod = @"method";
static NSString* const PCFType = @"type";
static NSString* const PCFObject = @"object";
static NSString* const PCFFallback = @"fallback";
static NSString* const PCFForce = @"force";

- (void)setUp {
    [super setUp];
    
    self.token = [NSUUID UUID].UUIDString;
    self.object = [[PCFTestMappable alloc] init];;
    self.fallback = [[PCFTestMappable alloc] init];;
    self.force = arc4random_uniform(2);
}

- (void)testInitializeWithRequest {
    PCFRequest *request = [[PCFRequest alloc] initWithAccessToken:self.token object:self.object force:self.force];
    request.fallback = self.fallback;
    
    PCFRequest *newRequest = [[PCFRequest alloc] initWithRequest:request];
    
    XCTAssertEqual(request.accessToken, newRequest.accessToken);
    XCTAssertEqual(request.object, newRequest.object);
    XCTAssertEqual(request.force, newRequest.force);
    XCTAssertEqual(request.fallback, newRequest.fallback);
}

- (void)testInitializeWithParameters {
    PCFRequest *request = [[PCFRequest alloc] initWithAccessToken:self.token object:self.object force:self.force];
    request.fallback = self.fallback;
    
    XCTAssertEqual(self.token, request.accessToken);
    XCTAssertEqual(self.object, request.object);
    XCTAssertEqual(self.force, request.force);
    XCTAssertEqual(self.fallback, request.fallback);
}

- (void)testInitWithDictionary {
    NSDictionary *dict = @{
       PCFAccessToken: self.token,
       PCFObject: [self.object toDictionary],
       PCFFallback: [self.fallback toDictionary],
       PCFForce: [NSString stringWithFormat:@"%d", self.force],
       PCFType: NSStringFromClass([self.object class])
    };
    
    PCFRequest *request = [[PCFRequest alloc] initWithDictionary:dict];
    
    XCTAssertEqual(self.token, request.accessToken);
    XCTAssertEqual(((PCFTestMappable *)self.fallback).value, ((PCFTestMappable *)request.fallback).value);
    XCTAssertEqual(((PCFTestMappable *)self.object).value, ((PCFTestMappable *)request.object).value);
    XCTAssertEqual(self.force, request.force);
}

- (void)testToDictionary {
    PCFRequest *request = [[PCFRequest alloc] initWithAccessToken:self.token object:self.object force:self.force];
    request.fallback = self.fallback;
    
    NSDictionary *dict = [request toDictionary];
    
    Class klass = NSClassFromString([dict objectForKey:PCFType]);
    PCFTestMappable *requestObject = [[klass alloc] initWithDictionary:[dict objectForKey:PCFObject]];
    PCFTestMappable *requestFallback = [[klass alloc] initWithDictionary:[dict objectForKey:PCFFallback]];
    
    XCTAssertEqual(self.token, [dict objectForKey:PCFAccessToken]);
    XCTAssertEqual(((PCFTestMappable *)self.object).value, requestObject.value);
    XCTAssertEqual(((PCFTestMappable *)self.fallback).value, requestFallback.value);
    XCTAssertEqual(self.force, [[dict objectForKey:PCFForce] boolValue]);
}

@end
