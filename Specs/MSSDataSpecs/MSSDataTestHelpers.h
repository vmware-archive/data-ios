//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MSSDataObject;

typedef void (^EnqueueAsyncBlock)(NSArray *);

void (^setupDefaultCredentialInKeychain)(void);

void (^setupCredentialInKeychain)(NSString *, NSString *, NSInteger expiresIn);

void (^setupForSuccessfulSilentAuth)(void);

void (^setupMSSDataSignInInstance)(id<MSSSignInDelegate>);

void (^stubKeychain)(AFOAuthCredential *);

NSError *(^unauthorizedError)(void);

void (^assertObjectEqual)(id, NSDictionary *, MSSDataObject *);

void (^verifyAuthorizationInRequest)(id, NSURLRequest *);

void (^stubPutAsyncCall)(EnqueueAsyncBlock);
void (^stubGetAsyncCall)(EnqueueAsyncBlock);
void (^stubDeleteAsyncCall)(EnqueueAsyncBlock);
