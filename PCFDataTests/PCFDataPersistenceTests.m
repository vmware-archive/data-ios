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

@interface PCFDataPersistence ()
@property (strong, readonly) NSUserDefaults *defaults;
@property (strong, readonly) NSMutableDictionary *values;
@property (strong, readonly) NSString *domainName;
@end

@interface PCFDataPersistenceTests: XCTestCase
@property NSString *key;
@property NSString *value;
@end

@implementation PCFDataPersistenceTests

- (void)setUp {
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
}

- (void)testInitWithExistingDomainName {
    NSString *domainName = [NSUUID UUID].UUIDString;
    NSMutableDictionary *dictionary = OCMClassMock([NSMutableDictionary class]);
    id defaults = OCMClassMock([NSUserDefaults class]);
    
    OCMStub([defaults standardUserDefaults]).andReturn(defaults);
    OCMStub([defaults persistentDomainForName:[OCMArg any]]).andReturn(dictionary);
    
    PCFDataPersistence *dataPersistence = [[PCFDataPersistence alloc] initWithDomainName:domainName];
    
    XCTAssertNotNil(dataPersistence);
    XCTAssertEqual([NSUserDefaults standardUserDefaults], dataPersistence.defaults);
    XCTAssertEqual(dictionary, dataPersistence.values);

    OCMVerify([defaults persistentDomainForName:domainName]);
    
    [defaults stopMocking];
}

- (void)testInitWithNewDomainName {
    NSString *domainName = [NSUUID UUID].UUIDString;
    id defaults = OCMClassMock([NSUserDefaults class]);
    
    OCMStub([defaults standardUserDefaults]).andReturn(defaults);
    OCMStub([defaults persistentDomainForName:[OCMArg any]]).andReturn(nil);
    
    PCFDataPersistence *dataPersistence = [[PCFDataPersistence alloc] initWithDomainName:domainName];
    
    XCTAssertNotNil(dataPersistence);
    XCTAssertEqual([NSUserDefaults standardUserDefaults], dataPersistence.defaults);
    
    [defaults stopMocking];
}

- (void)testGetString {
    id defaults = OCMClassMock([NSUserDefaults class]);
    NSDictionary *dictionary = OCMClassMock([NSDictionary class]);
    
    OCMStub([defaults standardUserDefaults]).andReturn(defaults);
    OCMStub([defaults persistentDomainForName:[OCMArg any]]).andReturn(dictionary);
    OCMStub([dictionary objectForKey:[OCMArg any]]).andReturn(self.value);
    
    PCFDataPersistence *dataPersistence = [[PCFDataPersistence alloc] initWithDomainName:nil];
    XCTAssertEqual(self.value, [dataPersistence getValueForKey:self.key]);
    
    OCMVerify([dictionary objectForKey:self.key]);
    
    [defaults stopMocking];
}

- (void)testPutString {
    NSString *domainName = [NSUUID UUID].UUIDString;
    id defaults = OCMClassMock([NSUserDefaults class]);
    NSMutableDictionary *dictionary = OCMClassMock([NSMutableDictionary class]);
    
    OCMStub([defaults standardUserDefaults]).andReturn(defaults);
    OCMStub([defaults persistentDomainForName:[OCMArg any]]).andReturn(dictionary);
    
    PCFDataPersistence *dataPersistence = [[PCFDataPersistence alloc] initWithDomainName:domainName];
    XCTAssertEqual(self.value, [dataPersistence putValue:self.value forKey:self.key]);
    
    OCMVerify([dictionary setObject:self.value forKey:self.key]);
    OCMVerify([defaults setPersistentDomain:dictionary forName:domainName]);
    
    [defaults stopMocking];
}

- (void)testDeleteString {
    NSString *domainName = [NSUUID UUID].UUIDString;
    id defaults = OCMClassMock([NSUserDefaults class]);
    NSMutableDictionary *dictionary = OCMClassMock([NSMutableDictionary class]);
    
    OCMStub([defaults standardUserDefaults]).andReturn(defaults);
    OCMStub([defaults persistentDomainForName:[OCMArg any]]).andReturn(dictionary);
    
    PCFDataPersistence *dataPersistence = [[PCFDataPersistence alloc] initWithDomainName:domainName];
    XCTAssertEqualObjects(@"", [dataPersistence deleteValueForKey:self.key]);
    
    OCMVerify([dictionary removeObjectForKey:self.key]);
    OCMVerify([defaults setPersistentDomain:dictionary forName:domainName]);
    
    [defaults stopMocking];
}

- (void)testClear {
    NSString *domainName = [NSUUID UUID].UUIDString;
    id defaults = OCMClassMock([NSUserDefaults class]);
    
    OCMStub([defaults standardUserDefaults]).andReturn(defaults);
    
    PCFDataPersistence *dataPersistence = [[PCFDataPersistence alloc] initWithDomainName:domainName];
    [dataPersistence clear];
    
    OCMVerify([defaults removePersistentDomainForName:domainName]);
    
    [defaults stopMocking];
}

- (void)testGetAfterClear {
    NSString *domainName = [NSUUID UUID].UUIDString;
    id defaults = OCMClassMock([NSUserDefaults class]);
    
    OCMStub([defaults standardUserDefaults]).andReturn(defaults);
    
    PCFDataPersistence *dataPersistence = [[PCFDataPersistence alloc] initWithDomainName:domainName];
    [dataPersistence putValue:self.value forKey:self.key];
    [dataPersistence clear];
    
    OCMVerify([defaults removePersistentDomainForName:domainName]);
    XCTAssertNil([dataPersistence getValueForKey:self.key]);
    
    [defaults stopMocking];
}

- (void)testIntegration {
    NSString *domainName = [NSUUID UUID].UUIDString;
    PCFDataPersistence *dataPersistence = [[PCFDataPersistence alloc] initWithDomainName:domainName];
    
    XCTAssertEqual(self.value, [dataPersistence putValue:self.value forKey:self.key]);
    
    XCTAssertEqual(self.value, [dataPersistence getValueForKey:self.key]);
    
    NSDictionary *dictionary = [dataPersistence.defaults persistentDomainForName:domainName];
    
    XCTAssertEqual(self.value, [dictionary objectForKey:self.key]);
}

@end
