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
    NSData *data = [[NSUUID UUID].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = OCMClassMock([NSDictionary class]);
    
    PCFPendingRequest *request = OCMClassMock([PCFPendingRequest class]);
    NSArray *array = [[NSArray alloc] initWithObjects:request, nil];
    
    PCFDataPersistence *persistence = OCMClassMock([PCFDataPersistence class]);
    PCFRequestCacheQueue *queue = [[PCFRequestCacheQueue alloc] initWithPersistence:persistence];
    
    id jsonSerialization = OCMClassMock([NSJSONSerialization class]);
    
    OCMStub([request toDictionary]).andReturn(dict);
    OCMStub([persistence getValueForKey:[OCMArg any]]).andReturn(array);
    OCMStub([jsonSerialization dataWithJSONObject:[OCMArg any] options:0 error:nil]).andReturn(data);
    
    [queue addRequest:request];
    
    OCMVerify([persistence getValueForKey:PCFDataRequestCache]);
    OCMVerify([persistence putValue:[OCMArg any] forKey:PCFDataRequestCache]);
    
    [jsonSerialization stopMocking];
}

- (void)testAddRequestWithoutExistingArray {
    NSString *value = [NSUUID UUID].UUIDString;
    PCFDataPersistence *persistence = OCMClassMock([PCFDataPersistence class]);
    PCFRequestCacheQueue *queue = [[PCFRequestCacheQueue alloc] initWithPersistence:persistence];

    NSDictionary *dict = OCMClassMock([NSDictionary class]);
    
    NSArray *serializedArray = @[dict];
    
    id pendingRequest = OCMStrictClassMock([PCFPendingRequest class]);
    id jsonSerialization = OCMClassMock([NSJSONSerialization class]);
    
    OCMStub([persistence getValueForKey:[OCMArg any]]).andReturn(value);
    OCMStub([jsonSerialization JSONObjectWithData:[OCMArg any] options:0 error:nil]).andReturn(serializedArray);
    OCMStub([pendingRequest alloc]).andReturn(pendingRequest);
    OCMStub([pendingRequest initWithDictionary:[OCMArg any]]).andReturn(pendingRequest);

    NSArray *resultArray = queue.empty;
    
    XCTAssertEqual(pendingRequest, resultArray[0]);
    
    OCMVerify([persistence getValueForKey:PCFDataRequestCache]);
    OCMVerify([persistence deleteValueForKey:PCFDataRequestCache]);
    OCMVerify([pendingRequest initWithDictionary:dict]);
    
    [jsonSerialization stopMocking];
    [pendingRequest stopMocking];
}


@end
