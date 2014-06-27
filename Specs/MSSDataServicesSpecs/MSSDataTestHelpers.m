//
//  MSSDataTestHelpers.m
//  MSSDataServices Spec
//
//  Created by Elliott Garcea on 2014-06-05.
//
//

#import <AFNetworking/AFNetworking.h>
#import <Kiwi/Kiwi.h>
#import <AFOAuth2Client/AFOAuth2Client.h>

#import "MSSDataSignIn+Internal.h"
#import "MSSDataTestHelpers.h"
#import "MSSDataTestConstants.h"
#import "MSSDataError.h"
#import "MSSObject+Internal.h"

void (^setupCredentialInKeychain)(NSString *, NSString *, NSInteger) = ^(NSString *accessToken, NSString *refreshToken, NSInteger expiresIn){
    AFOAuthCredential *cred = [AFOAuthCredential credentialWithOAuthToken:accessToken tokenType:@"Bearer"];
    [cred setRefreshToken:refreshToken expiration:[NSDate dateWithTimeIntervalSinceNow:expiresIn]];
    [AFOAuthCredential storeCredential:cred withIdentifier:kMSSOAuthCredentialID];
};

void (^setupDefaultCredentialInKeychain)(void) = ^{
    setupCredentialInKeychain(kTestAccessToken1, kTestRefreshToken1, 60 * 60);
};

void (^setupForSuccessfulSilentAuth)(void) = ^{
    setupDefaultCredentialInKeychain();
    AFOAuth2Client *authClient = [[MSSDataSignIn sharedInstance] authClient];
    [authClient stub:@selector(authenticateUsingOAuthWithPath:refreshToken:success:failure:)
           withBlock:^id(NSArray *params) {
               void (^success)(AFOAuthCredential *credential) = params[2];
               AFOAuthCredential *credential = [AFOAuthCredential credentialWithOAuthToken:kTestAccessToken2 tokenType:kTestTokenType];
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

void (^stubKeychain)(AFOAuthCredential *) = ^(AFOAuthCredential *credential){
    
    __block AFOAuthCredential *blockCredential = credential;
    
    //Stub out AFOAuthCredential as the Keychain is not available in a testing environment.
    [AFOAuthCredential stub:@selector(storeCredential:withIdentifier:) withBlock:^id(NSArray *params) {
        blockCredential = params[0];
        return @YES;
    }];
    
    [AFOAuthCredential stub:@selector(deleteCredentialWithIdentifier:) withBlock:^id(NSArray *params) {
        blockCredential = nil;
        return @YES;
    }];
    
    [AFOAuthCredential stub:@selector(retrieveCredentialWithIdentifier:) withBlock:^id(NSArray *params) {
        return blockCredential;
    }];
};

NSError *(^unauthorizedError)(void) = ^NSError *{
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"Unauthorized access" };
    return [NSError errorWithDomain:NSURLErrorDomain code:401 userInfo:userInfo];
};

void (^assertObjectEqual)(id, NSDictionary *, MSSObject *) = ^(id self, NSDictionary *expectedDictionary, MSSObject *object) {
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
    AFHTTPClient *client = [[MSSDataSignIn sharedInstance] dataServiceClient:error];
    
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