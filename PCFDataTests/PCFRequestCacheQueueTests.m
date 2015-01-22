//
//  PCFRequestCacheQueueTests.m
//  PCFData
//
//  Created by DX122-XL on 2015-01-19.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>
#import "PCFDataPersistence.h"
#import "PCFKeyValue.h"
#import "PCFRequest.h"
#import "PCFRequestCacheQueue.h"
#import "PCFPendingRequest.h"

@interface PCFRequestCacheQueueTests : XCTestCase

@end

@implementation PCFRequestCacheQueueTests

static NSString* const PCFDataRequestCache = @"PCFData:RequestCache";

- (void)testAddRequestWithExistingArray {
    id jsonSerialization = OCMClassMock([NSJSONSerialization class]);
    NSString *serialized = [NSUUID UUID].UUIDString;
    NSData *data = [serialized dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = OCMClassMock([NSDictionary class]);
    NSMutableArray *serializedArray = OCMClassMock([NSMutableArray class]);
    
    PCFPendingRequest *request = OCMClassMock([PCFPendingRequest class]);
    PCFDataPersistence *persistence = OCMClassMock([PCFDataPersistence class]);
    PCFRequestCacheQueue *queue = [[PCFRequestCacheQueue alloc] initWithPersistence:persistence];
    
    OCMStub([persistence getValueForKey:[OCMArg any]]).andReturn(serialized);
    OCMStub([jsonSerialization JSONObjectWithData:[OCMArg any] options:0 error:nil]).andReturn(serializedArray);
    OCMStub([serializedArray mutableCopy]).andReturn(serializedArray);
    OCMStub([request toDictionary]).andReturn(dict);
    OCMStub([jsonSerialization dataWithJSONObject:[OCMArg any] options:0 error:nil]).andReturn(data);
    
    [queue addRequest:request];
    
    OCMVerify([persistence getValueForKey:PCFDataRequestCache]);
    OCMVerify([jsonSerialization JSONObjectWithData:data options:0 error:nil]);
    OCMVerify([serializedArray addObject:dict]);
    OCMVerify([jsonSerialization dataWithJSONObject:serializedArray options:0 error:nil]);
    OCMVerify([persistence putValue:[OCMArg any] forKey:PCFDataRequestCache]);
    
    [jsonSerialization stopMocking];
}

- (void)testAddRequestWithoutExistingArray {
    id jsonSerialization = OCMClassMock([NSJSONSerialization class]);
    id array = OCMClassMock([NSMutableArray class]);
    NSDictionary *dict = OCMClassMock([NSDictionary class]);
    
    PCFPendingRequest *request = OCMClassMock([PCFPendingRequest class]);
    PCFDataPersistence *persistence = OCMClassMock([PCFDataPersistence class]);
    PCFRequestCacheQueue *queue = [[PCFRequestCacheQueue alloc] initWithPersistence:persistence];
    
    OCMStub([persistence getValueForKey:[OCMArg any]]).andReturn(nil);
    OCMStub([request toDictionary]).andReturn(dict);
    OCMStub([array arrayWithObject:[OCMArg any]]).andReturn(array);
    
    [queue addRequest:request];
    
    OCMVerify([persistence getValueForKey:PCFDataRequestCache]);
    OCMVerify([array arrayWithObject:dict]);
    OCMVerify([jsonSerialization dataWithJSONObject:array options:0 error:nil]);
    OCMVerify([persistence putValue:[OCMArg any] forKey:PCFDataRequestCache]);
    
    [jsonSerialization stopMocking];
    [array stopMocking];
}

- (void)testEmpty {
    id jsonSerialization = OCMClassMock([NSJSONSerialization class]);
    id pendingRequest = OCMStrictClassMock([PCFPendingRequest class]);
    NSString *serialized = [NSUUID UUID].UUIDString;
    NSData *data = [serialized dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = OCMClassMock([NSDictionary class]);
    NSArray *dictArray = @[dict];
    
    PCFDataPersistence *persistence = OCMClassMock([PCFDataPersistence class]);
    PCFRequestCacheQueue *queue = [[PCFRequestCacheQueue alloc] initWithPersistence:persistence];
    
    OCMStub([persistence getValueForKey:[OCMArg any]]).andReturn(serialized);
    OCMStub([jsonSerialization JSONObjectWithData:[OCMArg any] options:0 error:nil]).andReturn(dictArray);
    OCMStub([pendingRequest alloc]).andReturn(pendingRequest);
    OCMStub([pendingRequest initWithDictionary:[OCMArg any]]).andReturn(pendingRequest);
    
    NSArray *resultArray = queue.empty;
    
    XCTAssertEqual(pendingRequest, resultArray[0]);
    
    OCMVerify([persistence getValueForKey:PCFDataRequestCache]);
    OCMVerify([persistence deleteValueForKey:PCFDataRequestCache]);
    OCMVerify([jsonSerialization JSONObjectWithData:data options:0 error:nil]);
    OCMVerify([pendingRequest initWithDictionary:dict]);
    
    [jsonSerialization stopMocking];
    [pendingRequest stopMocking];
}


@end
