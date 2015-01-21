//
//  PCFDataPersistenceTests.m
//  PCFData
//
//  Created by DX122-XL on 2015-01-13.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PCFData/PCFData.h>
#import <OCMock/OCMock.h>
#import "PCFDataPersistence.h"

@interface PCFDataPersistenceTests: XCTestCase
@property NSString *key;
@property NSString *value;
@end

@implementation PCFDataPersistenceTests

- (void)setUp {
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
}

- (void)testGetString {
    id defaults = OCMClassMock([NSUserDefaults class]);
    
    OCMStub([defaults standardUserDefaults]).andReturn(defaults);
    OCMStub([defaults objectForKey:[OCMArg any]]).andReturn(self.value);
    
    PCFDataPersistence* dataPersistence = [[PCFDataPersistence alloc] init];
    XCTAssertEqual(self.value, [dataPersistence getValueForKey:self.key]);
    
    OCMVerify([defaults objectForKey:self.key]);
    
    [defaults stopMocking];
}

- (void)testPutString {
    id defaults = OCMClassMock([NSUserDefaults class]);
    
    OCMStub([defaults standardUserDefaults]).andReturn(defaults);
    
    PCFDataPersistence* dataPersistence = [[PCFDataPersistence alloc] init];
    [dataPersistence putValue:self.value forKey:self.key];
    
    OCMVerify([defaults setObject:self.value forKey:self.key]);
    
    [defaults stopMocking];
}

- (void)testDeleteString {
    id defaults = OCMClassMock([NSUserDefaults class]);
    
    OCMStub([defaults standardUserDefaults]).andReturn(defaults);
    
    PCFDataPersistence* dataPersistence = [[PCFDataPersistence alloc] init];
    [dataPersistence deleteValueForKey:self.key];
    
    OCMVerify([defaults removeObjectForKey:self.key]);
    
    [defaults stopMocking];
}

@end
