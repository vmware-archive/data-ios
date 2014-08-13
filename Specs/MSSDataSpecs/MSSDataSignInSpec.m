//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import "MSSAFNetworking.h"
#import "MSSAFOAuth2Client.h"

#import "Kiwi.h"

#import "MSSDataSignIn+Internal.h"
#import "MSSDataError.h"
#import "MSSDataTestConstants.h"
#import "MSSDataTestHelpers.h"


SPEC_BEGIN(MSSDataSignInSpec)

void (^resetSharedInstance)(void) = ^{
    [MSSDataSignIn setSharedInstance:nil];
};

void (^setupForFailedSilentAuth)(void) = ^{
    [MSSAFOAuthCredential deleteCredentialWithIdentifier:kMSSOAuthCredentialID];
};

context(@"MSSDataSignIn Specification", ^{
    
    __block MSSAFOAuthCredential *credential;
    
    beforeEach(^{
        resetSharedInstance();
        
        [[NSBundle mainBundle] stub:@selector(bundleIdentifier) withBlock:^id(NSArray *params) {
            return kTestBundleIndentifier;
        }];
        
        stubKeychain(credential);
    });
    
    afterEach(^{
        credential = nil;
    });
    
    describe(@"MSSDataSignIn shared instance initialization", ^{
        
        it(@"should initialize with the |openid| value in the scope property.", ^{
            NSArray *scopes = [[MSSDataSignIn sharedInstance] scopes];
            [[theValue([scopes containsObject:@"openid"]) should] beTrue];
        });
        
        it(@"should initialize with nil clientID", ^{
            [[[[MSSDataSignIn sharedInstance] clientID] should] beNil];
        });
    });
    
    describe(@"call delegate with error during authentication", ^{
        
        __block MSSDataSignIn *sharedInstance;
        
        beforeEach(^{
            sharedInstance = [MSSDataSignIn sharedInstance];
            NSObject<MSSSignInDelegate> *instanceDelegate = [KWMock mockForProtocol:@protocol(MSSSignInDelegate)];
            [[instanceDelegate should] receive:@selector(finishedWithAuth:error:) withArguments:nil, any()];
            sharedInstance.delegate = instanceDelegate;
        });
        
        it(@"should call delegate with error if authenticate is called while 'clientID' is not set on MSSDataSignIn shared instance", ^{
            [[sharedInstance.clientID should] beNil];
            [sharedInstance authenticate];
        });
        
        it(@"should call delegate with error if authenticate is called while 'openIDConnectURL' is not set on MSSDataSignIn shared instance", ^{
            [[sharedInstance.openIDConnectURL should] beNil];
            [sharedInstance authenticate];
        });
    });
        
    describe(@"trySilentAuthentication ", ^{
        
        __block NSObject<MSSSignInDelegate> *instanceDelegate;
        __block MSSDataSignIn *sharedInstance;
        
        beforeEach(^{
            instanceDelegate = [KWMock mockForProtocol:@protocol(MSSSignInDelegate)];
            setupMSSDataSignInInstance(instanceDelegate);
            sharedInstance = [MSSDataSignIn sharedInstance];
        });
        
        afterEach(^{
            instanceDelegate = nil;
        });
        
        it(@"should try authentication with stored credential before defaulting to sigining in through Mobile SMSSAFari", ^{
            [[sharedInstance should] receive:@selector(credential)];
            [sharedInstance authenticate];
        });
        
        it(@"should call delegate 'finishedWithAuth:error:' method with a populated MSSAFOAuthCredential object when silent authentication succeeds", ^{
            setupForSuccessfulSilentAuth();
            
            sharedInstance.dataServiceURL = kTestDataServiceURL;
            [[instanceDelegate shouldEventually] receive:@selector(finishedWithAuth:error:) withArguments:any(), nil];
            [sharedInstance authenticate];
        });
        
        it(@"should not call delegate 'finishedWithAuth:error:' method when silent authentication fails", ^{
            sharedInstance.dataServiceURL = kTestDataServiceURL;
            
            setupForFailedSilentAuth();
            
            [[instanceDelegate shouldNotEventually] receive:@selector(finishedWithAuth:error:)];
            
            [sharedInstance authenticate];
        });
        
        it(@"should open SMSSAFari Mobile if silent auth fails to perform authentication", ^{
            setupForFailedSilentAuth();
            
            NSString *scopes = [sharedInstance.scopes componentsJoinedByString:@"%%20"];
            NSString *bundleID = [NSString stringWithFormat:@"%@:/oauth2callback", kTestBundleIndentifier];
            NSURL *expectedURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?state=/profile&redirect_uri=%@&response_type=code&client_id=%@&scope=%@", kTestOpenIDConnectURL, bundleID, kTestClientID, scopes]];
            [[[UIApplication sharedApplication] shouldEventually] receive:@selector(openURL:) withArguments:expectedURL];
            
            [sharedInstance authenticate];
        });
        
        it(@"should save new access token credential if silent authentication is successful", ^{
            sharedInstance.dataServiceURL = kTestDataServiceURL;
            [[instanceDelegate shouldEventually] receive:@selector(finishedWithAuth:error:) withArguments:any(), nil];
            
            NSString *accessToken1 = [sharedInstance credential].accessToken;
            
            setupForSuccessfulSilentAuth();
            
            [sharedInstance trySilentAuthentication];
            
            [[[sharedInstance credential].accessToken shouldNot] equal:accessToken1];
            [[[sharedInstance credential].accessToken should] equal:kTestAccessToken2];
        });
        
        it(@"should update the authorization header on the data services client after successful silent authentication", ^{
            sharedInstance.dataServiceURL = kTestDataServiceURL;
            [[instanceDelegate shouldEventually] receive:@selector(finishedWithAuth:error:) withArguments:any(), nil];
            
            setupForSuccessfulSilentAuth();
            [sharedInstance setCredential:sharedInstance.credential];
            
            MSSAFHTTPClient *client = [sharedInstance dataServiceClient:nil];
            NSString *headerValue1 = [client defaultValueForHeader:@"Authorization"];
            [[headerValue1 shouldNot] beNil];
            
            [sharedInstance trySilentAuthentication];
            
            NSString *headerValue2 = [client defaultValueForHeader:@"Authorization"];
            [[headerValue2 shouldNot] beNil];
            [[headerValue2 shouldNot] equal:headerValue1];
            
            [[headerValue2 should] endWithString:kTestAccessToken2];
        });
    });
    
    describe(@"MSSDataSignIn Authentication callback", ^{
        
        __block NSURL *url;
        
        static NSString *const authCode = @"4/qQvXtvkdOQ40l_TJP1aMSSAFYLlRdbF.skN_a6n1694XmmS0T3UFEsO4VTJBjAI";
        SEL authSelector = @selector(authenticateUsingOAuthWithPath:code:redirectURI:success:failure:);
        
        NSURL *(^redirectURL)(NSString *) = ^NSURL *(NSString *authCode){
            return [NSURL URLWithString:[NSString stringWithFormat:@"%@:/oauth2callback?state=57934744&code=%@", [[NSBundle mainBundle] bundleIdentifier], authCode]];;
        };
        
        beforeEach(^{
            url = redirectURL(authCode);
        });
        
        it(@"should parse out the OAuth code from the 'application:openURL:sourceApplication:annotation:' callback", ^{
            setupMSSDataSignInInstance(nil);
            
            [[[[MSSDataSignIn sharedInstance] authClient] should] receive:authSelector
                                                            withArguments:any(), authCode, any(), any(), any()];
            
            [[MSSDataSignIn sharedInstance] handleURL:url sourceApplication:@"com.apple.mobilesMSSAFari" annotation:nil];
        });
        
        it(@"should call delegate 'finishedWithAuth:error:' with a credential object if authentication is successful", ^{
            NSObject<MSSSignInDelegate> *instanceDelegate = [KWMock mockForProtocol:@protocol(MSSSignInDelegate)];
            MSSAFOAuthCredential *credential = [MSSAFOAuthCredential credentialWithOAuthToken:kTestAccessToken1 tokenType:kTestTokenType];
            
            [[instanceDelegate should] receive:@selector(finishedWithAuth:error:) withArguments:credential, nil];
            setupMSSDataSignInInstance(instanceDelegate);
            
            MSSDataSignIn *sharedInstance = [MSSDataSignIn sharedInstance];
            sharedInstance.dataServiceURL = kTestDataServiceURL;
            [[sharedInstance authClient] stub:authSelector
                                    withBlock:^id(NSArray *params) {
                                        void (^success)(MSSAFOAuthCredential *) = params[3];
                                        success(credential);
                                        return nil;
                                    }];
            
            [[MSSDataSignIn sharedInstance] handleURL:url sourceApplication:@"com.apple.mobilesMSSAFari" annotation:nil];
        });
        
        it(@"should call delegate 'finishedWithAuth:error:' method with an error object if authentication fails", ^{
            NSObject<MSSSignInDelegate> *instanceDelegate = [KWMock mockForProtocol:@protocol(MSSSignInDelegate)];
            NSError *error = [NSError errorWithDomain:kMSSDataErrorDomain
                                                 code:MSSDatMSSAFailedAuthenticationError
                                             userInfo:@{ NSLocalizedFailureReasonErrorKey : @"Auth token does not match" }];
            
            [[instanceDelegate should] receive:@selector(finishedWithAuth:error:) withArguments:nil, error];
            setupMSSDataSignInInstance(instanceDelegate);
            
            [[[MSSDataSignIn sharedInstance] authClient] stub:authSelector
                                                    withBlock:^id(NSArray *params) {
                                                        void (^failure)(NSError *) = params[4];
                                                        failure(error);
                                                        return nil;
                                                    }];
            
            [[MSSDataSignIn sharedInstance] handleURL:url sourceApplication:@"com.apple.mobilesMSSAFari" annotation:nil];
        });
    });
    
    describe(@"Sign out and disconnect", ^{
        
        typedef void(^EnqueueBlock)(MSSAFHTTPRequestOperation *operation);
        
        void (^stubEnqueueOperation)(EnqueueBlock) = ^(EnqueueBlock block) {
            [[MSSDataSignIn sharedInstance].authClient stub:@selector(enqueueHTTPRequestOperation:)
                                                  withBlock:^id(NSArray *params) {
                                                      MSSAFHTTPRequestOperation *operation = params[0];
                                                      
                                                      if (block) {
                                                          block(operation);
                                                      }
                                                      
                                                      void (^completionBlock)(void) = [operation completionBlock];
                                                      completionBlock();
                                                      return nil;
                                                  }];
        };
        
        beforeEach(^{
            setupMSSDataSignInInstance(nil);
            setupForSuccessfulSilentAuth();
            
            [[[MSSAFOAuthCredential retrieveCredentialWithIdentifier:kMSSOAuthCredentialID] should] beNonNil];
        });
        
        afterEach(^{
            resetSharedInstance();
        });
        
        it(@"should remove the OAuth token from the keychain when signing out", ^{
            [[MSSDataSignIn sharedInstance] signOut];
        });
        
        it(@"'disconnect' should try to revoke OAuth token from the OpenID Connect server", ^{
            stubEnqueueOperation(^(MSSAFHTTPRequestOperation *operation){
                [[operation.request.URL.relativePath should] equal:@"/revoke"];
            });
            
            [[MSSAFOAuthCredential shouldEventually] receive:@selector(deleteCredentialWithIdentifier:)];
            [[MSSDataSignIn sharedInstance] disconnect];
        });
        
        it(@"should remove the OAuth token from the keychain if disconnect is successful", ^{
            stubEnqueueOperation(nil);
            
            [[MSSAFOAuthCredential shouldEventually] receive:@selector(deleteCredentialWithIdentifier:)];
            [[MSSDataSignIn sharedInstance] disconnect];
        });
        
        it(@"should not remove the OAuth token from the keychain if disconnect fails", ^{
            stubEnqueueOperation(^(MSSAFHTTPRequestOperation *operation){
                [operation setValue:[NSError errorWithDomain:@"FailedRevokeOperation" code:500 userInfo:nil]
                             forKey:@"HTTPError"];
            });
            
            [[MSSDataSignIn sharedInstance] disconnect];
            [[[MSSAFOAuthCredential retrieveCredentialWithIdentifier:kMSSOAuthCredentialID] shouldEventuallyBeforeTimingOutAfter(2)] beNonNil];
        });
    });
});

SPEC_END