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
    
    NSData *remoteCertData = [[NSUUID UUID].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *localCertData = [remoteCertData copy];
    
    
    NSURLAuthenticationChallenge *challenge = [self setupMockChallengeWithType:NSURLAuthenticationMethodServerTrust
                                                             andRemoteCertData:remoteCertData];
    NSURLCredential *credential = [self setupCredential];
    [self setupBundleWithLocalCertData:localCertData];

    
    __block BOOL completionHandlerWasCalled = NO;
    
    [handler URLSession:session didReceiveChallenge:challenge completionHandler:^(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *verifiedCredential) {
        XCTAssertEqual(disposition, NSURLSessionAuthChallengeUseCredential);
        XCTAssertEqual(verifiedCredential, credential);
        
        completionHandlerWasCalled = YES;
    }];
    
    XCTAssertEqual(completionHandlerWasCalled, YES);
}

- (void)testRespondToChallengeWithDefaultHandling {
    NSURLSession *session = OCMClassMock([NSURLSession class]);
    
    PCFSessionHandler *handler = [[PCFSessionHandler alloc] initWithUrlSession:session];
    
    NSData *remoteCertData = [[NSUUID UUID].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *localCertData = nil;
    
    
    NSURLAuthenticationChallenge *challenge = [self setupMockChallengeWithType:NSURLAuthenticationMethodServerTrust
                                                             andRemoteCertData:remoteCertData];
    [self setupCredential];
    [self setupBundleWithLocalCertData:localCertData];
    
    
    __block BOOL completionHandlerWasCalled = NO;
    
    [handler URLSession:session didReceiveChallenge:challenge completionHandler:^(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *verifiedCredential) {
        XCTAssertEqual(disposition, NSURLSessionAuthChallengePerformDefaultHandling);
        XCTAssertNil(verifiedCredential);
        
        completionHandlerWasCalled = YES;
    }];
    
    XCTAssertEqual(completionHandlerWasCalled, YES);
}

- (void)testRespondToChallengeWithRejectedProtectionSpace {
    NSURLSession *session = OCMClassMock([NSURLSession class]);
    
    PCFSessionHandler *handler = [[PCFSessionHandler alloc] initWithUrlSession:session];
    
    NSData *remoteCertData = [[NSUUID UUID].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    NSData *localCertData = [[NSUUID UUID].UUIDString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURLAuthenticationChallenge *challenge = [self setupMockChallengeWithType:NSURLAuthenticationMethodServerTrust
                                                             andRemoteCertData:remoteCertData];
    [self setupCredential];
    [self setupBundleWithLocalCertData:localCertData];
    
    
    __block BOOL completionHandlerWasCalled = NO;
    
    [handler URLSession:session didReceiveChallenge:challenge completionHandler:^(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *verifiedCredential) {
        XCTAssertEqual(disposition, NSURLSessionAuthChallengeRejectProtectionSpace);
        XCTAssertNil(verifiedCredential);
        
        completionHandlerWasCalled = YES;
    }];
    
    XCTAssertEqual(completionHandlerWasCalled, YES);
}

- (void)testAcceptAllSSLCertificates {
    
}


#pragma mark - Setup

- (NSURLAuthenticationChallenge *)setupMockChallengeWithType:(NSString *)trustType andRemoteCertData:(NSData *)remoteCertData {
    // Setup Authentication Challenge
    NSURLProtectionSpace *space = OCMClassMock([NSURLProtectionSpace class]);
    NSURLAuthenticationChallenge *challenge = OCMClassMock([NSURLAuthenticationChallenge class]);
    OCMStub([challenge protectionSpace]).andReturn(space);
    OCMStub([space authenticationMethod]).andReturn(NSURLAuthenticationMethodServerTrust);
    
    id handlerClass = OCMClassMock([PCFSessionHandler class]);
    
    OCMStub([handlerClass certificateDataFromProtectionSpace:space]).andReturn(remoteCertData);
    
    return challenge;
}

- (NSURLCredential *)setupCredential {
    id credential = OCMClassMock([NSURLCredential class]);
    OCMStub([credential credentialForTrust:[OCMArg anyPointer]]).andReturn(credential);
    return credential;
}

- (void)setupBundleWithLocalCertData:(NSData *)localCertData {
    // Setup local cert data to be returned from bundle
    id bundle = OCMClassMock([NSBundle class]);
    NSString *path = [NSUUID UUID].UUIDString;
    OCMStub([bundle mainBundle]).andReturn(bundle);
    OCMStub([bundle pathForResource:[OCMArg any] ofType:[OCMArg any]]).andReturn(path);
    
    id nsdata = OCMClassMock([NSData class]);
    OCMStub([nsdata dataWithContentsOfFile:path]).andReturn(localCertData);
}


#pragma mark - Teardown

@end
