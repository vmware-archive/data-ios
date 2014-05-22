//
//  PCFDataSignIn.m
//  
//
//  Created by DX123-XL on 2014-05-20.
//
//

#import "PCFDataSignIn+Internal.h"
#import "AFOAuth2Client.h"

NSString *const kPCFOAuthCredentialID = @"PCFDataServicesOAuthCredential";

NSString *const kPCFDataServicesErrorDomain = @"PCFDataServicesError";

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
    if (!_authClient) {
        NSURL *baseURL = [NSURL URLWithString:self.openIDConnectURL];
        _authClient = [AFOAuth2Client clientWithBaseURL:baseURL
                                               clientID:self.clientID
                                                 secret:self.clientSecret];
    }
    return _authClient;
}

- (BOOL)hasAuthInKeychain
{
#warning TODO: Complete
    return YES;
}

- (BOOL)trySilentAuthentication
{
#warning TODO: Complete
    return YES;
}

- (void)authenticate
{
    if (!self.clientID) {
        [self callDelegateWithErrorCode:PCFDataServicesNoClientIDError userInfo:@{ NSLocalizedDescriptionKey : @"Missing client ID" }];
        return;
    }
    
    if (!self.clientSecret) {
        [self callDelegateWithErrorCode:PCFDataServicesNoClientSecretError userInfo:@{ NSLocalizedDescriptionKey : @"Missing client Secret" }];
        return;
    }
    
    if (!self.openIDConnectURL) {
        [self callDelegateWithErrorCode:PCFDataServicesNoOpenIDConnectURLError userInfo:@{ NSLocalizedDescriptionKey : @"Missing Open ID Connect URL" }];
        return;
    }
    
#warning TODO: try silent auth before jumping out to safari.
    
    NSString *bundleIdentifier = [NSString stringWithFormat:@"%@:/oauth2callback", [[NSBundle mainBundle] bundleIdentifier]];
    NSString *scopesString = [self.scopes componentsJoinedByString:@"%%20"];
    NSString *urlWithParams = [NSString stringWithFormat:@"%@?state=/profile&redirect_uri=%@&response_type=code&client_id=%@&approval_prompt=force&access_type=offline&scope=%@", self.openIDConnectURL, bundleIdentifier, self.clientID, scopesString];
    NSURL *authURL = [NSURL URLWithString:urlWithParams];
    
    if (!authURL || !authURL.scheme || !authURL.host) {
        NSDictionary *userInfo =  @{
                                    NSLocalizedDescriptionKey : @"The authorization URL was malformed. Please check the openIDConnectURL value.",
                                    };
        [self callDelegateWithErrorCode:PCFDataServicesMalformedURLError userInfo:userInfo];
        return;
    }
    
    [[UIApplication sharedApplication] openURL:authURL];
}

- (BOOL)handleURL:(NSURL *)url
sourceApplication:(NSString *)sourceApplication
       annotation:(id)annotation
{
    return YES;
}

- (void)signOut
{
#warning TODO: Complete
}

- (void)disconnect
{
#warning TODO: Complete
}

@end
