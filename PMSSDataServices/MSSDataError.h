//
//  MSSDataError.h
//  
//
//  Created by Elliott Garcea on 2014-06-04.
//
//

#ifndef _MSSDataError_h
#define _MSSDataError_h

OBJC_EXTERN NSString *const kMSSOAuthCredentialID;
OBJC_EXTERN NSString *const kMSSDataServicesErrorDomain;

typedef NS_ENUM(NSInteger, MSSDataServicesErrorCode) {
    MSSDataServicesNoClientIDError,
    MSSDataServicesNoClientSecretError,
    MSSDataServicesNoOpenIDConnectURLError,
    MSSDataServicesFailedAuthenticationError,
    MSSDataServicesMalformedURLError,
    MSSDataServicesEmptyResponseData,
    MSSDataServicesMissingAccessToken,
    MSSDataServicesAuthorizationRequired,
    MSSDataServicesObjectIDRequired,
};

#endif
