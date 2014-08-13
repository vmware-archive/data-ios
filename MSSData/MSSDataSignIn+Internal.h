//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import "MSSDataSignIn.h"

@class MSSAFOAuthCredential, MSSDataServiceClient;

@interface MSSDataSignIn ()

// The client used to make the OAuth requests to the OpenID connect server.
- (MSSAFOAuth2Client *)authClient;

- (MSSAFOAuthCredential *)credential;

- (MSSAFHTTPClient *)dataServiceClient:(NSError **)error;

- (void)setCredential:(MSSAFOAuthCredential *)credential;

- (BOOL)authenticateWithInteractiveOption:(BOOL)interactive
                                  success:(void (^)(MSSAFOAuthCredential *credential))success
                                  failure:(void (^)(NSError *error))failure;

+ (void)setSharedInstance:(MSSDataSignIn *)sharedInstance;

@end
