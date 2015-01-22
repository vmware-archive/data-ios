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

@interface PCFDataTests : XCTestCase

@property NSString *token;
@property int logLevel;

@end

@implementation PCFDataTests

- (void)setUp {
    [super setUp];

    self.token = [NSUUID UUID].UUIDString;
    self.logLevel = arc4random_uniform(4);
}

- (void)testStartSyncingInvokesSyncBlockWhenReachable {
    id reachability = OCMClassMock([PCFReachability class]);
    
    OCMStub([reachability reachability]).andReturn(reachability);
    OCMStub([reachability currentReachabilityStatus]).andReturn(ReachableViaWiFi);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [PCFData syncWhenNetworkAvailableWithBlock:^{
        [expectation fulfill];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPCFReachabilityChangedNotification object:nil];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    [reachability stopMocking];
}

- (void)testStartSyncingDoesNotInvokeSyncBlockWhenNotReachable {
    id reachability = OCMClassMock([PCFReachability class]);
    
    OCMStub([reachability reachability]).andReturn(reachability);
    OCMStub([reachability currentReachabilityStatus]).andReturn(NotReachable);
    
    [PCFData syncWhenNetworkAvailableWithBlock:^{
        XCTFail(@"Should not call block");
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPCFReachabilityChangedNotification object:nil];
    
    [reachability stopMocking];
}

- (void)testStartSyncingInvokesReachability {
    id reachability = OCMClassMock([PCFReachability class]);
    id notificationCenter = OCMClassMock([NSNotificationCenter class]);
    
    OCMStub([reachability reachability]).andReturn(reachability);
    OCMStub([notificationCenter defaultCenter]).andReturn(notificationCenter);
    
    [PCFData syncWhenNetworkAvailableWithBlock:nil];
    
    OCMVerify([reachability startNotifier]);
    OCMVerify([notificationCenter addObserverForName:kPCFReachabilityChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:[OCMArg any]]);
    
    [reachability stopMocking];
    [notificationCenter stopMocking];
}

//- (void)testSyncWithAccessTokenInvokesRequestCache {
//    id requestCache = OCMClassMock([PCFRequestCache class]);
//    
//    OCMStub([requestCache sharedInstance]).andReturn(requestCache);
//    
//    [PCFData syncWithAccessToken:self.token];
//    
//    OCMVerify([requestCache executePendingRequestsWithToken:self.token]);
//    
//    [requestCache stopMocking];
//}
//
//- (void)testSyncWithAccessTokenAndCompletionBlockInvokesRequestCache {
//    id requestCache = OCMClassMock([PCFRequestCache class]);
//    void (^block)(UIBackgroundFetchResult) = ^(UIBackgroundFetchResult result) {};
//    
//    OCMStub([requestCache sharedInstance]).andReturn(requestCache);
//    
//    [PCFData syncWithAccessToken:self.token completionHandler:block];
//    
//    OCMVerify([requestCache executePendingRequestsWithToken:self.token completionHandler:block]);
//    
//    [requestCache stopMocking];
//}

- (void)testLogLevelInvokesPCFLogger {
    id logger = OCMClassMock([PCFDataLogger class]);
    
    OCMStub([logger sharedInstance]).andReturn(logger);
    
    [PCFData logLevel:self.logLevel];
    
    OCMVerify([logger setLevel:self.logLevel]);
    
    [logger stopMocking];
}

@end
