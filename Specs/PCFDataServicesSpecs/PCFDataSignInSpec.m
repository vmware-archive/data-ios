//
//  PCFDataSignInSpec.m
//  PCFDataServices Spec
//
//  Created by DX123-XL on 2014-05-20.
//
//

#import "Kiwi.h"

#import "PCFDataSignIn+Internal.h"

#import "AFOAuth2Client.h"

SPEC_BEGIN(PCFDataSignInSpec)

static NSString *const kTestOAuthToken = @"";

static NSString *const kTestOpenIDConnectURL = @"https://testOpenIDConnectURL.com";

static NSString *const kTestClientID = @"TestClientID";

static NSString *const kTestBundleIndentifier = @"com.testbundleID.spec";

void (^resetSharedInstance)(void) = ^{
    [PCFDataSignIn setSharedInstance:nil];
};

void (^setupForSuccessfulSilentAuth)(void) = ^{
    AFOAuthCredential *cred = [AFOAuthCredential credentialWithOAuthToken:kTestOAuthToken tokenType:@"Bearer"];
    [AFOAuthCredential storeCredential:cred withIdentifier:kPCFOAuthCredentialID];
};

void (^setupForFailedSilentAuth)(void) = ^{
    [AFOAuthCredential deleteCredentialWithIdentifier:kPCFOAuthCredentialID];
};

void (^setupPCFDataSignInInstance)(id<PCFSignInDelegate>) = ^(id<PCFSignInDelegate> delegate){
    PCFDataSignIn *instance = [PCFDataSignIn sharedInstance];
    [instance setOpenIDConnectURL:kTestOpenIDConnectURL];
    [instance setClientID:kTestClientID];
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
        
        void (^shouldRaiseInvalidArguementException)(MethodBlock) = ^(MethodBlock block){
            [[theBlock(^{
                block();
            }) should] raiseWithName:NSInvalidArgumentException];
        };
        
        it(@"should throw an exception if authenticate is called while |clientID| is not set on PCFDataSignIn shared instance", ^{
            PCFDataSignIn *sharedInstance = [PCFDataSignIn sharedInstance];
            
            [[sharedInstance.clientID should] beNil];
            
            shouldRaiseInvalidArguementException(^{
                [sharedInstance authenticate];
            });
        });
        
        it(@"should throw an exception if authenticate is called while |openIDConnectURL| is not set on PCFDataSignIn shared instance", ^{
            PCFDataSignIn *sharedInstance = [PCFDataSignIn sharedInstance];
            
            [[sharedInstance.openIDConnectURL should] beNil];
            
            shouldRaiseInvalidArguementException(^{
                [[PCFDataSignIn sharedInstance] authenticate];
            });
        });
        
        describe(@"trySilentAuthentication ", ^{
            
            __block NSObject<PCFSignInDelegate> *instanceDelegate;
            
            beforeAll(^{
                [[NSBundle mainBundle] stub:@selector(bundleIdentifier) andReturn:kTestBundleIndentifier];
            });
            
            beforeEach(^{
                instanceDelegate = [KWMock mockForProtocol:@protocol(PCFSignInDelegate)];
                setupPCFDataSignInInstance(instanceDelegate);
            });
            
            afterEach(^{
                instanceDelegate = nil;
            });
            
            it(@"should try silent authentication before defaulting to sigining in through Mobile Safari", ^{
                PCFDataSignIn *sharedInstance = [PCFDataSignIn sharedInstance];
                [[sharedInstance shouldEventually] receive:@selector(trySilentAuthentication)];
                [sharedInstance authenticate];
            });
            
            it(@"should call delegate finishedWithAuth:error: method with a populated AFOAuthCredential object when silent authentication succeeds", ^{
                PCFDataSignIn *sharedInstance = [PCFDataSignIn sharedInstance];
                
                setupForSuccessfulSilentAuth();
                
                [[instanceDelegate shouldEventually] receive:@selector(finishedWithAuth:error:)];
                
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
        it(@"PCFDataSignIn instance parses out the OAuth code from the application:openURL:sourceApplication:annotation: callback", ^{
//            [[PCFDataSignIn sharedInstance] handleURL:<#(NSURL *)#> sourceApplication:<#(NSString *)#> annotation:<#(id)#>];
        });
    });
    
});

SPEC_END