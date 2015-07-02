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

    PCFSessionHandler *handler = [[PCFSessionHandler alloc] initWithUrlSession:session];
    
    id handlerClass = OCMClassMock([PCFSessionHandler class]);

    // Setup Authentication Challenge
    id credential = OCMClassMock([NSURLCredential class]);
    NSURLProtectionSpace *space = OCMClassMock([NSURLProtectionSpace class]);
    NSURLAuthenticationChallenge *challenge = OCMClassMock([NSURLAuthenticationChallenge class]);
    OCMStub([challenge protectionSpace]).andReturn(space);
    OCMStub([space authenticationMethod]).andReturn(NSURLAuthenticationMethodServerTrust);
    OCMStub([credential credentialForTrust:[OCMArg anyPointer]]).andReturn(credential);

    // Setup local cert data to be returned from bundle
    id bundle = OCMClassMock([NSBundle class]);
    NSString *path = [NSUUID UUID].UUIDString;
    OCMStub([bundle mainBundle]).andReturn(bundle);
    OCMStub([bundle pathForResource:@"pivotal" ofType:@"cer"]).andReturn(path);
    
    NSData *localCertData = OCMClassMock([NSData class]);
    NSData *remoteCertData = OCMClassMock([NSData class]);
    id nsdata = OCMClassMock([NSData class]);
    OCMStub([nsdata dataWithContentsOfFile:path]).andReturn(localCertData);

    // Setup remote cert data
    OCMStub([handlerClass certificateDataFromProtectionSpace:space]).andReturn(remoteCertData);

    OCMStub([remoteCertData isEqualToData:localCertData]).andReturn(YES);
    OCMStub([localCertData isEqualToData:remoteCertData]).andReturn(YES);

    __block BOOL completionHandlerWasCalled = NO;
    
    [handler URLSession:session didReceiveChallenge:challenge completionHandler:^(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *verifiedCredential) {
        XCTAssertEqual(disposition, NSURLSessionAuthChallengeUseCredential);
        XCTAssertEqual(verifiedCredential, credential);
        
        completionHandlerWasCalled = YES;
    }];
    
    XCTAssertEqual(completionHandlerWasCalled, YES);
    
    [credential stopMocking];
}

- (void)testRespondToChallengeWithDefaultHandling {
    NSURLSession *session = OCMClassMock([NSURLSession class]);
    
    PCFSessionHandler *handler = [[PCFSessionHandler alloc] initWithUrlSession:session];
    
    id handlerClass = OCMClassMock([PCFSessionHandler class]);
    
    // Setup Authentication Challenge
    id credential = OCMClassMock([NSURLCredential class]);
    NSURLProtectionSpace *space = OCMClassMock([NSURLProtectionSpace class]);
    NSURLAuthenticationChallenge *challenge = OCMClassMock([NSURLAuthenticationChallenge class]);
    OCMStub([challenge protectionSpace]).andReturn(space);
    OCMStub([space authenticationMethod]).andReturn(NSURLAuthenticationMethodServerTrust);
    OCMStub([credential credentialForTrust:[OCMArg anyPointer]]).andReturn(credential);
    
    // Setup local cert data to be returned from bundle
    id bundle = OCMClassMock([NSBundle class]);
    NSString *path = [NSUUID UUID].UUIDString;
    OCMStub([bundle mainBundle]).andReturn(bundle);
    OCMStub([bundle pathForResource:@"pivotal" ofType:@"cer"]).andReturn(path);
    
    NSData *remoteCertData = OCMClassMock([NSData class]);
    id nsdata = OCMClassMock([NSData class]);
    OCMStub([nsdata dataWithContentsOfFile:path]).andReturn(nil);
    
    // Setup remote cert data
    OCMStub([handlerClass certificateDataFromProtectionSpace:space]).andReturn(remoteCertData);
    
    __block BOOL completionHandlerWasCalled = NO;
    
    [handler URLSession:session didReceiveChallenge:challenge completionHandler:^(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *verifiedCredential) {
        XCTAssertEqual(disposition, NSURLSessionAuthChallengePerformDefaultHandling);
        XCTAssertNil(verifiedCredential);
        
        completionHandlerWasCalled = YES;
    }];
    
    XCTAssertEqual(completionHandlerWasCalled, YES);
    
    [credential stopMocking];
}

- (void)testRespondToChallengeWithRejectedProtectionSpace {
    NSURLSession *session = OCMClassMock([NSURLSession class]);
    
    PCFSessionHandler *handler = [[PCFSessionHandler alloc] initWithUrlSession:session];
    
    id handlerClass = OCMClassMock([PCFSessionHandler class]);
    
    // Setup Authentication Challenge
    id credential = OCMClassMock([NSURLCredential class]);
    NSURLProtectionSpace *space = OCMClassMock([NSURLProtectionSpace class]);
    NSURLAuthenticationChallenge *challenge = OCMClassMock([NSURLAuthenticationChallenge class]);
    OCMStub([challenge protectionSpace]).andReturn(space);
    OCMStub([space authenticationMethod]).andReturn(NSURLAuthenticationMethodServerTrust);
    OCMStub([credential credentialForTrust:[OCMArg anyPointer]]).andReturn(credential);
    
    // Setup local cert data to be returned from bundle
    id bundle = OCMClassMock([NSBundle class]);
    NSString *path = [NSUUID UUID].UUIDString;
    OCMStub([bundle mainBundle]).andReturn(bundle);
    OCMStub([bundle pathForResource:@"pivotal" ofType:@"cer"]).andReturn(path);
    
    NSData *localCertData = OCMClassMock([NSData class]);
    NSData *remoteCertData = OCMClassMock([NSData class]);
    id nsdata = OCMClassMock([NSData class]);
    OCMStub([nsdata dataWithContentsOfFile:path]).andReturn(localCertData);
    
    // Setup remote cert data
    OCMStub([handlerClass certificateDataFromProtectionSpace:space]).andReturn(remoteCertData);
    
    OCMStub([remoteCertData isEqualToData:localCertData]).andReturn(NO);
    OCMStub([localCertData isEqualToData:remoteCertData]).andReturn(NO);
    
    __block BOOL completionHandlerWasCalled = NO;
    
    [handler URLSession:session didReceiveChallenge:challenge completionHandler:^(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *verifiedCredential) {
        XCTAssertEqual(disposition, NSURLSessionAuthChallengeRejectProtectionSpace);
        XCTAssertNil(verifiedCredential);
        
        completionHandlerWasCalled = YES;
    }];
    
    XCTAssertEqual(completionHandlerWasCalled, YES);
    
    [credential stopMocking];
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
