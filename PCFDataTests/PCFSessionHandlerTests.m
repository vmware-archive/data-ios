//
//  PCFSessionHandlerTests.m
//  PCFData
//
//  Created by DX122-XL on 2015-06-30.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>
#import "PCFSessionHandler.h"

#define OCMOCK_STRUCT(atype, variable) [NSValue valueWithBytes:&variable withObjCType:@encode(atype)]

@interface PCFSessionHandlerTests : XCTestCase

@end

@implementation PCFSessionHandlerTests


- (void)testPerformRequest {
    NSURLRequest *request = OCMClassMock([NSURLRequest class]);
    NSURLSession *session = OCMClassMock([NSURLSession class]);
    PCFSessionHandler *handler = [[PCFSessionHandler alloc] initWithUrlSession:session];
    
    NSData *expectedData = OCMClassMock([NSData class]);
    NSError *expectedError = OCMClassMock([NSError class]);
    NSURLResponse *expectedResponse = OCMClassMock([NSURLResponse class]);
    
    OCMStub([session dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^completionHandler)(NSData *data, NSURLResponse *response, NSError *error);
        [invocation getArgument:&completionHandler atIndex:3];
        completionHandler(expectedData, expectedResponse, expectedError);
    });
    
    NSError *error;
    NSURLResponse *response;
    NSData *data = [handler performRequest:request response:&response error:&error];
    
    XCTAssertEqual(data, expectedData);
    XCTAssertEqual(response, expectedResponse);
    XCTAssertEqual(error, expectedError);
    
    OCMVerify([session dataTaskWithRequest:request completionHandler:[OCMArg any]]);
}

- (void)testRespondToChallengeWithCredential {
    NSURLSession *session = OCMClassMock([NSURLSession class]);
    id credential = OCMClassMock([NSURLCredential class]);
    NSURLProtectionSpace *space = OCMClassMock([NSURLProtectionSpace class]);
    NSURLAuthenticationChallenge *challenge = OCMClassMock([NSURLAuthenticationChallenge class]);
    PCFSessionHandler *handler = [[PCFSessionHandler alloc] initWithUrlSession:session];
    
    // Need to stub out Pivotal.plist properties to return specific cert name(s)
    // Need to stub everything so that local cert == provided cert
    
    OCMStub([challenge protectionSpace]).andReturn(space);
    OCMStub([credential credentialForTrust:[OCMArg anyPointer]]).andReturn(credential);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    [handler URLSession:session didReceiveChallenge:challenge completionHandler:^(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *verifiedCredential) {
        XCTAssertEqual(disposition, NSURLSessionAuthChallengeUseCredential);
        XCTAssertEqual(verifiedCredential, credential);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    [credential stopMocking];
}

- (void)testRespondToChallengeWithDefaultHandling {
    // Need to stub everything with no local provided cert
}

- (void)testRespondToChallengeWithRejectedProtectionSpace {
    // Need to stub everything so that local cert != provided cert
}

- (void)testAcceptAllSSLCertificates {
    
}

//
//I renamed RequestPerformer to SessionHandler.
//
//I've fixed all the tests so that everyhting passes using the sessionHandler instead of sendSynchonrousRequest.
//
//I commented out all the certificate validation code. We need to finish our tests before continuing :)
//
//I started adding cases for certificate validation above^^^^^^^. Can you continue on with those?
//
//If anything doesn't make sense we can discuss on monday
//

@end
