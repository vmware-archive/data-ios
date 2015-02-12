//
//  PCFDataTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-11-19.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>
#import "PCFRequestCache.h"
#import "PCFReachability.h"
#import "PCFDataLogger.h"
#import "PCFDataConfig.h"

@interface PCFData ()

+ (void)notifyNetworkStatusChanged:(BOOL)connected;

+ (void)registerForReachabilityNotifications;

+ (void)unregisterForReachabilityNotifications;

+ (void)registerDefaultConnectedBlock;

+ (void)unregisterDefaultConnectedBlock;

+ (void)startReachability;

+ (void)stopReachability;

+ (NSString*)provideTokenWithUserPrompt:(BOOL)prompt;

@end

@interface PCFDataTests : XCTestCase

@property NSString *token;
@property int logLevel;
@property int networkStatus;

@end

@implementation PCFDataTests

- (void)setUp {
    [super setUp];

    self.token = [NSUUID UUID].UUIDString;
    self.logLevel = arc4random_uniform(4);
    self.networkStatus = arc4random_uniform(3);
    
    [PCFData stopReachability];
}

- (void)testStartReachability {
    id pcfData = OCMPartialMock([[PCFData alloc] init]);
    id reachability = OCMClassMock([PCFReachability class]);
    
    OCMStub([reachability reachability]).andReturn(reachability);
    
    [PCFData startReachability];
    
    OCMVerify([pcfData registerForReachabilityNotifications]);
    OCMVerify([pcfData registerDefaultConnectedBlock]);
    OCMVerify([reachability startNotifier]);
    
    [pcfData stopMocking];
    [reachability stopMocking];
}

- (void)testStopReachability {
    id pcfData = OCMPartialMock([[PCFData alloc] init]);
    id reachability = OCMClassMock([PCFReachability class]);
    
    OCMStub([reachability reachability]).andReturn(reachability);
    
    [PCFData startReachability];
    [PCFData stopReachability];
    
    OCMVerify([pcfData unregisterForReachabilityNotifications]);
    OCMVerify([pcfData unregisterDefaultConnectedBlock]);
    OCMVerify([reachability stopNotifier]);
    
    [pcfData stopMocking];
    [reachability stopMocking];
}

- (void)testReachabilityNotification {
    id pcfData = OCMClassMock([PCFData class]);
    id reachability = OCMClassMock([PCFReachability class]);
    
    OCMStub([reachability reachability]).andReturn(reachability);
    OCMStub([reachability currentReachabilityStatus]).andReturn(NotReachable);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];

    OCMStub([pcfData notifyNetworkStatusChanged:false]).andDo(^(NSInvocation *invocation) {
        [expectation fulfill];
    });
    
    [PCFData registerForReachabilityNotifications];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPCFReachabilityChangedNotification object:nil];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    [reachability stopMocking];
    [pcfData stopMocking];
}

- (void)testRegisterTokenProviderBlock {
    id pcfConfig = OCMClassMock([PCFDataConfig class]);
    id pcfData = OCMClassMock([PCFData class]);
    id reachability = OCMClassMock([PCFReachability class]);
    
    OCMStub([reachability reachability]).andReturn(reachability);
    OCMStub([pcfConfig sharedInstance]).andReturn(pcfConfig);
    OCMStub([pcfConfig serviceUrl]).andReturn(@"");
    
    NSString *token = [NSUUID UUID].UUIDString;
    
    [PCFData registerTokenProviderBlock:^(BOOL prompt) {
        return token;
    }];
    
    BOOL prompt = arc4random_uniform(2);
    XCTAssertEqual(token, [PCFData provideTokenWithUserPrompt:prompt]);
    
    OCMVerify([pcfData startReachability]);
    
    [pcfData stopMocking];
    [pcfConfig stopMocking];
    [reachability stopMocking];
}

- (void)testRegisterNetworkObserverBlock {
    id pcfConfig = OCMClassMock([PCFDataConfig class]);
    id pcfData = OCMClassMock([PCFData class]);
    id reachability = OCMClassMock([PCFReachability class]);
    
    OCMStub([reachability reachability]).andReturn(reachability);
    OCMStub([pcfConfig sharedInstance]).andReturn(pcfConfig);
    OCMStub([pcfConfig serviceUrl]).andReturn(@"");
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [PCFData registerNetworkObserverBlock:^(BOOL connected) {
        [expectation fulfill];
    }];
    
    [PCFData notifyNetworkStatusChanged:true];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OCMVerify([pcfData startReachability]);
    
    [pcfData stopMocking];
    [pcfConfig stopMocking];
    [reachability stopMocking];
}

- (void)testPerformSyncInvokesRequestCache {
    id requestCache = OCMClassMock([PCFRequestCache class]);
    
    OCMStub([[requestCache alloc] init]).andReturn(requestCache);
    
    [PCFData performSync];
    
    OCMVerify([requestCache executePendingRequests]);
    
    [requestCache stopMocking];
}

- (void)testPerformSyncWithCompletionHandlerInvokesRequestCache {
    id requestCache = OCMClassMock([PCFRequestCache class]);
    void (^block)(UIBackgroundFetchResult) = ^(UIBackgroundFetchResult result) {};
    
    OCMStub([[requestCache alloc] init]).andReturn(requestCache);
    
    [PCFData performSyncWithCompletionHandler:block];
    
    OCMVerify([requestCache executePendingRequestsWithCompletionHandler:block]);
    
    [requestCache stopMocking];
}

- (void)testLogLevelInvokesPCFLogger {
    id logger = OCMClassMock([PCFDataLogger class]);
    
    OCMStub([logger sharedInstance]).andReturn(logger);
    
    [PCFData logLevel:self.logLevel];
    
    OCMVerify([logger setLevel:self.logLevel]);
    
    [logger stopMocking];
}

@end
