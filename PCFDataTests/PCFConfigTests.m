//
//  PCFConfigTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-12-08.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>

@interface PCFConfigTests : XCTestCase

@property NSString *url;
@property BOOL etagsSupported;

@end

@implementation PCFConfigTests

static NSString* const PCFServiceUrl = @"pivotal.data.serviceUrl";
static NSString* const PCFAreEtagsEnabled = @"pivotal.data.etagsEnabled";

- (void)setUp {
    [super setUp];

    self.url = [NSUUID UUID].UUIDString;
    self.etagsSupported = arc4random_uniform(1);
}

- (void)testServiceUrl {
    id config = OCMPartialMock([[PCFConfig alloc] init]);
    
    OCMStub([config sharedInstance]).andReturn(config);
    OCMStub([config serviceUrl]).andReturn(self.url);
    
    NSString *serviceUrl = [PCFConfig serviceUrl];
    
    XCTAssertEqual(serviceUrl, self.url);
    
    OCMVerify([config sharedInstance]);
    OCMVerify([config serviceUrl]);
    
    [config stopMocking];
}

- (void)testServiceUrlInstance {
    id config = OCMPartialMock([[PCFConfig alloc] init]);
    NSDictionary *dict = OCMClassMock([NSDictionary class]);
    
    OCMStub([config values]).andReturn(dict);
    OCMStub([dict objectForKey:[OCMArg any]]).andReturn(self.url);
    
    NSString *serviceUrl = [config serviceUrl];
    
    XCTAssertEqual(serviceUrl, self.url);
    
    OCMVerify([config values]);
    OCMVerify([dict objectForKey:PCFServiceUrl]);
    
    [config stopMocking];
}

- (void)testEtagsSupported {
    id config = OCMPartialMock([[PCFConfig alloc] init]);
    
    OCMStub([config sharedInstance]).andReturn(config);
    OCMStub([config areEtagsSupported]).andReturn(self.etagsSupported);
    
    BOOL etags = [PCFConfig areEtagsSupported];
    
    XCTAssertEqual(etags, self.etagsSupported);
    
    OCMVerify([config sharedInstance]);
    OCMVerify([config areEtagsSupported]);
    
    [config stopMocking];
}

- (void)testEtagsSupportedInstance {
    id config = OCMPartialMock([[PCFConfig alloc] init]);
    NSDictionary *dict = OCMClassMock([NSDictionary class]);
    
    OCMStub([config values]).andReturn(dict);
    OCMStub([dict objectForKey:[OCMArg any]]).andReturn([NSNumber numberWithBool:self.etagsSupported]);
    
    BOOL etags = [config areEtagsSupported];
    
    XCTAssertEqual(etags, self.etagsSupported);
    
    OCMVerify([config values]);
    OCMVerify([dict objectForKey:PCFAreEtagsEnabled]);
    
    [config stopMocking];
}

- (void)testValues {
    id config = [[PCFConfig alloc] init];
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
