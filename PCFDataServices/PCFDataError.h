//
//  PCFDataError.h
//  
//
//  Created by Elliott Garcea on 2014-06-04.
//
//

#ifndef _PCFDataError_h
#define _PCFDataError_h

OBJC_EXTERN NSString *const kPCFOAuthCredentialID;
OBJC_EXTERN NSString *const kPCFDataServicesErrorDomain;

typedef NS_ENUM(NSInteger, PCFDataServicesErrorCode) {
    PCFDataServicesNoClientIDError,
    PCFDataServicesNoClientSecretError,
    PCFDataServicesNoOpenIDConnectURLError,
    PCFDataServicesFailedAuthenticationError,
    PCFDataServicesMalformedURLError,
    PCFDataServicesMissingAccessToken,
};

#endif
