//
//  PCFDataSignIn+Internal.h
//  PCFDataServices Spec
//
//  Created by DX123-XL on 2014-05-21.
//
//

#import "PCFDataSignIn.h"

@class AFOAuthCredential;

OBJC_EXTERN NSString *const kPCFOAuthCredentialID;
OBJC_EXTERN NSString *const kPCFDataServicesErrorDomain;

typedef NS_ENUM(NSInteger, PCFDataServicesErrorCode) {
    PCFDataServicesNoClientIDError,
    PCFDataServicesNoClientSecretError,
    PCFDataServicesNoOpenIDConnectURLError,
    PCFDataServicesFailedAuthenticationError,
    PCFDataServicesMalformedURLError,
    PCFDataServicesMissingAccessToken,
};

@interface PCFDataSignIn ()

// The client used to make the OAuth requests to the OpenID connect server.
- (AFOAuth2Client *)authClient;

- (AFOAuthCredential *)credential;

+ (void)setSharedInstance:(PCFDataSignIn *)sharedInstance;

@end
