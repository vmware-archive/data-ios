//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import "MSSAFOAuth2Client.h"
#import "MSSAFNetworking.h"


#import "MSSDataSignIn+Internal.h"
#import "MSSDataError.h"


NSString *const kMSSOAuthCredentialID = @"MSSDataOAuthCredential";
NSString *const kMSSDataErrorDomain = @"MSSDataError";

NSString *const kMSSOAuthPath = @"/oauth/authorize";
NSString *const kMSSOAuthTokenPath = @"/token";
NSString *const kMSSOAuthAccessTokensPath = @"/api/tokens/access";

static MSSDataSignIn *_sharedMSSDataSignIn;
static dispatch_once_t _sharedOnceToken;

static

@interface MSSDataSignIn ()

@property (nonatomic) MSSAFOAuth2Client *authClient;
@property (nonatomic) MSSAFHTTPClient *dataServiceClient;

@end

@implementation MSSDataSignIn

+ (MSSDataSignIn *)sharedInstance
{
    dispatch_once(&_sharedOnceToken, ^{
        if (!_sharedMSSDataSignIn) {
            _sharedMSSDataSignIn = [[self alloc] init];
        }
    });
    return _sharedMSSDataSignIn;
}

+ (void)setSharedInstance:(MSSDataSignIn *)sharedInstance
{
    _sharedOnceToken = 0;
    _sharedMSSDataSignIn = sharedInstance;
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

- (void)callDelegateWithErrorCode:(MSSDataErrorCode)code
                         userInfo:(NSDictionary *)userInfo
{
    if ([self delegate]) {
        NSError *error = [NSError errorWithDomain:kMSSDataErrorDomain code:(NSInteger)code userInfo:userInfo];
        [self.delegate finishedWithAuth:nil error:error];
    }
}

- (MSSAFOAuth2Client *)authClient
{
    if (!_authClient || _authClient.clientID != self.clientID) {
        NSURL *baseURL = [NSURL URLWithString:self.openIDConnectURL];
        _authClient = [MSSAFOAuth2Client clientWithBaseURL:baseURL
                                               clientID:self.clientID
                                                 secret:self.clientSecret];
        
        _authClient.parameterEncoding = MSSAFFormURLParameterEncoding;
    }
    return _authClient;
}

- (MSSAFHTTPClient *)dataServiceClient:(NSError **)error
{
    if (!self.dataServiceURL) {
        @throw [NSException exceptionWithName:NSObjectNotAvailableException reason:@"Requires dataServiceURL value to be set." userInfo:nil];
    }
    
    if (![self hasAuthInKeychain]) {
        if (error) {
            *error = [NSError errorWithDomain:kMSSDataErrorDomain code:MSSDataAuthorizationRequired userInfo:@{ NSLocalizedDescriptionKey : @"No credentials found. Authentication required." }];
        }
        return nil;
    }
    
    if (!_dataServiceClient) {
        _dataServiceClient = [MSSAFHTTPClient clientWithBaseURL:[NSURL URLWithString:self.dataServiceURL]];
        
        _dataServiceClient.parameterEncoding = MSSAFJSONParameterEncoding;
        [self setAuthorizationHeaderOnClient:_dataServiceClient withCredential:self.credential];
    }
    
    return _dataServiceClient;
}

- (void)setAuthorizationHeaderOnClient:(MSSAFHTTPClient *)client
                        withCredential:(MSSAFOAuthCredential *)credential
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

- (MSSAFOAuthCredential *)credential
{
    return [MSSAFOAuthCredential retrieveCredentialWithIdentifier:kMSSOAuthCredentialID];
}

- (BOOL)storeCredentialInKeychain:(MSSAFOAuthCredential *)credential
{
    return [MSSAFOAuthCredential storeCredential:credential withIdentifier:kMSSOAuthCredentialID];
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
                                  success:(void (^)(MSSAFOAuthCredential *credential))success
                                  failure:(void (^)(NSError *error))failure
{
    if (!self.clientID) {
        [self callDelegateWithErrorCode:MSSDataNoClientIDError userInfo:@{ NSLocalizedDescriptionKey : @"Missing client ID" }];
        return NO;
    }
    
    if (!self.clientSecret) {
        [self callDelegateWithErrorCode:MSSDataNoClientSecretError userInfo:@{ NSLocalizedDescriptionKey : @"Missing client Secret" }];
        return NO;
    }
    
    if (!self.openIDConnectURL) {
        [self callDelegateWithErrorCode:MSSDataNoOpenIDConnectURLError userInfo:@{ NSLocalizedDescriptionKey : @"Missing Open ID Connect URL" }];
        return NO;
    }
    
    MSSAFOAuthCredential *savedCredential = [self credential];
    if (savedCredential) {
        
        void (^failureBlock)(NSError *) = ^(NSError *error) {
            
            if (error) {
                NSRange range = [error.localizedDescription rangeOfString:@"401"]; // unauthorized error
                if (range.location != NSNotFound) {
                   
                    // The saved credential has probably expired.  We need to clear it.
                    [self setCredential:nil];
                    
                    // If interactive login mode is requested, then go for it now.
                    if (interactive) {
                        [self performOAuthLogin];
                        return;
                    }
                }
            }
            
            if (failure) {
                failure(error);
            }
            
            [self.delegate finishedWithAuth:nil error:error];
        };
        
        void (^successBlock)(MSSAFOAuthCredential *) = ^(MSSAFOAuthCredential *credential) {
            if(success) {
                success(credential);
            }
            
            [self setCredential:credential];
            [self.delegate finishedWithAuth:credential error:nil];
        };
        
        [self.authClient authenticateUsingOAuthWithPath:kMSSOAuthTokenPath refreshToken:savedCredential.refreshToken success:successBlock failure:failureBlock];
        return YES;
    }
    
    if (interactive) {
        [self performOAuthLogin];
        return YES;
    }
    
    return NO;
}

- (void)setCredential:(MSSAFOAuthCredential *)credential
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
    
    NSURL *url = [NSURL URLWithString:kMSSOAuthPath relativeToURL:[NSURL URLWithString:self.openIDConnectURL]];
    NSURL *urlWithParams = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[kMSSOAuthPath rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", MSSAFQueryStringFromParametersWithEncoding(parameters, NSUTF8StringEncoding)]];
    
    if (!urlWithParams || !urlWithParams.scheme || !urlWithParams.host) {
        NSDictionary *userInfo =  @{ NSLocalizedDescriptionKey : @"The authorization URL was malformed. Please check the openIDConnectURL value." };
        [self callDelegateWithErrorCode:MSSDataMalformedURLError userInfo:userInfo];
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
        [self.authClient authenticateUsingOAuthWithPath:kMSSOAuthTokenPath
                                                   code:code
                                            redirectURI:[self redirectURI]
                                                success:^(MSSAFOAuthCredential *credential) {
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
    [MSSAFOAuthCredential deleteCredentialWithIdentifier:kMSSOAuthCredentialID];
}

- (void)disconnect
{
    NSString *accessToken = [[self credential] accessToken];
    if (accessToken) {
        [self.authClient getPath:kMSSOAuthAccessTokensPath
                      parameters:nil
                            success:^(MSSAFHTTPRequestOperation *operation, id responseObject) {
                                [self continueDisconnectWithAccessToken:accessToken responseObject:responseObject];
                            }
                            failure:^(MSSAFHTTPRequestOperation *operation, NSError *error) {
                                [self callDelegateWithError:error];
                            }];
    } else {
        NSError *error = [NSError errorWithDomain:kMSSDataErrorDomain
                                             code:MSSDataMissingAccessToken
                                         userInfo:@{ NSLocalizedFailureReasonErrorKey : @"Disconnect method called with no credential stored in keychain." }];
        [self callDelegateWithError:error];
    }
}

- (void)continueDisconnectWithAccessToken:(NSString*)accessToken responseObject:(id)responseObject
{
    NSError *error;
    id responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
    if (error) {
        [self callDelegateWithError:error];
        return;
    }
    
    long tokenId = [self findTokenIdFromResponse:responseDict matchingAccessToken:accessToken];
    if (tokenId == -1) {
        NSError *error = [NSError errorWithDomain:kMSSDataErrorDomain
                                             code:MSSDataMissingAccessToken
                                         userInfo:@{ NSLocalizedFailureReasonErrorKey : @"Token ID for current access token not found on server." }];
        [self callDelegateWithError:error];
        return;
    }
    
    NSString *deleteUrl = [NSString stringWithFormat:@"%@/%ld", kMSSOAuthAccessTokensPath, tokenId];
    [self.authClient deletePath:deleteUrl
                     parameters:nil
                        success:^(MSSAFHTTPRequestOperation *operation, id responseObject) {
                            [self signOut];
                        }
                        failure:^(MSSAFHTTPRequestOperation *operation, NSError *error) {
                            [self callDelegateWithError:error];
                        }];
}

- (long)findTokenIdFromResponse:(id)responseDict matchingAccessToken:(NSString*)accessToken
{
    for (id item in responseDict) {
        NSString *itemAccessToken = item[@"value"];
        if ([itemAccessToken isEqualToString:accessToken]) {
            return [item[@"id"] longValue];
        }
    }
    return -1;
}

- (void)callDelegateWithError:(NSError *)error
{
    if ([(NSObject *)self.delegate respondsToSelector:@selector(didDisconnectWithError:)]) {
        [self.delegate didDisconnectWithError:error];
    }
}

@end
