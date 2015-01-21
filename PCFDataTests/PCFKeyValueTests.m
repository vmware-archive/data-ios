//
//  PCFKeyValueTests.m
//  PCFData
//
//  Created by DX122-XL on 2015-01-20.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>
#import "PCFMappable.h"
#import "PCFConfig.h"

@interface PCFKeyValueTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *collection;

@end

@implementation PCFKeyValueTests

static NSString* const PCFCollection = @"collection";
static NSString* const PCFKey = @"key";
static NSString* const PCFValue = @"value";

- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.collection = [NSUUID UUID].UUIDString;
}

- (void)testInitWithKeyValue {
    PCFKeyValue *otherKeyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    PCFKeyValue *newKeyValue = [[PCFKeyValue alloc] initWithKeyValue:otherKeyValue];
    
    XCTAssertEqual(otherKeyValue.key, newKeyValue.key);
    XCTAssertEqual(otherKeyValue.value, newKeyValue.value);
    XCTAssertEqual(otherKeyValue.collection, newKeyValue.collection);
}

- (void)testInitWithCollection {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    
    XCTAssertEqual(self.key, keyValue.key);
    XCTAssertEqual(self.value, keyValue.value);
    XCTAssertEqual(self.collection, keyValue.collection);
}

- (void)testInitWithDictionary {
    NSDictionary *dict = @{
       PCFKey: self.key,
       PCFValue: self.value,
       PCFCollection: self.collection
    };
    
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithDictionary:dict];

    XCTAssertEqual(self.key, keyValue.key);
    XCTAssertEqual(self.value, keyValue.value);
    XCTAssertEqual(self.collection, keyValue.collection);
}

- (void)testToDictionary {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    
    NSDictionary *dict = [keyValue toDictionary];
    
    XCTAssertEqual(self.collection, [dict objectForKey:PCFCollection]);
    XCTAssertEqual(self.key, [dict objectForKey:PCFKey]);
    XCTAssertEqual(self.value, [dict objectForKey:PCFValue]);
}

- (void)testUrl {
    NSString *url = [NSString stringWithFormat:@"http://%@.com", [NSUUID UUID].UUIDString];
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    
    id config = OCMClassMock([PCFConfig class]);
    
    OCMStub([config sharedInstance]).andReturn(config);
    OCMStub([config serviceUrl]).andReturn(url);
    
    NSString *expectedUrl = [NSString stringWithFormat:@"%@/%@/%@", url, self.collection, self.key];
    
    XCTAssertEqualObjects(expectedUrl, [keyValue.url absoluteString]);
    
    [config stopMocking];
}

@end
