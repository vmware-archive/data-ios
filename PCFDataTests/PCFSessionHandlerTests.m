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
#import "PCFDataConfig.h"


@interface PCFSessionHandler ()

- (NSData *)certificateDataFromProtectionSpace:(NSURLProtectionSpace *)protectionSpace;

@end

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

- (void)testRespondToNonSslChallenge {
    NSURLSession *session = OCMClassMock([NSURLSession class]);
    PCFSessionHandler *handler = OCMPartialMock([[PCFSessionHandler alloc] initWithUrlSession:session]);
    NSURLProtectionSpace *space = OCMClassMock([NSURLProtectionSpace class]);
    NSURLAuthenticationChallenge *challenge = OCMClassMock([NSURLAuthenticationChallenge class]);
    id credential = OCMClassMock([NSURLCredential class]);
    
    OCMStub([challenge protectionSpace]).andReturn(space);
    OCMStub([space authenticationMethod]).andReturn(NSURLAuthenticationMethodHTTPBasic);
    OCMStub([credential credentialForTrust:[OCMArg anyPointer]]).andReturn(credential);
    
    __block BOOL completionHandlerWasCalled = NO;
    
    [handler URLSession:session didReceiveChallenge:challenge completionHandler:^(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *verifiedCredential) {
        XCTAssertEqual(disposition, NSURLSessionAuthChallengePerformDefaultHandling);
        XCTAssertNil(verifiedCredential);
        
        completionHandlerWasCalled = YES;
    }];
    
    XCTAssertEqual(completionHandlerWasCalled, YES);
    
    [credential stopMocking];
}

- (void)testRespondToChallengeWithPinnedCertificateMatchingRemote {
    NSURLSession *session = OCMClassMock([NSURLSession class]);
    PCFSessionHandler *handler = OCMPartialMock([[PCFSessionHandler alloc] initWithUrlSession:session]);
    NSURLProtectionSpace *space = OCMClassMock([NSURLProtectionSpace class]);
    NSURLAuthenticationChallenge *challenge = OCMClassMock([NSURLAuthenticationChallenge class]);
    NSArray *pinnedSSLCertificateNames = @[@"test1.cer", @"test2.cer"];
    id credential = OCMClassMock([NSURLCredential class]);
    id bundle = OCMClassMock([NSBundle class]);
    id config = OCMClassMock([PCFDataConfig class]);
    
    SecCertificateRef certificate1 = [self certificateFromMainBundleWithName:@"test1.cer"];
    
    SecTrustRef serverTrust;
    SecTrustCreateWithCertificates(certificate1, SecPolicyCreateBasicX509(), &serverTrust);
    
    OCMStub([challenge protectionSpace]).andReturn(space);
    OCMStub([space authenticationMethod]).andReturn(NSURLAuthenticationMethodServerTrust);
    OCMStub([space serverTrust]).andReturn(serverTrust);
    OCMStub([credential credentialForTrust:[OCMArg anyPointer]]).andReturn(credential);
    OCMStub([bundle mainBundle]).andReturn([NSBundle bundleForClass:[self class]]);
    OCMStub([config sharedInstance]).andReturn(config);
    OCMStub([config trustAllSslCertificates]).andReturn(NO);
    OCMStub([config pinnedSslCertificateNames]).andReturn(pinnedSSLCertificateNames);
    
    __block BOOL completionHandlerWasCalled = NO;
    
    [handler URLSession:session didReceiveChallenge:challenge completionHandler:^(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *verifiedCredential) {
        XCTAssertEqual(disposition, NSURLSessionAuthChallengeUseCredential);
        XCTAssertEqual(verifiedCredential, credential);
        
        completionHandlerWasCalled = YES;
    }];
    
    XCTAssertEqual(completionHandlerWasCalled, YES);
    
    [config stopMocking];
    [credential stopMocking];
    [bundle stopMocking];
}

- (void)testRespondToChallengeWithPinnedCertificatesThatDontMatchRemote {
    NSURLSession *session = OCMClassMock([NSURLSession class]);
    PCFSessionHandler *handler = OCMPartialMock([[PCFSessionHandler alloc] initWithUrlSession:session]);
    NSURLProtectionSpace *space = OCMClassMock([NSURLProtectionSpace class]);
    NSURLAuthenticationChallenge *challenge = OCMClassMock([NSURLAuthenticationChallenge class]);
    NSArray *pinnedSSLCertificateNames = @[@"test2.cer"];
    id credential = OCMClassMock([NSURLCredential class]);
    id bundle = OCMClassMock([NSBundle class]);
    id config = OCMClassMock([PCFDataConfig class]);
    
    SecCertificateRef certificate1 = [self certificateFromMainBundleWithName:@"test1.cer"];
    
    SecTrustRef serverTrust;
    SecTrustCreateWithCertificates(certificate1, NULL, &serverTrust);
    
    OCMStub([challenge protectionSpace]).andReturn(space);
    OCMStub([space authenticationMethod]).andReturn(NSURLAuthenticationMethodServerTrust);
    OCMStub([space serverTrust]).andReturn(serverTrust);
    OCMStub([credential credentialForTrust:[OCMArg anyPointer]]).andReturn(credential);
    OCMStub([bundle mainBundle]).andReturn([NSBundle bundleForClass:[self class]]);
    OCMStub([config sharedInstance]).andReturn(config);
    OCMStub([config trustAllSslCertificates]).andReturn(NO);
    OCMStub([config pinnedSslCertificateNames]).andReturn(pinnedSSLCertificateNames);
    
    __block BOOL completionHandlerWasCalled = NO;
    
    [handler URLSession:session didReceiveChallenge:challenge completionHandler:^(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *verifiedCredential) {
        XCTAssertEqual(disposition, NSURLSessionAuthChallengeRejectProtectionSpace);
        XCTAssertNil(verifiedCredential);
        
        completionHandlerWasCalled = YES;
    }];
    
    XCTAssertEqual(completionHandlerWasCalled, YES);
    
    [config stopMocking];
    [credential stopMocking];
    [bundle stopMocking];
}

- (void)testRespondToSslChallengeWithDefaultHandling {
    NSURLSession *session = OCMClassMock([NSURLSession class]);
    PCFSessionHandler *handler = OCMPartialMock([[PCFSessionHandler alloc] initWithUrlSession:session]);
    NSURLProtectionSpace *space = OCMClassMock([NSURLProtectionSpace class]);
    NSURLAuthenticationChallenge *challenge = OCMClassMock([NSURLAuthenticationChallenge class]);
    NSArray *pinnedSSLCertificateNames = @[];
    id credential = OCMClassMock([NSURLCredential class]);
    id config = OCMClassMock([PCFDataConfig class]);
    
    OCMStub([challenge protectionSpace]).andReturn(space);
    OCMStub([space authenticationMethod]).andReturn(NSURLAuthenticationMethodServerTrust);
    OCMStub([credential credentialForTrust:[OCMArg anyPointer]]).andReturn(credential);
    OCMStub([config sharedInstance]).andReturn(config);
    OCMStub([config trustAllSslCertificates]).andReturn(NO);
    OCMStub([config pinnedSslCertificateNames]).andReturn(pinnedSSLCertificateNames);
    
    __block BOOL completionHandlerWasCalled = NO;
    
    [handler URLSession:session didReceiveChallenge:challenge completionHandler:^(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *verifiedCredential) {
        XCTAssertEqual(disposition, NSURLSessionAuthChallengePerformDefaultHandling);
        XCTAssertNil(verifiedCredential);
        
        completionHandlerWasCalled = YES;
    }];
    
    XCTAssertEqual(completionHandlerWasCalled, YES);
    
    [config stopMocking];
    [credential stopMocking];
}

- (void)testRespondToSslChallengeWithTrustAllSSLCertificates {
    NSURLSession *session = OCMClassMock([NSURLSession class]);
    PCFSessionHandler *handler = OCMPartialMock([[PCFSessionHandler alloc] initWithUrlSession:session]);
    NSURLProtectionSpace *space = OCMClassMock([NSURLProtectionSpace class]);
    NSURLAuthenticationChallenge *challenge = OCMClassMock([NSURLAuthenticationChallenge class]);
    id credential = OCMClassMock([NSURLCredential class]);
    id config = OCMClassMock([PCFDataConfig class]);
    
    OCMStub([challenge protectionSpace]).andReturn(space);
    OCMStub([space authenticationMethod]).andReturn(NSURLAuthenticationMethodServerTrust);
    OCMStub([credential credentialForTrust:[OCMArg anyPointer]]).andReturn(credential);
    OCMStub([config sharedInstance]).andReturn(config);
    OCMStub([config trustAllSslCertificates]).andReturn(YES);
    OCMStub([config pinnedSslCertificateNames]).andReturn(@[]);
    
    __block BOOL completionHandlerWasCalled = NO;
    
    [handler URLSession:session didReceiveChallenge:challenge completionHandler:^(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *verifiedCredential) {
        XCTAssertEqual(disposition, NSURLSessionAuthChallengeUseCredential);
        XCTAssertEqual(verifiedCredential, credential);
        
        completionHandlerWasCalled = YES;
    }];
    
    XCTAssertEqual(completionHandlerWasCalled, YES);
    
    [config stopMocking];
    [credential stopMocking];
}

#pragma mark Helper Methods

- (SecCertificateRef)certificateFromMainBundleWithName:(NSString *)localCertificateName {
    NSString *localCertificatePath = [[NSBundle bundleForClass:[self class]] pathForResource:[localCertificateName stringByDeletingPathExtension] ofType:[localCertificateName pathExtension]];
    NSData *localCertificateData = [NSData dataWithContentsOfFile:localCertificatePath];
    CFDataRef localCertificateDataRef = (__bridge_retained CFDataRef)localCertificateData;
    
    SecCertificateRef localCertificate = SecCertificateCreateWithData(NULL, localCertificateDataRef);
    
    return localCertificate;
}

@end
