//
//  PMSSDataSignIn.m
//  
//
//  Created by DX123-XL on 2014-05-20.
//
//

#import <AFNetworking/AFNetworking.h>

#import "AFOAuth2Client.h"
#import "PMSSDataSignIn+Internal.h"
#import "PMSSDataError.h"


NSString *const kPMSSOAuthCredentialID = @"PMSSDataServicesOAuthCredential";
NSString *const kPMSSDataServicesErrorDomain = @"PMSSDataServicesError";

NSString *const kPMSSOAuthPath = @"/oauth/authorize";
NSString *const kPMSSOAuthTokenPath = @"/token";
NSString *const kPMSSOAuthRevokePath = @"/revoke";

static PMSSDataSignIn *_sharedPMSSDataSignIn;
static dispatch_once_t _sharedOnceToken;

static

@interface PMSSDataSignIn ()

@property (nonatomic) AFOAuth2Client *authClient;
@property (nonatomic) AFHTTPClient *dataServiceClient;

@end

@implementation PMSSDataSignIn

+ (PMSSDataSignIn *)sharedInstance
{
    dispatch_once(&_sharedOnceToken, ^{
        if (!_sharedPMSSDataSignIn) {
            _sharedPMSSDataSignIn = [[self alloc] init];
        }
    });
    return _sharedPMSSDataSignIn;
}

+ (void)setSharedInstance:(PMSSDataSignIn *)sharedInstance
{
    _sharedOnceToken = 0;
    _sharedPMSSDataSignIn = sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.scopes = @[
                        @"openid",
                        @"offline_access",
                        ];
    }
    return self;
}

- (void)callDelegateWithErrorCode:(PMSSDataServicesErrorCode)code
                         userInfo:(NSDictionary *)userInfo
{
    if ([self delegate]) {
        NSError *error = [NSError errorWithDomain:kPMSSDataServicesErrorDomain code:(NSInteger)code userInfo:userInfo];
        [self.delegate finishedWithAuth:nil error:error];
    }
}

- (AFOAuth2Client *)authClient
{
    if (!_authClient || _authClient.clientID != self.clientID) {
        NSURL *baseURL = [NSURL URLWithString:self.openIDConnectURL];
        _authClient = [AFOAuth2Client clientWithBaseURL:baseURL
                                               clientID:self.clientID
                                                 secret:self.clientSecret];
        
        _authClient.parameterEncoding = AFFormURLParameterEncoding;
    }
    return _authClient;
}

- (AFHTTPClient *)dataServiceClient:(NSError **)error
{
    if (!self.dataServiceURL) {
        @throw [NSException exceptionWithName:NSObjectNotAvailableException reason:@"Requires dataServiceURL value to be set." userInfo:nil];
    }
    
    if (![self hasAuthInKeychain]) {
        if (error) {
            *error = [NSError errorWithDomain:kPMSSDataServicesErrorDomain code:PMSSDataServicesAuthorizationRequired userInfo:@{ NSLocalizedDescriptionKey : @"No credentials found. Authentication required." }];
        }
        return nil;
    }
    
    if (!_dataServiceClient) {
        _dataServiceClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:self.dataServiceURL]];
        
        _dataServiceClient.parameterEncoding = AFJSONParameterEncoding;
        [self setAuthorizationHeaderOnClient:_dataServiceClient withCredential:self.credential];
    }
    
    return _dataServiceClient;
}

- (void)setAuthorizationHeaderOnClient:(AFHTTPClient *)client
                        withCredential:(AFOAuthCredential *)credential
{
    [client setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", credential.accessToken]];
}

- (NSString *)redirectURI
{
    static NSString *bundleIdentifier;
    if (!bundleIdentifier) {
        bundleIdentifier = [NSString stringWithFormat:@"%@:/oauth2callback", [[NSBundle mainBundle] bundleIdentifier]];
    }
    return [bundleIdentifier lowercaseString];
}

- (BOOL)hasAuthInKeychain
{
    return [self credential] ? YES : NO;
}

- (AFOAuthCredential *)credential
{
    return [AFOAuthCredential retrieveCredentialWithIdentifier:kPMSSOAuthCredentialID];
}

- (BOOL)storeCredentialInKeychain:(AFOAuthCredential *)credential
{
    return [AFOAuthCredential storeCredential:credential withIdentifier:kPMSSOAuthCredentialID];
}

- (BOOL)trySilentAuthentication
{
    return [self authenticateWithInteractiveOption:NO];
}

- (void)authenticate
{
    [self authenticateWithInteractiveOption:YES];
}

- (BOOL)authenticateWithInteractiveOption:(BOOL)interactive
{
    return [self authenticateWithInteractiveOption:interactive success:nil failure:nil];
}

- (BOOL)authenticateWithInteractiveOption:(BOOL)interactive
                                  success:(void (^)(AFOAuthCredential *credential))success
                                  failure:(void (^)(NSError *error))failure
{
    if (!self.clientID) {
        [self callDelegateWithErrorCode:PMSSDataServicesNoClientIDError userInfo:@{ NSLocalizedDescriptionKey : @"Missing client ID" }];
        return NO;
    }
    
    if (!self.clientSecret) {
        [self callDelegateWithErrorCode:PMSSDataServicesNoClientSecretError userInfo:@{ NSLocalizedDescriptionKey : @"Missing client Secret" }];
        return NO;
    }
    
    if (!self.openIDConnectURL) {
        [self callDelegateWithErrorCode:PMSSDataServicesNoOpenIDConnectURLError userInfo:@{ NSLocalizedDescriptionKey : @"Missing Open ID Connect URL" }];
        return NO;
    }
    
    AFOAuthCredential *savedCredential = [self credential];
    if (savedCredential) {
        
        void (^failureBlock)(NSError *) = ^(NSError *error) {
            if (failure) {
                failure(error);
            }
            
            [self.delegate finishedWithAuth:nil error:error];
        };
        
        void (^successBlock)(AFOAuthCredential *) = ^(AFOAuthCredential *credential) {
            if(success) {
                success(credential);
            }
            
            [self setCredential:credential];
            [self.delegate finishedWithAuth:credential error:nil];
        };
        
        [self.authClient authenticateUsingOAuthWithPath:kPMSSOAuthTokenPath refreshToken:savedCredential.refreshToken success:successBlock failure:failureBlock];
        return YES;
    }
    
    if (interactive) {
        [self performOAuthLogin];
        return YES;
    }
    
    return NO;
}

- (void)setCredential:(AFOAuthCredential *)credential
{
    [self setAuthorizationHeaderOnClient:self.dataServiceClient withCredential:credential];
    [self storeCredentialInKeychain:credential];
}

- (void)performOAuthLogin
{
    NSDictionary *parameters = @{
                                 @"state" : @"/profile",
                                 @"redirect_uri" : self.redirectURI,
                                 @"response_type" : @"code",
                                 @"client_id" : self.clientID,
                                 @"approval_prompt" : @"force",
                                 @"scope" : [self.scopes componentsJoinedByString:@" "],
                                 };
    
    NSURL *url = [NSURL URLWithString:kPMSSOAuthPath relativeToURL:[NSURL URLWithString:self.openIDConnectURL]];
    NSURL *urlWithParams = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[kPMSSOAuthPath rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", AFQueryStringFromParametersWithEncoding(parameters, NSUTF8StringEncoding)]];
    
    if (!urlWithParams || !urlWithParams.scheme || !urlWithParams.host) {
        NSDictionary *userInfo =  @{ NSLocalizedDescriptionKey : @"The authorization URL was malformed. Please check the openIDConnectURL value." };
        [self callDelegateWithErrorCode:PMSSDataServicesMalformedURLError userInfo:userInfo];
    }
    
    [[UIApplication sharedApplication] openURL:urlWithParams];
}

- (NSString *)OAuthCodeFromRedirectURI:(NSURL *)redirectURI
{
    __block NSString *code;
    NSArray *pairs = [redirectURI.query componentsSeparatedByString:@"&"];
    [pairs enumerateObjectsUsingBlock:^(NSString *pair, NSUInteger idx, BOOL *stop) {
        if ([pair hasPrefix:@"code"]) {
            code = [pair substringFromIndex:5];
            *stop = YES;
        }
    }];
    return code;
}

- (BOOL)handleURL:(NSURL *)url
sourceApplication:(NSString *)sourceApplication
       annotation:(id)annotation
{
    if ([url.absoluteString.lowercaseString hasPrefix:self.redirectURI.lowercaseString]) {
        NSString *code = [self OAuthCodeFromRedirectURI:url];
        [self.authClient authenticateUsingOAuthWithPath:kPMSSOAuthTokenPath
                                                   code:code
                                            redirectURI:[self redirectURI]
                                                success:^(AFOAuthCredential *credential) {
                                                    [self setCredential:credential];
                                                    [self.delegate finishedWithAuth:credential error:nil];
                                                }
                                                failure:^(NSError *error) {
                                                    [self.delegate finishedWithAuth:nil error:error];
                                                }];
        return YES;
    }
    return NO;
}

- (void)signOut
{
    [AFOAuthCredential deleteCredentialWithIdentifier:kPMSSOAuthCredentialID];
}

- (void)disconnect
{
    NSString *accessToken = [[self credential] accessToken];
    if (accessToken) {
        [self.authClient deletePath:kPMSSOAuthRevokePath
                         parameters:@{ @"token" : accessToken }
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                [self signOut];
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                [self callDelegateWithError:error];
                            }];
    } else {
        NSError *error = [NSError errorWithDomain:kPMSSDataServicesErrorDomain
                                             code:PMSSDataServicesMissingAccessToken
                                         userInfo:@{ NSLocalizedFailureReasonErrorKey : @"Disconnect method called with no credential stored in keychain." }];
        [self callDelegateWithError:error];
    }
}

- (void)callDelegateWithError:(NSError *)error
{
    if ([(NSObject *)self.delegate respondsToSelector:@selector(didDisconnectWithError:)]) {
        [self.delegate didDisconnectWithError:error];
    }
}

@end
