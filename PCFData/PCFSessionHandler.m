//
//  PCFSessionHandler.m
//  PCFData
//
//  Created by DX122-XL on 2015-06-29.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "PCFSessionHandler.h"
#import "PCFDataConfig.h"

@interface PCFSessionHandler ()

@property (nonatomic, strong) NSURLSession *urlSession;

@end

@implementation PCFSessionHandler

- (instancetype)init {
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return self;
}

- (instancetype)initWithUrlSession:(NSURLSession *)urlSession {
    if (self = [super init]) {
        _urlSession = urlSession;
    }
    return self;
}

- (NSData *)performRequest:(NSURLRequest *)request response:(NSURLResponse *__autoreleasing *)response error:(NSError *__autoreleasing *)error {
    
    __block NSData *returnedData;
    __block NSURLResponse *returnedResponse;
    __block NSError *returnedError;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        returnedData = data;
        returnedResponse = response;
        returnedError = error;
       
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (response != nil) {
        *response = returnedResponse;
    }
    
    if (error != nil) {
        *error = returnedError;
    }
    
    return returnedData;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    
    // not clear on the difference between session and task specific authentication challenges, but if we want them handled the same we have to explicity make this call
    [self URLSession:session didReceiveChallenge:challenge completionHandler:completionHandler];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {

    [self respondToChallenge:challenge completionHandler:completionHandler];
}

- (void)respondToChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    NSURLProtectionSpace *protectionSpace = challenge.protectionSpace;
    
    if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [self respondToSslChallengeForProtectionSpace:protectionSpace completionHandler:completionHandler];
        
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)respondToSslChallengeForProtectionSpace:(NSURLProtectionSpace *)protectionSpace completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    
    if ([PCFDataConfig trustAllSSLCertificates]) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else if ([self appHasCertificatesPinned]) {
        [self respondWithPinnedCertificatesToChallengeForProtectionSpace:protectionSpace completionHandler:completionHandler];
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)respondWithPinnedCertificatesToChallengeForProtectionSpace:(NSURLProtectionSpace *)protectionSpace completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    NSData *remoteCertificateData = [self.class certificateDataFromProtectionSpace:protectionSpace];
    
    if ([self pinnedCertExistsMatchingRemoteCertData:remoteCertificateData]) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        completionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, nil);
    }
}

+ (NSData *)certificateDataFromProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(protectionSpace.serverTrust, 0);
    NSData *remoteCertificateData = CFBridgingRelease(SecCertificateCopyData(certificate));
    return remoteCertificateData;
}

- (BOOL)appHasCertificatesPinned {
    return [PCFDataConfig pinnedSSLCertificateNames].count > 0;
}

- (BOOL)pinnedCertExistsMatchingRemoteCertData:(NSData *)remoteCertData {
    NSArray *pinnedCertNames = [PCFDataConfig pinnedSSLCertificateNames];
    
    BOOL pinnedCertExistsMatchingRemoteCertData = NO;
    
    for (NSString *pinnedCertName in pinnedCertNames) {
        NSData *pinnedCertData = [self certificateFromMainBundleWithName:pinnedCertName];
        
        if ([remoteCertData isEqualToData:pinnedCertData]) {
            pinnedCertExistsMatchingRemoteCertData = YES;
            break;
        }
    }
    
    return pinnedCertExistsMatchingRemoteCertData;
}

- (NSData *)certificateFromMainBundleWithName:(NSString *)certificateName {
    NSString *certificatePath = [[NSBundle mainBundle] pathForResource:certificateName ofType:@"cer"];
    NSData *localCertificateData = [NSData dataWithContentsOfFile:certificatePath];
    return localCertificateData;
}

@end
