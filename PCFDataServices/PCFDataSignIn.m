//
//  PCFDataSignIn.m
//  
//
//  Created by DX123-XL on 2014-05-20.
//
//

#import <AFNetworking/AFNetworking.h>
#import "AFOAuth2Client.h"

#import "PCFDataSignIn+Internal.h"

NSString *const kPCFOAuthCredentialID = @"PCFDataServicesOAuthCredential";

NSString *const kPCFDataServicesErrorDomain = @"PCFDataServicesError";

NSString *const kPCFOAuthPath = @"/o/oauth2/token";

static PCFDataSignIn *_sharedPCFDataSignIn;
static dispatch_once_t _sharedOnceToken;

static

@interface PCFDataSignIn ()

@property (nonatomic) AFOAuth2Client *authClient;

@end

@implementation PCFDataSignIn

+ (PCFDataSignIn *)sharedInstance
{
    dispatch_once(&_sharedOnceToken, ^{
        if (!_sharedPCFDataSignIn) {
            _sharedPCFDataSignIn = [[self alloc] init];
        }
    });
    return _sharedPCFDataSignIn;
}

+ (void)setSharedInstance:(PCFDataSignIn *)sharedInstance
{
    _sharedOnceToken = 0;
    _sharedPCFDataSignIn = sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.scopes = @[@"openid"];
    }
    return self;
}

- (void)callDelegateWithErrorCode:(PCFDataServicesErrorCode)code
                         userInfo:(NSDictionary *)userInfo
{
    if([self delegate]) {
        NSError *error = [NSError errorWithDomain:kPCFDataServicesErrorDomain code:(NSInteger)code userInfo:userInfo];
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
        
        _authClient.parameterEncoding = AFJSONParameterEncoding;
    }
    return _authClient;
}

- (NSString *)redirectURI
{
    static NSString *bundleIdentifier;
    if (!bundleIdentifier) {
        bundleIdentifier = [NSString stringWithFormat:@"%@:/oauth2callback", [[NSBundle mainBundle] bundleIdentifier]];
    }
    return bundleIdentifier;
}

- (BOOL)hasAuthInKeychain
{
    return [self credentialFromKeychain] ? YES : NO;
}

- (AFOAuthCredential *)credentialFromKeychain
{
    return [AFOAuthCredential retrieveCredentialWithIdentifier:kPCFOAuthCredentialID];
}

- (BOOL)storeCredential:(AFOAuthCredential *)credential
{
    return [AFOAuthCredential storeCredential:credential withIdentifier:kPCFOAuthCredentialID];
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
    if (!self.clientID) {
        [self callDelegateWithErrorCode:PCFDataServicesNoClientIDError userInfo:@{ NSLocalizedDescriptionKey : @"Missing client ID" }];
        return NO;
    }
    
    if (!self.clientSecret) {
        [self callDelegateWithErrorCode:PCFDataServicesNoClientSecretError userInfo:@{ NSLocalizedDescriptionKey : @"Missing client Secret" }];
        return NO;
    }
    
    if (!self.openIDConnectURL) {
        [self callDelegateWithErrorCode:PCFDataServicesNoOpenIDConnectURLError userInfo:@{ NSLocalizedDescriptionKey : @"Missing Open ID Connect URL" }];
        return NO;
    }
    
    AFOAuthCredential *savedCredential = [self credentialFromKeychain];
    if (savedCredential) {
        [self.authClient authenticateUsingOAuthWithPath:kPCFOAuthPath
                                           refreshToken:savedCredential.refreshToken
                                                success:^(AFOAuthCredential *credential) {
                                                    [self storeCredential:credential];
                                                    [self.delegate finishedWithAuth:credential error:nil];
                                                }
                                                failure:^(NSError *error) {
                                                    [self.delegate finishedWithAuth:nil error:error];
                                                }];
        return YES;
        
    }
    
    if (interactive) {
        [self performOAuthLogin];
        return YES;
    }
    
    return NO;
}

- (void)performOAuthLogin
{
    NSString *scopesString = [self.scopes componentsJoinedByString:@"%%20"];
    NSString *urlWithParams = [NSString stringWithFormat:@"%@?state=/profile&redirect_uri=%@&response_type=code&client_id=%@&approval_prompt=force&access_type=offline&scope=%@", self.openIDConnectURL, self.redirectURI, self.clientID, scopesString];
    NSURL *OAuthURL = [NSURL URLWithString:urlWithParams];
    
    if (!OAuthURL || !OAuthURL.scheme || !OAuthURL.host) {
        NSDictionary *userInfo =  @{ NSLocalizedDescriptionKey : @"The authorization URL was malformed. Please check the openIDConnectURL value." };
        [self callDelegateWithErrorCode:PCFDataServicesMalformedURLError userInfo:userInfo];
    }
    
    [[UIApplication sharedApplication] openURL:OAuthURL];
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
    if ([[url absoluteString] hasPrefix:[self redirectURI]]) {
        NSString *code = [self OAuthCodeFromRedirectURI:url];
        [self.authClient authenticateUsingOAuthWithPath:kPCFOAuthPath
                                                   code:code
                                            redirectURI:[self redirectURI]
                                                success:^(AFOAuthCredential *credential) {
                                                    [self storeCredential:credential];
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
    [AFOAuthCredential deleteCredentialWithIdentifier:kPCFOAuthCredentialID];
}

- (void)disconnect
{
    NSString *accessToken = [[self credentialFromKeychain] accessToken];
    if (accessToken) {
        [self.authClient deletePath:@"/revoke"
                         parameters:@{ @"token" : accessToken }
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                [self signOut];
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                [self callDelegateWithError:error];
                            }];
    } else {
        NSError *error = [NSError errorWithDomain:kPCFDataServicesErrorDomain
                                             code:PCFDataServicesMissingAccessToken
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
