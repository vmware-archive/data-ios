//
//  PCFDataSignInSpec.m
//  PCFDataServices Spec
//
//  Created by DX123-XL on 2014-05-20.
//
//

#import <AFNetworking/AFNetworking.h>
#import "AFOAuth2Client.h"

#import "Kiwi.h"

#import "PCFDataSignIn+Internal.h"
#import "PCFDataError.h"
#import "PCFDataTestConstants.h"
#import "PCFDataTestHelpers.h"


SPEC_BEGIN(PCFDataSignInSpec)

void (^resetSharedInstance)(void) = ^{
    [PCFDataSignIn setSharedInstance:nil];
};

void (^setupForFailedSilentAuth)(void) = ^{
    [AFOAuthCredential deleteCredentialWithIdentifier:kPCFOAuthCredentialID];
};

context(@"PCFDataSignIn Specification", ^{
    
    __block AFOAuthCredential *credential;
    
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
    
    describe(@"PCFDataSignIn shared instance initialization", ^{
        
        it(@"should initialize with the |openid| value in the scope property.", ^{
            NSArray *scopes = [[PCFDataSignIn sharedInstance] scopes];
            [[theValue([scopes containsObject:@"openid"]) should] beTrue];
        });
        
        it(@"should initialize with nil clientID", ^{
            [[[[PCFDataSignIn sharedInstance] clientID] should] beNil];
        });
    });
    
    describe(@"call delegate with error during authentication", ^{
        
        __block PCFDataSignIn *sharedInstance;
        
        beforeEach(^{
            sharedInstance = [PCFDataSignIn sharedInstance];
            NSObject<PCFSignInDelegate> *instanceDelegate = [KWMock mockForProtocol:@protocol(PCFSignInDelegate)];
            [[instanceDelegate should] receive:@selector(finishedWithAuth:error:) withArguments:nil, any()];
            sharedInstance.delegate = instanceDelegate;
        });
        
        it(@"should call delegate with error if authenticate is called while 'clientID' is not set on PCFDataSignIn shared instance", ^{
            [[sharedInstance.clientID should] beNil];
            [sharedInstance authenticate];
        });
        
        it(@"should call delegate with error if authenticate is called while 'openIDConnectURL' is not set on PCFDataSignIn shared instance", ^{
            [[sharedInstance.openIDConnectURL should] beNil];
            [sharedInstance authenticate];
        });
    });
        
    describe(@"trySilentAuthentication ", ^{
        
        __block NSObject<PCFSignInDelegate> *instanceDelegate;
        __block PCFDataSignIn *sharedInstance;
        
        beforeEach(^{
            instanceDelegate = [KWMock mockForProtocol:@protocol(PCFSignInDelegate)];
            setupPCFDataSignInInstance(instanceDelegate);
            sharedInstance = [PCFDataSignIn sharedInstance];
        });
        
        afterEach(^{
            instanceDelegate = nil;
        });
        
        it(@"should try authentication with stored credential before defaulting to sigining in through Mobile Safari", ^{
            [[sharedInstance should] receive:@selector(credential)];
            [sharedInstance authenticate];
        });
        
        it(@"should call delegate 'finishedWithAuth:error:' method with a populated AFOAuthCredential object when silent authentication succeeds", ^{
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
        
        it(@"should open Safari Mobile if silent auth fails to perform authentication", ^{
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
            
            AFHTTPClient *client = [sharedInstance dataServiceClient:nil];
            NSString *headerValue1 = [client defaultValueForHeader:@"Authorization"];
            [[headerValue1 shouldNot] beNil];
            
            [sharedInstance trySilentAuthentication];
            
            NSString *headerValue2 = [client defaultValueForHeader:@"Authorization"];
            [[headerValue2 shouldNot] beNil];
            [[headerValue2 shouldNot] equal:headerValue1];
            
            [[headerValue2 should] endWithString:kTestAccessToken2];
        });
    });
    
    describe(@"PCFDataSignIn Authentication callback", ^{
        
        __block NSURL *url;
        
        static NSString *const authCode = @"4/qQvXtvkdOQ40l_TJP1aAFYLlRdbF.skN_a6n1694XmmS0T3UFEsO4VTJBjAI";
        SEL authSelector = @selector(authenticateUsingOAuthWithPath:code:redirectURI:success:failure:);
        
        NSURL *(^redirectURL)(NSString *) = ^NSURL *(NSString *authCode){
            return [NSURL URLWithString:[NSString stringWithFormat:@"%@:/oauth2callback?state=57934744&code=%@", [[NSBundle mainBundle] bundleIdentifier], authCode]];;
        };
        
        beforeEach(^{
            url = redirectURL(authCode);
        });
        
        it(@"should parse out the OAuth code from the 'application:openURL:sourceApplication:annotation:' callback", ^{
            setupPCFDataSignInInstance(nil);
            
            [[[[PCFDataSignIn sharedInstance] authClient] should] receive:authSelector
                                                            withArguments:any(), authCode, any(), any(), any()];
            
            [[PCFDataSignIn sharedInstance] handleURL:url sourceApplication:@"com.apple.mobilesafari" annotation:nil];
        });
        
        it(@"should call delegate 'finishedWithAuth:error:' with a credential object if authentication is successful", ^{
            NSObject<PCFSignInDelegate> *instanceDelegate = [KWMock mockForProtocol:@protocol(PCFSignInDelegate)];
            AFOAuthCredential *credential = [AFOAuthCredential credentialWithOAuthToken:kTestAccessToken1 tokenType:kTestTokenType];
            
            [[instanceDelegate should] receive:@selector(finishedWithAuth:error:) withArguments:credential, nil];
            setupPCFDataSignInInstance(instanceDelegate);
            
            PCFDataSignIn *sharedInstance = [PCFDataSignIn sharedInstance];
            sharedInstance.dataServiceURL = kTestDataServiceURL;
            [[sharedInstance authClient] stub:authSelector
                                    withBlock:^id(NSArray *params) {
                                        void (^success)(AFOAuthCredential *) = params[3];
                                        success(credential);
                                        return nil;
                                    }];
            
            [[PCFDataSignIn sharedInstance] handleURL:url sourceApplication:@"com.apple.mobilesafari" annotation:nil];
        });
        
        it(@"should call delegate 'finishedWithAuth:error:' method with an error object if authentication fails", ^{
            NSObject<PCFSignInDelegate> *instanceDelegate = [KWMock mockForProtocol:@protocol(PCFSignInDelegate)];
            NSError *error = [NSError errorWithDomain:kPCFDataServicesErrorDomain
                                                 code:PCFDataServicesFailedAuthenticationError
                                             userInfo:@{ NSLocalizedFailureReasonErrorKey : @"Auth token does not match" }];
            
            [[instanceDelegate should] receive:@selector(finishedWithAuth:error:) withArguments:nil, error];
            setupPCFDataSignInInstance(instanceDelegate);
            
            [[[PCFDataSignIn sharedInstance] authClient] stub:authSelector
                                                    withBlock:^id(NSArray *params) {
                                                        void (^failure)(NSError *) = params[4];
                                                        failure(error);
                                                        return nil;
                                                    }];
            
            [[PCFDataSignIn sharedInstance] handleURL:url sourceApplication:@"com.apple.mobilesafari" annotation:nil];
        });
    });
    
    describe(@"Sign out and disconnect", ^{
        
        typedef void(^EnqueueBlock)(AFHTTPRequestOperation *operation);
        
        void (^stubEnqueueOperation)(EnqueueBlock) = ^(EnqueueBlock block) {
            [[PCFDataSignIn sharedInstance].authClient stub:@selector(enqueueHTTPRequestOperation:)
                                                  withBlock:^id(NSArray *params) {
                                                      AFHTTPRequestOperation *operation = params[0];
                                                      
                                                      if (block) {
                                                          block(operation);
                                                      }
                                                      
                                                      void (^completionBlock)(void) = [operation completionBlock];
                                                      completionBlock();
                                                      return nil;
                                                  }];
        };
        
        beforeEach(^{
            setupPCFDataSignInInstance(nil);
            setupForSuccessfulSilentAuth();
            
            [[[AFOAuthCredential retrieveCredentialWithIdentifier:kPCFOAuthCredentialID] should] beNonNil];
        });
        
        afterEach(^{
            resetSharedInstance();
        });
        
        it(@"should remove the OAuth token from the keychain when signing out", ^{
            [[PCFDataSignIn sharedInstance] signOut];
        });
        
        it(@"'disconnect' should try to revoke OAuth token from the OpenID Connect server", ^{
            stubEnqueueOperation(^(AFHTTPRequestOperation *operation){
                [[operation.request.URL.relativePath should] equal:@"/revoke"];
            });
            
            [[AFOAuthCredential shouldEventually] receive:@selector(deleteCredentialWithIdentifier:)];
            [[PCFDataSignIn sharedInstance] disconnect];
        });
        
        it(@"should remove the OAuth token from the keychain if disconnect is successful", ^{
            stubEnqueueOperation(nil);
            
            [[AFOAuthCredential shouldEventually] receive:@selector(deleteCredentialWithIdentifier:)];
            [[PCFDataSignIn sharedInstance] disconnect];
        });
        
        it(@"should not remove the OAuth token from the keychain if disconnect fails", ^{
            stubEnqueueOperation(^(AFHTTPRequestOperation *operation){
                [operation setValue:[NSError errorWithDomain:@"FailedRevokeOperation" code:500 userInfo:nil]
                             forKey:@"HTTPError"];
            });
            
            [[PCFDataSignIn sharedInstance] disconnect];
            [[[AFOAuthCredential retrieveCredentialWithIdentifier:kPCFOAuthCredentialID] shouldEventuallyBeforeTimingOutAfter(2)] beNonNil];
        });
    });
});

SPEC_END