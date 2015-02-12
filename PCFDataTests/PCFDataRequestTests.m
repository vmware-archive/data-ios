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

@interface PCFData ()

+ (NSString*)provideTokenWithUserPrompt:(BOOL)prompt;

@end

@interface PCFDataRequestTests : XCTestCase

@property NSString *token;
@property PCFTestMappable *object;
@property PCFTestMappable *fallback;
@property BOOL force;

@end

@implementation PCFDataRequestTests

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
    PCFDataRequest *request = [[PCFDataRequest alloc] initWithObject:self.object fallback:self.fallback force:self.force];
    PCFDataRequest *newRequest = [[PCFDataRequest alloc] initWithRequest:request];
    
    XCTAssertEqual(request.object, newRequest.object);
    XCTAssertEqual(request.force, newRequest.force);
    XCTAssertEqual(request.fallback, newRequest.fallback);
}

- (void)testInitializeWithParameters {
    PCFDataRequest *request = [[PCFDataRequest alloc] initWithObject:self.object fallback:self.fallback force:self.force];
    
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
    
    PCFDataRequest *request = [[PCFDataRequest alloc] initWithDictionary:dict];
    
    XCTAssertEqual(((PCFTestMappable *)self.fallback).value, ((PCFTestMappable *)request.fallback).value);
    XCTAssertEqual(((PCFTestMappable *)self.object).value, ((PCFTestMappable *)request.object).value);
    XCTAssertEqual(self.force, request.force);
}

- (void)testToDictionary {
    PCFDataRequest *request = [[PCFDataRequest alloc] initWithObject:self.object fallback:self.fallback force:self.force];
    NSDictionary *dict = [request toDictionary];
    
    Class klass = NSClassFromString([dict objectForKey:PCFType]);
    PCFTestMappable *requestObject = [[klass alloc] initWithDictionary:[dict objectForKey:PCFObject]];
    PCFTestMappable *requestFallback = [[klass alloc] initWithDictionary:[dict objectForKey:PCFFallback]];
    
    XCTAssertEqual(((PCFTestMappable *)self.object).value, requestObject.value);
    XCTAssertEqual(((PCFTestMappable *)self.fallback).value, requestFallback.value);
    XCTAssertEqual(self.force, [[dict objectForKey:PCFForce] boolValue]);
}

- (void)testAccessToken {
    id pcfData = OCMClassMock([PCFData class]);
    PCFDataRequest *request = [[PCFDataRequest alloc] initWithObject:self.object];
    
    OCMStub([pcfData provideTokenWithUserPrompt:true]).andReturn(self.token);

    NSString *accessToken = [request accessToken];
    
    XCTAssertEqual(self.token, accessToken);
    
    OCMVerify([pcfData provideTokenWithUserPrompt:true]);
    
    [pcfData stopMocking];
}

@end
