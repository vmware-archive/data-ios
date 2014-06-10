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

- (AFHTTPClient *)dataServiceClient:(NSError **)error;

- (void)setCredential:(AFOAuthCredential *)credential;

- (BOOL)authenticateWithInteractiveOption:(BOOL)interactive
                                  success:(void (^)(AFOAuthCredential *credential))success
                                  failure:(void (^)(NSError *error))failure;

+ (void)setSharedInstance:(PCFDataSignIn *)sharedInstance;

@end
