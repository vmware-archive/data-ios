//
//  PCFResponseTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-11-19.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PCFData/PCFData.h>

@interface PCFResponseTests : XCTestCase

@property NSString *object;
@property NSError *error;

@end

@implementation PCFResponseTests

- (void)setUp {
    [super setUp];
    
    self.object = [NSUUID UUID].UUIDString;
    self.error = [[NSError alloc] init];
}

- (void)testInitWithObject {
    PCFResponse *response = [[PCFResponse alloc] initWithObject:self.object];
    
    XCTAssertEqual(self.object, response.object);
}

- (void)testInitWithObjectAndError {
    PCFResponse *response = [[PCFResponse alloc] initWithObject:self.object error:self.error];
    
    XCTAssertEqual(self.object, response.object);
    XCTAssertEqual(self.error, response.error);
}

@end
