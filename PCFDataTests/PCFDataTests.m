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
#import "PCFData.h"
#import "PCFRequestCache.h"
#import "PCFDataLogger.h"
#import "PCFDataHandler.h"

@interface PCFData ()

+ (PCFDataHandler *)handler;

+ (NSString *)provideTokenWithUserPrompt:(BOOL)prompt;

@end

@interface PCFDataTests : XCTestCase

@property NSString *token;
@property BOOL prompt;
@property int logLevel;

@end

@implementation PCFDataTests

- (void)setUp {
    [super setUp];

    self.token = [NSUUID UUID].UUIDString;
    self.prompt = arc4random_uniform(2);
    self.logLevel = arc4random_uniform(4);
}

- (void)testRegisterTokenProviderWithUserPrompt {
    id pcfData = OCMClassMock([PCFData class]);
    PCFDataHandler *handler = OCMClassMock([PCFDataHandler class]);
    PCFTokenBlock block = ^(BOOL promptUser) { return @""; };
    
    OCMStub([pcfData handler]).andReturn(handler);
    
    [PCFData registerTokenProviderBlock:block];
    
    OCMVerify([handler registerTokenProviderBlock:block]);
    
    [pcfData stopMocking];
}

- (void)testProvideTokenWithUserPrompt {
    id pcfData = OCMClassMock([PCFData class]);
    PCFDataHandler *handler = OCMClassMock([PCFDataHandler class]);
    
    OCMStub([pcfData handler]).andReturn(handler);
    OCMStub([handler provideTokenWithUserPrompt:self.prompt]).andReturn(self.token);
    
    XCTAssertEqual(self.token, [PCFData provideTokenWithUserPrompt:self.prompt]);
    
    OCMVerify([handler provideTokenWithUserPrompt:self.prompt]);
    
    [pcfData stopMocking];
}

- (void)testRegisterNetworkObserver {
    id pcfData = OCMClassMock([PCFData class]);
    PCFDataHandler *handler = OCMClassMock([PCFDataHandler class]);
    PCFNetworkBlock block = ^(BOOL connected) {};
    
    OCMStub([pcfData handler]).andReturn(handler);
    
    [PCFData registerNetworkObserverBlock:block];
    
    OCMVerify([handler registerNetworkObserverBlock:block]);
    
    [pcfData stopMocking];
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
