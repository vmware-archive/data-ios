//
//  PMSSDataError.h
//  
//
//  Created by Elliott Garcea on 2014-06-04.
//
//

#ifndef _PMSSDataError_h
#define _PMSSDataError_h

OBJC_EXTERN NSString *const kPMSSOAuthCredentialID;
OBJC_EXTERN NSString *const kPMSSDataServicesErrorDomain;

typedef NS_ENUM(NSInteger, PMSSDataServicesErrorCode) {
    PMSSDataServicesNoClientIDError,
    PMSSDataServicesNoClientSecretError,
    PMSSDataServicesNoOpenIDConnectURLError,
    PMSSDataServicesFailedAuthenticationError,
    PMSSDataServicesMalformedURLError,
    PMSSDataServicesEmptyResponseData,
    PMSSDataServicesMissingAccessToken,
    PMSSDataServicesAuthorizationRequired,
    PMSSDataServicesObjectIDRequired,
};

#endif
