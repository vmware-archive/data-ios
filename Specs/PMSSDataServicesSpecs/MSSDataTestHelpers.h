//
//  MSSDataTestHelpers.h
//  MSSDataServices Spec
//
//  Created by Elliott Garcea on 2014-06-05.
//
//

#import <Foundation/Foundation.h>

@class MSSObject;

typedef void (^EnqueueAsyncBlock)(NSArray *);

void (^setupDefaultCredentialInKeychain)(void);

void (^setupCredentialInKeychain)(NSString *, NSString *, NSInteger expiresIn);

void (^setupForSuccessfulSilentAuth)(void);

void (^setupMSSDataSignInInstance)(id<MSSSignInDelegate>);

void (^stubKeychain)(AFOAuthCredential *);

NSError *(^unauthorizedError)(void);

void (^assertObjectEqual)(id, NSDictionary *, MSSObject *);

void (^verifyAuthorizationInRequest)(id, NSURLRequest *);

void (^stubPutAsyncCall)(EnqueueAsyncBlock);
void (^stubGetAsyncCall)(EnqueueAsyncBlock);
void (^stubDeleteAsyncCall)(EnqueueAsyncBlock);
