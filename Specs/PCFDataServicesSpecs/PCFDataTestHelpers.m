//
//  PCFDataTestHelpers.m
//  PCFDataServices Spec
//
//  Created by Elliott Garcea on 2014-06-05.
//
//

#import <AFNetworking/AFNetworking.h>
#import <Kiwi/Kiwi.h>
#import <AFOAuth2Client/AFOAuth2Client.h>

#import "PCFDataSignIn+Internal.h"
#import "PCFDataTestHelpers.h"
#import "PCFDataTestConstants.h"
#import "PCFDataError.h"

void (^setupCredentialInKeychain)(NSString *, NSString *, NSInteger) = ^(NSString *accessToken, NSString *refreshToken, NSInteger expiresIn){
    AFOAuthCredential *cred = [AFOAuthCredential credentialWithOAuthToken:accessToken tokenType:@"Bearer"];
    [cred setRefreshToken:refreshToken expiration:[NSDate dateWithTimeIntervalSinceNow:expiresIn]];
    [AFOAuthCredential storeCredential:cred withIdentifier:kPCFOAuthCredentialID];
};

void (^setupDefaultCredentialInKeychain)(void) = ^{
    setupCredentialInKeychain(kTestAccessToken1, kTestRefreshToken1, 60 * 60);
};

void (^setupForSuccessfulSilentAuth)(void) = ^{
    setupDefaultCredentialInKeychain();
    AFOAuth2Client *authClient = [[PCFDataSignIn sharedInstance] authClient];
    [authClient stub:@selector(authenticateUsingOAuthWithPath:refreshToken:success:failure:)
           withBlock:^id(NSArray *params) {
               void (^success)(AFOAuthCredential *credential) = params[2];
               AFOAuthCredential *credential = [AFOAuthCredential credentialWithOAuthToken:kTestAccessToken2 tokenType:kTestTokenType];
               [credential setRefreshToken:kTestRefreshToken1 expiration:[NSDate dateWithTimeIntervalSinceNow:3600]];
               success(credential);
               return nil;
           }];
};

void (^setupPCFDataSignInInstance)(id<PCFSignInDelegate>) = ^(id<PCFSignInDelegate> delegate){
    PCFDataSignIn *instance = [PCFDataSignIn sharedInstance];
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
