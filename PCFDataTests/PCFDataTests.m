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
#import "PCFDataPersistence.h"
#import "PCFEtagStore.h"

@interface PCFData ()

+ (PCFDataHandler *)handler;

+ (NSString *)provideToken;

+ (void)invalidateToken;

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

- (void)testRegisterTokenProvider {
    id pcfData = OCMClassMock([PCFData class]);
    PCFDataHandler *handler = OCMClassMock([PCFDataHandler class]);
    PCFTokenProviderBlock block = ^() { return @""; };
    
    OCMStub([pcfData handler]).andReturn(handler);
    
    [PCFData registerTokenProviderBlock:block];
    
    OCMVerify([handler registerTokenProviderBlock:block]);
    
    [pcfData stopMocking];
}

- (void)testUnregisterTokenProvider {
    id pcfData = OCMClassMock([PCFData class]);
    PCFDataHandler *handler = OCMClassMock([PCFDataHandler class]);
    
    OCMStub([pcfData handler]).andReturn(handler);
    
    [PCFData unregisterTokenProviderBlock];
    
    OCMVerify([handler registerTokenProviderBlock:nil]);
    
    [pcfData stopMocking];
}

- (void)testRegisterTokenInvalidator {
    id pcfData = OCMClassMock([PCFData class]);
    PCFDataHandler *handler = OCMClassMock([PCFDataHandler class]);
    PCFTokenInvalidatorBlock block = ^() {};
    
    OCMStub([pcfData handler]).andReturn(handler);
    
    [PCFData registerTokenInvalidatorBlock:block];
    
    OCMVerify([handler registerTokenInvalidatorBlock:block]);
    
    [pcfData stopMocking];
}

- (void)testUnregisterTokenInvalidator {
    id pcfData = OCMClassMock([PCFData class]);
    PCFDataHandler *handler = OCMClassMock([PCFDataHandler class]);
    
    OCMStub([pcfData handler]).andReturn(handler);
    
    [PCFData unregisterTokenInvalidatorBlock];
    
    OCMVerify([handler registerTokenInvalidatorBlock:nil]);
    
    [pcfData stopMocking];
}

- (void)testProvideToken {
    id pcfData = OCMClassMock([PCFData class]);
    PCFDataHandler *handler = OCMClassMock([PCFDataHandler class]);
    
    OCMStub([pcfData handler]).andReturn(handler);
    OCMStub([handler provideToken]).andReturn(self.token);
    
    XCTAssertEqual(self.token, [PCFData provideToken]);
    
    OCMVerify([handler provideToken]);

    [pcfData stopMocking];
}

- (void)testInvalidateToken {
    id pcfData = OCMClassMock([PCFData class]);
    PCFDataHandler *handler = OCMClassMock([PCFDataHandler class]);
    
    OCMStub([pcfData handler]).andReturn(handler);
    OCMStub([handler provideToken]).andReturn(self.token);
    
    [PCFData invalidateToken];
    
    OCMVerify([handler invalidateToken]);
    
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

- (void)testClearCachedData {
    id dataPersistence = OCMClassMock([PCFDataPersistence class]);
    
    OCMStub([dataPersistence alloc]).andReturn(dataPersistence);
    OCMStub([dataPersistence initWithDomainName:PCFDataPrefix]).andReturn(dataPersistence);
    OCMStub([dataPersistence initWithDomainName:PCFDataEtagPrefix]).andReturn(dataPersistence);
    
    [PCFData clearCachedData];
    
    OCMVerify([dataPersistence initWithDomainName:PCFDataPrefix]);
    OCMVerify([dataPersistence clear]);
    OCMVerify([dataPersistence initWithDomainName:PCFDataEtagPrefix]);
    OCMVerify([dataPersistence clear]);
    
    [dataPersistence stopMocking];
}

- (void)testLogLevelInvokesPCFLogger {
    id logger = OCMClassMock([PCFDataLogger class]);
    
    OCMStub([logger sharedInstance]).andReturn(logger);
    
    [PCFData logLevel:self.logLevel];
    
    OCMVerify([logger setLevel:self.logLevel]);
    
    [logger stopMocking];
}

@end
