//
//  PCFDataSignIn+Internal.h
//  PCFDataServices Spec
//
//  Created by DX123-XL on 2014-05-21.
//
//

#import "PCFDataSignIn.h"

OBJC_EXTERN NSString *const kPCFOAuthCredentialID;

@interface PCFDataSignIn ()

+ (void)setSharedInstance:(PCFDataSignIn *)sharedInstance;

@end
