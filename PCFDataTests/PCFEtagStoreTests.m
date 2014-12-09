//
//  PCFEtagStoreTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-12-05.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>

@interface PCFEtagStoreTests : XCTestCase

@property NSString *etag;
@property NSURL *url;

@end

@implementation PCFEtagStoreTests

static NSString* const PCFDataEtagPrefix = @"PCFData:Etag:";

- (void)setUp {
    [super setUp];
    
    self.etag = [NSUUID UUID].UUIDString;
    
    self.url = [NSURL URLWithString:@"http://example.com"];
}

- (void)testPutEtagForUrl {
    NSUserDefaults *defaults = OCMClassMock([NSUserDefaults class]);
    PCFEtagStore *etagStore = [[PCFEtagStore alloc] initWithDefaults:defaults];
    
    [etagStore putEtagForUrl:self.url etag:self.etag];
    
    OCMVerify([defaults setObject:self.etag forKey:self.prefixedUrl]);
}

- (void)testGetEtagForUrl {
    NSUserDefaults *defaults = OCMClassMock([NSUserDefaults class]);
    PCFEtagStore *etagStore = [[PCFEtagStore alloc] initWithDefaults:defaults];
    
    OCMStub([defaults objectForKey:[OCMArg any]]).andReturn(self.etag);
    
    NSString *etag = [etagStore getEtagForUrl:self.url];
    
    XCTAssertEqual(etag, self.etag);
    
    OCMVerify([defaults objectForKey:self.prefixedUrl]);
}

- (NSString *)prefixedUrl {
    return [PCFDataEtagPrefix stringByAppendingString:[self.url absoluteString]];
}

@end
