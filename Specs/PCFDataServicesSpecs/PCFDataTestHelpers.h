//
//  PCFDataTestHelpers.h
//  PCFDataServices Spec
//
//  Created by Elliott Garcea on 2014-06-05.
//
//

#import <Foundation/Foundation.h>

@class PCFObject;

typedef void (^EnqueueAsyncBlock)(NSArray *);

void (^setupDefaultCredentialInKeychain)(void);

void (^setupCredentialInKeychain)(NSString *, NSString *, NSInteger expiresIn);

void (^setupForSuccessfulSilentAuth)(void);

void (^setupPCFDataSignInInstance)(id<PCFSignInDelegate>);

void (^stubKeychain)(AFOAuthCredential *);

NSError *(^unauthorizedError)(void);

void (^assertObjectEqual)(id, NSDictionary *, PCFObject *);

void (^verifyAuthorizationInRequest)(id, NSURLRequest *);

void (^stubPutAsyncCall)(EnqueueAsyncBlock);
void (^stubGetAsyncCall)(EnqueueAsyncBlock);
void (^stubDeleteAsyncCall)(EnqueueAsyncBlock);
