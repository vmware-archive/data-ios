//
//  PCFResponseTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-11-19.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PCFData/PCFResponse.h>

@interface PCFResponseTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSError *error;

@end

@implementation PCFResponseTests

- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    
    self.error = [[NSError alloc] init];
}

- (void)testSuccess {
    PCFResponse *response = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.value, self.value);
    
    XCTAssertNil(response.error);
}

- (void)testFailure {
    PCFResponse *response = [[PCFResponse alloc] initWithKey:self.key error:self.error];
    
    XCTAssertEqual(response.key, self.key);
    XCTAssertEqual(response.error, self.error);

    XCTAssertNil(response.value);
}

@end
