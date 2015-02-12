//
//  PCFDataHandlerTests.m
//  PCFData
//
//  Created by DX122-XL on 2015-02-12.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>
#import "PCFReachability.h"
#import "PCFDataLogger.h"
#import "PCFDataConfig.h"
#import "PCFDataHandler.h"

@interface PCFDataHandler ()

@property PCFReachability *reachability;

@end

@interface PCFDataHandlerTests : XCTestCase

@property NSString *token;
@property BOOL prompt;
@property int logLevel;
@property int networkStatus;

@end

@implementation PCFDataHandlerTests


- (void)setUp {
    [super setUp];
    
    self.token = [NSUUID UUID].UUIDString;
    self.prompt = arc4random_uniform(2);
    self.logLevel = arc4random_uniform(4);
    self.networkStatus = arc4random_uniform(3);
}

- (void)testStartReachability {
    id reachability = OCMClassMock([PCFReachability class]);
    PCFDataHandler *handler = OCMPartialMock([[PCFDataHandler alloc] init]);
    
    OCMStub([reachability reachability]).andReturn(reachability);
    
    [handler startReachability];
    
    OCMVerify([handler registerForReachabilityNotifications]);
    OCMVerify([handler registerDefaultConnectedBlock]);
    OCMVerify([reachability startNotifier]);
    
    [reachability stopMocking];
}

- (void)testStopReachability {
    id reachability = OCMClassMock([PCFReachability class]);
    PCFDataHandler *handler = OCMPartialMock([[PCFDataHandler alloc] init]);
    handler.reachability = reachability;
    
    OCMStub([reachability reachability]).andReturn(reachability);
    
    [handler stopReachability];
    
    OCMVerify([handler unregisterForReachabilityNotifications]);
    OCMVerify([handler unregisterDefaultConnectedBlock]);
    OCMVerify([reachability stopNotifier]);
    
    [reachability stopMocking];
}

- (void)testReachabilityNotification {
    id reachability = OCMClassMock([PCFReachability class]);
    PCFDataHandler *handler = OCMPartialMock([[PCFDataHandler alloc] init]);
    
    OCMStub([reachability reachability]).andReturn(reachability);
    OCMStub([reachability currentReachabilityStatus]).andReturn(NotReachable);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    OCMStub([handler notifyNetworkStatusChanged:false]).andDo(^(NSInvocation *invocation) {
        [expectation fulfill];
    });
    
    [handler registerForReachabilityNotifications];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPCFReachabilityChangedNotification object:nil];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    [reachability stopMocking];
}

- (void)testRegisterTokenProviderBlock {
    id pcfConfig = OCMClassMock([PCFDataConfig class]);
    id reachability = OCMClassMock([PCFReachability class]);
    PCFDataHandler *handler = OCMPartialMock([[PCFDataHandler alloc] init]);
    
    OCMStub([reachability reachability]).andReturn(reachability);
    OCMStub([pcfConfig sharedInstance]).andReturn(pcfConfig);
    OCMStub([pcfConfig serviceUrl]).andReturn(@"");
    
    [handler registerTokenProviderBlock:^(BOOL prompt) {
        return self.token;
    }];
    
    XCTAssertEqual(self.token, [handler provideTokenWithUserPrompt:self.prompt]);
    
    OCMVerify([handler startReachability]);
    
    [pcfConfig stopMocking];
    [reachability stopMocking];
}

- (void)testRegisterNetworkObserverBlock {
    id pcfConfig = OCMClassMock([PCFDataConfig class]);
    id reachability = OCMClassMock([PCFReachability class]);
    PCFDataHandler *handler = OCMPartialMock([[PCFDataHandler alloc] init]);
    
    OCMStub([reachability reachability]).andReturn(reachability);
    OCMStub([pcfConfig sharedInstance]).andReturn(pcfConfig);
    OCMStub([pcfConfig serviceUrl]).andReturn(@"");
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [handler registerNetworkObserverBlock:^(BOOL connected) {
        [expectation fulfill];
    }];
    
    [handler notifyNetworkStatusChanged:true];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OCMVerify([handler startReachability]);
    
    [pcfConfig stopMocking];
    [reachability stopMocking];
}

@end