//
//  PCFDataConfigTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-12-08.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>
#import "PCFDataConfig.h"

@interface PCFDataConfigTests : XCTestCase

@property NSString *url;
@property PCFCollisionStrategy strategy;
@property BOOL trustAllSslCertificates;
@property NSArray *pinnedSslCertificateNames;

@end

@implementation PCFDataConfigTests

static NSString* const PCFServiceUrl = @"pivotal.data.serviceUrl";
static NSString* const PCFStrategy = @"pivotal.data.collisionStrategy";
static NSString* const PCFTrustAllSslCertificates = @"pivotal.data.trustAllSslCertificates";
static NSString* const PCFPinnedSslCertificateNames = @"pivotal.data.pinnedSslCertificateNames";

- (void)setUp {
    [super setUp];

    self.url = [NSUUID UUID].UUIDString;
    self.strategy = arc4random_uniform(1);
    self.trustAllSslCertificates = arc4random_uniform(1);
    self.pinnedSslCertificateNames = @[[NSUUID UUID].UUIDString];
}

- (void)testServiceUrl {
    id config = OCMPartialMock([[PCFDataConfig alloc] init]);
    
    OCMStub([config sharedInstance]).andReturn(config);
    OCMStub([config serviceUrl]).andReturn(self.url);
    
    NSString *serviceUrl = [PCFDataConfig serviceUrl];
    
    XCTAssertEqual(serviceUrl, self.url);
    
    OCMVerify([config sharedInstance]);
    OCMVerify([config serviceUrl]);
    
    [config stopMocking];
}

- (void)testServiceUrlInstance {
    id config = OCMPartialMock([[PCFDataConfig alloc] init]);
    NSDictionary *dict = OCMClassMock([NSDictionary class]);
    
    OCMStub([config values]).andReturn(dict);
    OCMStub([dict objectForKey:[OCMArg any]]).andReturn(self.url);
    
    NSString *serviceUrl = [config serviceUrl];
    
    XCTAssertEqual(serviceUrl, self.url);
    
    OCMVerify([config values]);
    OCMVerify([dict objectForKey:PCFServiceUrl]);
    
    [config stopMocking];
}

- (void)testCollisionStrategy {
    id config = OCMPartialMock([[PCFDataConfig alloc] init]);
    
    OCMStub([config sharedInstance]).andReturn(config);
    OCMStub([config collisionStrategy]).andReturn(self.strategy);
    
    PCFCollisionStrategy strategy = [PCFDataConfig collisionStrategy];
    
    XCTAssertEqual(strategy, self.strategy);
    
    OCMVerify([config sharedInstance]);
    OCMVerify([config collisionStrategy]);
    
    [config stopMocking];
}

- (void)testCollisionStrategyInstance {
    id config = OCMPartialMock([[PCFDataConfig alloc] init]);
    NSDictionary *dict = OCMClassMock([NSDictionary class]);
    
    OCMStub([config values]).andReturn(dict);
    OCMStub([dict objectForKey:[OCMArg any]]).andReturn([NSNumber numberWithBool:self.strategy]);
    
    PCFCollisionStrategy strategy = [config collisionStrategy];
    
    XCTAssertEqual(strategy, self.strategy);
    
    OCMVerify([config values]);
    OCMVerify([dict objectForKey:PCFStrategy]);
    
    [config stopMocking];
}

- (void)testTrustAllSSLCertificates {
    id config = OCMPartialMock([[PCFDataConfig alloc] init]);
    
    OCMStub([config sharedInstance]).andReturn(config);
    OCMStub([config trustAllSslCertificates]).andReturn(self.trustAllSslCertificates);
    
    BOOL trustAllSSLCertificates = [PCFDataConfig trustAllSslCertificates];
    
    XCTAssertEqual(trustAllSSLCertificates, self.trustAllSslCertificates);
    
    OCMVerify([config sharedInstance]);
    OCMVerify([config trustAllSslCertificates]);
    
    [config stopMocking];
}

- (void)testTrustAllSSLCertificatesInstace {
    id config = OCMPartialMock([[PCFDataConfig alloc] init]);
    NSDictionary *dict = OCMClassMock([NSDictionary class]);
    
    OCMStub([config values]).andReturn(dict);
    OCMStub([dict objectForKey:[OCMArg any]]).andReturn([NSNumber numberWithBool:self.trustAllSslCertificates]);
    
    BOOL trustAllSSLCertificates = [config trustAllSslCertificates];
    
    XCTAssertEqual(trustAllSSLCertificates, self.trustAllSslCertificates);
    
    OCMVerify([config values]);
    OCMVerify([dict objectForKey:PCFTrustAllSslCertificates]);
    
    [config stopMocking];
}

- (void)testPinnedSSLCertificateNames {
    id config = OCMPartialMock([[PCFDataConfig alloc] init]);
    
    OCMStub([config sharedInstance]).andReturn(config);
    OCMStub([config pinnedSslCertificateNames]).andReturn(self.pinnedSslCertificateNames);
    
    NSArray *pinnedSSLCertificateNames = [PCFDataConfig pinnedSslCertificateNames];
    
    XCTAssertEqual(pinnedSSLCertificateNames, self.pinnedSslCertificateNames);
    
    OCMVerify([config sharedInstance]);
    OCMVerify([config pinnedSslCertificateNames]);
    
    [config stopMocking];
}

- (void)testPinnedSSLCertificateNamesInstance {
    id config = OCMPartialMock([[PCFDataConfig alloc] init]);
    NSDictionary *dict = OCMClassMock([NSDictionary class]);
    
    OCMStub([config values]).andReturn(dict);
    OCMStub([dict objectForKey:[OCMArg any]]).andReturn(self.pinnedSslCertificateNames);
    
    NSArray *pinnedSSLCertificateNames = [config pinnedSslCertificateNames];
    
    XCTAssertEqual(pinnedSSLCertificateNames, self.pinnedSslCertificateNames);
    
    OCMVerify([config values]);
    OCMVerify([dict objectForKey:PCFPinnedSslCertificateNames]);
    
    [config stopMocking];
}

- (void)testValues {
    id config = [[PCFDataConfig alloc] init];
    id bundle = OCMClassMock([NSBundle class]);
    id dict = OCMClassMock([NSDictionary class]);
    NSString *path = [NSUUID UUID].UUIDString;
    
    OCMStub([bundle mainBundle]).andReturn(bundle);
    OCMStub([bundle pathForResource:[OCMArg any] ofType:[OCMArg any]]).andReturn(path);
    OCMStub([dict alloc]).andReturn(dict);
    OCMStub([dict initWithContentsOfFile:[OCMArg any]]).andReturn(dict);
    
    XCTAssertEqual([config values], dict);
    
    OCMVerify([bundle pathForResource:@"Pivotal" ofType:@"plist"]);
    OCMVerify([dict initWithContentsOfFile:path]);
    
    [bundle stopMocking];
    [dict stopMocking];
}

@end
