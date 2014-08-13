//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//


#import <Kiwi/Kiwi.h>

#import "MSSAFOAuth2Client.h"
#import "MSSAFNetworking.h"

#import "MSSDataSignIn+Internal.h"
#import "MSSDataTestHelpers.h"
#import "MSSDataTestConstants.h"
#import "MSSDataError.h"
#import "MSSDataObject+Internal.h"

void (^setupCredentialInKeychain)(NSString *, NSString *, NSInteger) = ^(NSString *accessToken, NSString *refreshToken, NSInteger expiresIn){
    MSSAFOAuthCredential *cred = [MSSAFOAuthCredential credentialWithOAuthToken:accessToken tokenType:@"Bearer"];
    [cred setRefreshToken:refreshToken expiration:[NSDate dateWithTimeIntervalSinceNow:expiresIn]];
    [MSSAFOAuthCredential storeCredential:cred withIdentifier:kMSSOAuthCredentialID];
};

void (^setupDefaultCredentialInKeychain)(void) = ^{
    setupCredentialInKeychain(kTestAccessToken1, kTestRefreshToken1, 60 * 60);
};

void (^setupForSuccessfulSilentAuth)(void) = ^{
    setupDefaultCredentialInKeychain();
    MSSAFOAuth2Client *authClient = [[MSSDataSignIn sharedInstance] authClient];
    [authClient stub:@selector(authenticateUsingOAuthWithPath:refreshToken:success:failure:)
           withBlock:^id(NSArray *params) {
               void (^success)(MSSAFOAuthCredential *credential) = params[2];
               MSSAFOAuthCredential *credential = [MSSAFOAuthCredential credentialWithOAuthToken:kTestAccessToken2 tokenType:kTestTokenType];
               [credential setRefreshToken:kTestRefreshToken1 expiration:[NSDate dateWithTimeIntervalSinceNow:3600]];
               success(credential);
               return nil;
           }];
};

void (^setupMSSDataSignInInstance)(id<MSSSignInDelegate>) = ^(id<MSSSignInDelegate> delegate){
    MSSDataSignIn *instance = [MSSDataSignIn sharedInstance];
    [instance setOpenIDConnectURL:kTestOpenIDConnectURL];
    [instance setClientID:kTestClientID];
    [instance setClientSecret:kTestClientSecret];
    [instance setDelegate:delegate];
};

void (^stubKeychain)(MSSAFOAuthCredential *) = ^(MSSAFOAuthCredential *credential){
    
    __block MSSAFOAuthCredential *blockCredential = credential;
    
    //Stub out MSSAFOAuthCredential as the Keychain is not available in a testing environment.
    [MSSAFOAuthCredential stub:@selector(storeCredential:withIdentifier:) withBlock:^id(NSArray *params) {
        blockCredential = params[0];
        return @YES;
    }];
    
    [MSSAFOAuthCredential stub:@selector(deleteCredentialWithIdentifier:) withBlock:^id(NSArray *params) {
        blockCredential = nil;
        return @YES;
    }];
    
    [MSSAFOAuthCredential stub:@selector(retrieveCredentialWithIdentifier:) withBlock:^id(NSArray *params) {
        return blockCredential;
    }];
};

NSError *(^unauthorizedError)(void) = ^NSError *{
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"Unauthorized access" };
    return [NSError errorWithDomain:NSURLErrorDomain code:401 userInfo:userInfo];
};

void (^assertObjectEqual)(id, NSDictionary *, MSSDataObject *) = ^(id self, NSDictionary *expectedDictionary, MSSDataObject *object) {
    [[object.contentsDictionary should] equal:expectedDictionary];
};

void (^verifyAuthorizationInRequest)(id, NSURLRequest *) = ^(id self, NSURLRequest *request) {
    static NSString *const kAuthorizationHeaderKey = @"Authorization";
    NSString *token = [request valueForHTTPHeaderField:kAuthorizationHeaderKey];
    [[theValue([token hasPrefix:@"Bearer "]) should] beTrue];
    [[theValue([token hasSuffix:kTestAccessToken1]) should] beTrue];
};

void (^stubAsyncCall)(NSString *, NSError **, EnqueueAsyncBlock) = ^(NSString *method, NSError **error, EnqueueAsyncBlock block){
    SEL stubSel = NSSelectorFromString([NSString stringWithFormat:@"%@Path:parameters:success:failure:", [method lowercaseString]]);
    MSSAFHTTPClient *client = [[MSSDataSignIn sharedInstance] dataServiceClient:error];
    
    [client stub:stubSel
       withBlock:^id(NSArray *params) {
           block(params);
           return nil;
       }];
};

void (^stubPutAsyncCall)(EnqueueAsyncBlock) = ^(EnqueueAsyncBlock block){
    stubAsyncCall(@"PUT", nil, block);
};

void (^stubGetAsyncCall)(EnqueueAsyncBlock) = ^(EnqueueAsyncBlock block){
    stubAsyncCall(@"GET", nil, block);
};

void (^stubDeleteAsyncCall)(EnqueueAsyncBlock) = ^(EnqueueAsyncBlock block){
    stubAsyncCall(@"DELETE", nil, block);
};