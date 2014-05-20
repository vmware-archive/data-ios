//
//  PCFDataSignIn.h
//  
//
//  Created by DX123-XL on 2014-05-20.
//
//

#import <Foundation/Foundation.h>

@class AFOAuthCredential;

@protocol PCFSignInDelegate

// The authorization has finished and is successful if |error| is |nil|.
- (void)finishedWithAuth:(AFOAuthCredential *)auth
                   error:(NSError *)error;

// Finished disconnecting user from the app.
// The operation was successful if |error| is |nil|.
@optional
- (void)didDisconnectWithError:(NSError *)error;

@end

@interface PCFDataSignIn : NSObject

// The credential object for the current user.
@property(nonatomic, strong, readonly) AFOAuthCredential *credential;

// A JSON Web Token identifying the user. Send this token to your server to
// authenticate the user on the server. For more information on JWTs, see
// http://tools.ietf.org/html/draft-ietf-oauth-json-web-token-05
@property(nonatomic, strong, readonly) NSString *idToken;

// The client ID of the app from the Open ID Connection console.
// Must set for sign-in to work.
@property(nonatomic, copy) NSString *clientID;

// The OpenID Connect Authentication UI URL endpoint
// Must be set for sign-in to work.
@property(nonatomic, copy) NSString *openIDConnectURL;

// The API scopes requested by the app in an array of NSStrings.
// The default value is |@[@"openid"]|.
@property(nonatomic, copy) NSArray *scopes;

// The object to be notified when authentication is finished.
@property(nonatomic, weak) id<PCFSignInDelegate> delegate;

// Returns a shared PCFDataSignIn instance.
+ (PCFDataSignIn *)sharedInstance;

// Checks whether the user has either currently signed in or has previous
// authentication saved in keychain.
- (BOOL)hasAuthInKeychain;

// Attempts to authenticate silently without user interaction.
// Returns |YES| and calls the delegate if the user has either currently signed
// in or has previous authentication saved in keychain.
// Note that if the previous authentication was revoked by the user, this method
// still returns |YES| but |finishedWithAuth:error:| callback will indicate
// that authentication has failed.
- (BOOL)trySilentAuthentication;

// Starts the authentication process. Set |attemptSSO| to try single sign-on.
// If |attemptSSO| is true, try to authenticate with the Google+ app, if
// installed. If false, always use Google+ via Chrome or Mobile Safari for
// authentication. The delegate will be called at the end of this process.
// Note that this method should not be called when the app is starting up,
// (e.g in application:didFinishLaunchingWithOptions:). Instead use the
// |trySilentAuthentication| method.
- (void)authenticate;

// This method should be called from your |UIApplicationDelegate|'s
// |application:openURL:sourceApplication:annotation|. Returns |YES| if
// |PCFDataSignIn| handled this URL.
- (BOOL)handleURL:(NSURL *)url
sourceApplication:(NSString *)sourceApplication
       annotation:(id)annotation;


// Removes the OAuth 2.0 token from the keychain.
- (void)signOut;

// Disconnects the user from the app and revokes previous authentication.
// If the operation succeeds, the OAuth 2.0 token is also removed from keychain.
// The token is needed to disconnect so do not call |signOut| if |disconnect| is
// to be called.
- (void)disconnect;

@end
