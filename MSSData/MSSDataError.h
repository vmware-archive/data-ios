//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#ifndef _MSSDataError_h
#define _MSSDataError_h

OBJC_EXTERN NSString *const kMSSOAuthCredentialID;
OBJC_EXTERN NSString *const kMSSDataErrorDomain;

typedef NS_ENUM(NSInteger, MSSDataErrorCode) {
    MSSDataNoClientIDError,
    MSSDataNoClientSecretError,
    MSSDataNoOpenIDConnectURLError,
    MSSDataMSSAFailedAuthenticationError,
    MSSDataMalformedURLError,
    MSSDataEmptyResponseData,
    MSSDataMissingAccessToken,
    MSSDataAuthorizationRequired,
    MSSDataObjectIDRequired,
};

#endif
