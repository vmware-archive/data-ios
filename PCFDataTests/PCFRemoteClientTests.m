//
//  PCFRemoteClientTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-11-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>

@interface PCFRemoteClientTests : XCTestCase

@property NSString *token;
@property NSString *result;
@property NSError *error;
@property NSURL *url;

@end

@implementation PCFRemoteClientTests

- (void)setUp {
    [super setUp];
    
    self.token = [NSUUID UUID].UUIDString;
    self.result = [NSUUID UUID].UUIDString;
    
    self.error = [[NSError alloc] init];
    self.url = [NSURL URLWithString:@"http://test.com"];
}

- (void)testGetSucceeds {
    NSData *data = [self.result dataUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = OCMClassMock([NSURLRequest class]);
    id connection = OCMClassMock([NSURLConnection class]);

    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] init]);

    OCMStub([client requestWithAccessToken:[OCMArg any] url:[OCMArg any]]).andReturn(request);
    OCMStub([connection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andReturn(data);
    
    NSString *value = [client getWithAccessToken:self.token url:self.url error:nil];

    XCTAssertEqualObjects(value, self.result);
    
    OCMVerify([client requestWithAccessToken:self.token url:self.url]);
    OCMVerify([connection sendSynchronousRequest:request returningResponse:[OCMArg anyObjectRef] error:nil]);
    
    [connection stopMocking];
}

- (void)testGetFailsWithHttpErrorCode {
    NSURLRequest *request = OCMClassMock([NSURLRequest class]);
    id connection = OCMClassMock([NSURLConnection class]);
    
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] init]);
    
    OCMStub([client requestWithAccessToken:[OCMArg any] url:[OCMArg any]]).andReturn(request);
    OCMStub([connection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
        NSHTTPURLResponse *__autoreleasing *responsePtrPtr;
        [invocation getArgument:&responsePtrPtr atIndex:3];
        (*responsePtrPtr) = [[NSHTTPURLResponse alloc] initWithURL:self.url statusCode:404 HTTPVersion:nil headerFields:nil];
    });
    
    NSError *error;
    NSString *value = [client getWithAccessToken:self.token url:self.url error:&error];

    XCTAssertNil(value);
    XCTAssertEqual(error.code, 404);
    
    OCMVerify([client requestWithAccessToken:self.token url:self.url]);
    OCMVerify([connection sendSynchronousRequest:request returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]);
    
    [connection stopMocking];
}

- (void)testGetFailsWithError {
    NSURLRequest *request = OCMClassMock([NSURLRequest class]);
    id connection = OCMClassMock([NSURLConnection class]);
    
    PCFRemoteClient *client = OCMPartialMock([[PCFRemoteClient alloc] init]);
    
    OCMStub([client requestWithAccessToken:[OCMArg any] url:[OCMArg any]]).andReturn(request);
    OCMStub([connection sendSynchronousRequest:[OCMArg any] returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]).andDo(^(NSInvocation *invocation) {
        NSError *__autoreleasing *errorPtrPtr;
        [invocation getArgument:&errorPtrPtr atIndex:4];
        *errorPtrPtr = self.error;
    });
    
    NSError *error;
    NSString *value = [client getWithAccessToken:self.token url:self.url error:&error];
    
    XCTAssertNil(value);
    XCTAssertEqual(error, self.error);
    
    OCMVerify([client requestWithAccessToken:self.token url:self.url]);
    OCMVerify([connection sendSynchronousRequest:request returningResponse:[OCMArg anyObjectRef] error:[OCMArg anyObjectRef]]);
    
    [connection stopMocking];
}


@end
