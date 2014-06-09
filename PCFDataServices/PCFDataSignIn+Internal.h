//
//  PCFDataSignIn+Internal.h
//  PCFDataServices Spec
//
//  Created by DX123-XL on 2014-05-21.
//
//

#import "PCFDataSignIn.h"

@class AFOAuthCredential, PCFDataServiceClient;

@interface PCFDataSignIn ()

// The client used to make the OAuth requests to the OpenID connect server.
- (AFOAuth2Client *)authClient;

- (AFOAuthCredential *)credential;

- (PCFDataServiceClient *)dataServiceClient;

- (void)setCredential:(AFOAuthCredential *)credential;

+ (void)setSharedInstance:(PCFDataSignIn *)sharedInstance;

@end
