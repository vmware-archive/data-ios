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

SPEC_BEGIN(PCFDataSignInSpec)

static NSString *const kTestOAuthToken = @"ya29.HQCrkKW12Yd9ZBoAAABMOFnwSb-LJUDm0MebYgoHls0zVNRrZYpDmpdpylIrEw";
static NSString *const kTestRefreshToken = @"1/5mSJo631AVmdw1rFUsxofZJnXprvs2-EZ8nLpCYtDJY";
static NSString *const kTestTokenType = @"Bearer";

static NSString *const kTestOpenIDConnectURL = @"https://testOpenIDConnectURL.com";

static NSString *const kTestClientID = @"TestClientID";
static NSString *const kTestClientSecret = @"TestClientSecret";

static NSString *const kTestBundleIndentifier = @"com.testbundleID.spec";

void (^resetSharedInstance)(void) = ^{
    [PCFDataSignIn setSharedInstance:nil];
};

void (^setupForSuccessfulSilentAuth)(void) = ^{
    AFOAuthCredential *cred = [AFOAuthCredential credentialWithOAuthToken:kTestOAuthToken tokenType:@"Bearer"];
    [cred setRefreshToken:kTestRefreshToken expiration:[NSDate dateWithTimeIntervalSinceNow:60 * 60]];
    [AFOAuthCredential storeCredential:cred withIdentifier:kPCFOAuthCredentialID];
    
    [[[PCFDataSignIn sharedInstance] authClient] stub:@selector(authenticateUsingOAuthWithPath:refreshToken:success:failure:)
                                            withBlock:^id(NSArray *params) {
                                                void (^success)(AFOAuthCredential *credential) = params[2];
                                                AFOAuthCredential *credential = [AFOAuthCredential credentialWithOAuthToken:kTestOAuthToken tokenType:kTestTokenType];
                                                [credential setRefreshToken:kTestRefreshToken expiration:[NSDate dateWithTimeIntervalSinceNow:3600]];
                                                success(credential);
                                                return nil;
                                            }];
};

void (^setupForFailedSilentAuth)(void) = ^{
    [AFOAuthCredential deleteCredentialWithIdentifier:kPCFOAuthCredentialID];
};

void (^setupPCFDataSignInInstance)(id<PCFSignInDelegate>) = ^(id<PCFSignInDelegate> delegate){
    PCFDataSignIn *instance = [PCFDataSignIn sharedInstance];
    [instance setOpenIDConnectURL:kTestOpenIDConnectURL];
    [instance setClientID:kTestClientID];
    [instance setClientSecret:kTestClientSecret];
    [instance setDelegate:delegate];
};

context(@"PCFDataSignIn Specification", ^{
    
    beforeEach(^{
        resetSharedInstance();
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
    
    describe(@"PCFDataSignIn authentication", ^{
        typedef void (^MethodBlock)(void);
        
        void (^setupDelegate)(void) = ^{
            PCFDataSignIn *sharedInstance = [PCFDataSignIn sharedInstance];
            NSObject<PCFSignInDelegate> *instanceDelegate = [KWMock mockForProtocol:@protocol(PCFSignInDelegate)];
            [[instanceDelegate should] receive:@selector(finishedWithAuth:error:) withArguments:nil, any()];
            sharedInstance.delegate = instanceDelegate;
        };
        
        it(@"should call delegate with error if authenticate is called while |clientID| is not set on PCFDataSignIn shared instance", ^{
            setupDelegate();
            
            PCFDataSignIn *sharedInstance = [PCFDataSignIn sharedInstance];
            [[sharedInstance.clientID should] beNil];
            [sharedInstance authenticate];
        });
        
        it(@"should call delegate with error if authenticate is called while |openIDConnectURL| is not set on PCFDataSignIn shared instance", ^{
            setupDelegate();
            
            PCFDataSignIn *sharedInstance = [PCFDataSignIn sharedInstance];
            [[sharedInstance.openIDConnectURL should] beNil];
            [sharedInstance authenticate];
        });
        
        describe(@"trySilentAuthentication ", ^{
            
            __block NSObject<PCFSignInDelegate> *instanceDelegate;
            
//            beforeAll(^{
//                [[NSBundle mainBundle] stub:@selector(bundleIdentifier) andReturn:kTestBundleIndentifier];
//            });
            
            beforeEach(^{
                instanceDelegate = [KWMock mockForProtocol:@protocol(PCFSignInDelegate)];
                setupPCFDataSignInInstance(instanceDelegate);
            });
            
            afterEach(^{
                instanceDelegate = nil;
            });
            
            it(@"should try authentication with stored credential before defaulting to sigining in through Mobile Safari", ^{
                PCFDataSignIn *sharedInstance = [PCFDataSignIn sharedInstance];
                [[sharedInstance should] receive:@selector(credentialFromKeychain)];
                [sharedInstance authenticate];
            });
            
            it(@"should call delegate finishedWithAuth:error: method with a populated AFOAuthCredential object when silent authentication succeeds", ^{
                setupForSuccessfulSilentAuth();
                
                PCFDataSignIn *sharedInstance = [PCFDataSignIn sharedInstance];
                [[instanceDelegate should] receive:@selector(finishedWithAuth:error:) withArguments:any(), nil];
                [sharedInstance authenticate];
            });
            
            it(@"should not call delegate finishedWithAuth:error: method when silent authentication fails", ^{
                PCFDataSignIn *sharedInstance = [PCFDataSignIn sharedInstance];
                
                setupForFailedSilentAuth();
                
                [[instanceDelegate shouldNotEventually] receive:@selector(finishedWithAuth:error:)];
                
                [sharedInstance authenticate];
            });
            
            it(@"should open Safari Mobile if silent auth fails to perform authentication", ^{
                PCFDataSignIn *sharedInstance = [PCFDataSignIn sharedInstance];
                setupForFailedSilentAuth();
                
                NSString *scopes = [sharedInstance.scopes componentsJoinedByString:@"%%20"];
                NSString *bundleID = [NSString stringWithFormat:@"%@:/oauth2callback", kTestBundleIndentifier];
                NSURL *expectedURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?state=/profile&redirect_uri=%@&response_type=code&client_id=%@&scope=%@", kTestOpenIDConnectURL, bundleID, kTestClientID, scopes]];
                [[[UIApplication sharedApplication] shouldEventually] receive:@selector(openURL:) withArguments:expectedURL];
                
                [sharedInstance authenticate];
            });
        });
    });
    
    describe(@"PCFDataSignIn Authentication callback", ^{
        static NSString *const authCode = @"4/qQvXtvkdOQ40l_TJP1aAFYLlRdbF.skN_a6n1694XmmS0T3UFEsO4VTJBjAI";
        SEL authSelector = @selector(authenticateUsingOAuthWithPath:code:redirectURI:success:failure:);
        
        NSURL *(^redirectURL)(NSString *) = ^NSURL *(NSString *authCode){
            return [NSURL URLWithString:[NSString stringWithFormat:@"%@:/oauth2callback?state=57934744&code=%@", [[NSBundle mainBundle] bundleIdentifier], authCode]];;
        };
        
        it(@"should parse out the OAuth code from the |application:openURL:sourceApplication:annotation:| callback", ^{
            NSURL *url = redirectURL(authCode);
            
            setupPCFDataSignInInstance(nil);
            
            [[[[PCFDataSignIn sharedInstance] authClient] should] receive:authSelector
                                                            withArguments:any(), authCode, any(), any(), any()];
            
            [[PCFDataSignIn sharedInstance] handleURL:url sourceApplication:@"com.apple.mobilesafari" annotation:nil];
        });
        
        it(@"should call delegate finishedWithAuth:error: with a credential object if authentication is successful", ^{
            NSURL *url = redirectURL(authCode);
            
            NSObject<PCFSignInDelegate> *instanceDelegate = [KWMock mockForProtocol:@protocol(PCFSignInDelegate)];
            AFOAuthCredential *credential = [AFOAuthCredential credentialWithOAuthToken:kTestOAuthToken tokenType:kTestTokenType];
            
            [[instanceDelegate should] receive:@selector(finishedWithAuth:error:) withArguments:credential, nil];
            setupPCFDataSignInInstance(instanceDelegate);
            
            [[[PCFDataSignIn sharedInstance] authClient] stub:authSelector withBlock:^id(NSArray *params) {
                void (^success)(AFOAuthCredential *) = params[3];
                success(credential);
                return nil;
            }];
            
            [[PCFDataSignIn sharedInstance] handleURL:url sourceApplication:@"com.apple.mobilesafari" annotation:nil];
        });
        
        it(@"should call delegate finishedWithAuth:error: method with an error object if authentication fails", ^{
            NSURL *url = redirectURL(authCode);
            
            NSObject<PCFSignInDelegate> *instanceDelegate = [KWMock mockForProtocol:@protocol(PCFSignInDelegate)];
            NSError *error = [NSError errorWithDomain:kPCFDataServicesErrorDomain
                                                 code:PCFDataServicesFailedAuthenticationError
                                             userInfo:@{ NSLocalizedFailureReasonErrorKey : @"Auth token does not match" }];
            
            [[instanceDelegate should] receive:@selector(finishedWithAuth:error:) withArguments:nil, error];
            setupPCFDataSignInInstance(instanceDelegate);
            
            [[[PCFDataSignIn sharedInstance] authClient] stub:authSelector withBlock:^id(NSArray *params) {
                void (^failure)(NSError *) = params[4];
                failure(error);
                return nil;
            }];
            
            [[PCFDataSignIn sharedInstance] handleURL:url sourceApplication:@"com.apple.mobilesafari" annotation:nil];
        });
    });
    
    describe(@"Sign out and disconnect", ^{
        
        beforeEach(^{
            setupPCFDataSignInInstance(nil);
            setupForSuccessfulSilentAuth();
            
            [[[AFOAuthCredential retrieveCredentialWithIdentifier:kPCFOAuthCredentialID] should] beNonNil];
        });
        
        afterEach(^{
            [[[AFOAuthCredential retrieveCredentialWithIdentifier:kPCFOAuthCredentialID] should] beNil];
            resetSharedInstance();
        });
        
        it(@"should remove the OAuth token from the keychain when signing out", ^{
            [[PCFDataSignIn sharedInstance] signOut];
        });
        
        it(@"should revoke OAuth token from the OpenID Connect server when disconnecting", ^{
            [[PCFDataSignIn sharedInstance].authClient stub:@selector(enqueueHTTPRequestOperation:)
                                                  withBlock:^id(NSArray *params) {
                                                      AFHTTPRequestOperation *operation = params[0];
                                                      [[[[operation request].URL relativeString] should] equal:@"revoke"];
                                                      return nil;
                                                  }];
            
            [[PCFDataSignIn sharedInstance] disconnect];
        });
        
        it(@"should remove the OAuth token from the keychain when disconnecting", ^{
            [[PCFDataSignIn sharedInstance].authClient stub:@selector(enqueueHTTPRequestOperation:) withBlock:^id(NSArray *params) {
                AFHTTPRequestOperation *operation = params[0];
                void (^completionBlock)(void) = [operation completionBlock];
                completionBlock();
                return nil;
            }];
            
            [[PCFDataSignIn sharedInstance] disconnect];
        });
    });
});

SPEC_END