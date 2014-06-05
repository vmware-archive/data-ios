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

void (^setupCredentialInKeychain)(void) = ^{
    AFOAuthCredential *cred = [AFOAuthCredential credentialWithOAuthToken:kTestOAuthToken tokenType:@"Bearer"];
    [cred setRefreshToken:kTestRefreshToken expiration:[NSDate dateWithTimeIntervalSinceNow:60 * 60]];
    [AFOAuthCredential storeCredential:cred withIdentifier:kPCFOAuthCredentialID];
};

void (^setupForSuccessfulSilentAuth)(void) = ^{
    setupCredentialInKeychain();
    
    [[[PCFDataSignIn sharedInstance] authClient] stub:@selector(authenticateUsingOAuthWithPath:refreshToken:success:failure:)
                                            withBlock:^id(NSArray *params) {
                                                void (^success)(AFOAuthCredential *credential) = params[2];
                                                AFOAuthCredential *credential = [AFOAuthCredential credentialWithOAuthToken:kTestOAuthToken tokenType:kTestTokenType];
                                                [credential setRefreshToken:kTestRefreshToken expiration:[NSDate dateWithTimeIntervalSinceNow:3600]];
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
