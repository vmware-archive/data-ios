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
#import "PCFEtagStore.h"
#import "PCFDataPersistence.h"

@interface PCFEtagStoreTests : XCTestCase

@property NSString *etag;
@property NSURL *url;

@end

@implementation PCFEtagStoreTests

- (void)setUp {
    [super setUp];
    
    self.etag = [NSUUID UUID].UUIDString;
    self.url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@.com", [NSUUID UUID].UUIDString]];
}

- (void)testPutEtagForUrl {
    PCFDataPersistence *persistence = OCMClassMock([PCFDataPersistence class]);
    PCFEtagStore *etagStore = [[PCFEtagStore alloc] initWithPersistence:persistence];
    
    [etagStore putEtagForUrl:self.url etag:self.etag];
    
    OCMVerify([persistence putValue:self.etag forKey:self.prefixedUrl]);
}

- (void)testGetEtagForUrl {
    PCFDataPersistence *persistence = OCMClassMock([PCFDataPersistence class]);
    PCFEtagStore *etagStore = [[PCFEtagStore alloc] initWithPersistence:persistence];
    
    OCMStub([persistence getValueForKey:[OCMArg any]]).andReturn(self.etag);
    
    NSString *etag = [etagStore etagForUrl:self.url];
    
    XCTAssertEqual(etag, self.etag);
    
    OCMVerify([persistence getValueForKey:self.prefixedUrl]);
}

- (NSString *)prefixedUrl {
    return [self.url absoluteString];
}

@end
