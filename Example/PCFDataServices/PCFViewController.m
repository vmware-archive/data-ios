//
//  PCFViewController.m
//  PCFDataServices
//
//  Created by DX123-XL on 2014-05-15.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Security/Security.h>
#import <AFNetworking/AFNetworking.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

#import "JRSwizzle.h"

#import "PCFViewController.h"

#import "AFOAuth2Client.h"

static NSString *const kOAuthServerURL = @"https://accounts.google.com/";
static NSString *const kClientID = @"958201466680-dd8mf4n57g6echld0km7senh80ahf1s6.apps.googleusercontent.com";
static NSString *const kClientSecret = @"cxmDXp45JC1zdqcgk1cSgmTZ";

static NSString *const kClientID2 = @"958201466680-j991tfkh55de7vrlaqfn06ntichvaum3.apps.googleusercontent.com";
static NSString *const kClientSecret2 = @"ceadvC4aJ8fjm34ZPeGoO8zw";

static NSString *const kRedirectURI1 = @"urn:ietf:wg:oauth:2.0:oob";
static NSString *const kRedirectURI2 = @"http://localhost";

@interface PCFViewController () <GPPSignInDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@property (strong, nonatomic) IBOutlet PCFButton *googleSignInButton;

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation PCFButton

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [super addTarget:target action:action forControlEvents:controlEvents];
}

@end

static GPPSignIn *signIn;

@implementation PCFViewController

- (void)openURL:(NSURL *)url
{
    NSLog(@"Open URL");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    signIn = [GPPSignIn sharedInstance];
    
    NSError *error;
    [UIApplication jr_swizzleMethod:@selector(openURL:) withMethod:@selector(openURL:) error:&error];
    if (error) {
        NSLog(@"Oh No!");
    }
    
    signIn.shouldFetchGooglePlusUser = YES;
    //signIn.shouldFetchGoogleUserEmail = YES;  // Uncomment to get the user's email
    
    signIn.clientID = kClientID2;
    
//    signIn.scopes = @[ kGTLAuthScopePlusLogin ];  // "https://www.googleapis.com/auth/plus.login" scope
    signIn.scopes = @[ @"profile" ];            // "profile" scope
    
    // Optional: declare signIn.actions, see "app activities"
    signIn.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInButtonPressed:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?state=/profile&redirect_uri=%@&response_type=code&client_id=%@&approval_prompt=force&access_type=offline&scope=openid%%20email%%20profile", @"com.pivotal.PCFDataServices:/oauth2callback", kClientID2]]];
//    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(self.view.frame) - 20, CGRectGetHeight(self.view.frame) - 20)];
//    [self.webView loadRequest:[NSURLRequest requestWithURL:]];
//    self.webView.delegate = self;
//    [self.view addSubview:self.webView];
}

#pragma mark - UIWebView

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *theTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	if( [theTitle rangeOfString:@"Success"].location != NSNotFound ) {
        
		NSArray *strings = [theTitle componentsSeparatedByString:@"&"];
		if ([strings count] > 0) {
			NSString *code = [[strings objectAtIndex:strings.count - 1] substringFromIndex:5];
            
            AFOAuth2Client *client = [AFOAuth2Client clientWithBaseURL:[NSURL URLWithString:kOAuthServerURL]
                                                              clientID:kClientID
                                                                secret:kClientSecret];
            [client authenticateUsingOAuthWithPath:@"/o/oauth2/token"
                                              code:code
                                       redirectURI:kRedirectURI1
                                           success:^(AFOAuthCredential *credential) {
                                               NSLog(@"Success");
                                               [AFOAuthCredential storeCredential:credential withIdentifier:@"PCFDataServicesID"];
                                               NSURLRequest *request = [client requestWithMethod:@"GET" path:@"https://www.googleapis.com/oauth2/v1/userinfo"
                                                                                      parameters:@{@"Authorization" : [NSString stringWithFormat:@"Bearer %@", credential.accessToken]}];
                                               
                                               AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                                                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                                                                       NSLog(@"GOT USER INFO");
                                                                                                                                   }
                                                                                                                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                                                                       NSLog(@"FAILURE");
                                                                                                                                   }];
                                               [operation start];
                                               [webView removeFromSuperview];
                                           } failure:^(NSError *error) {
                                               NSLog(@"Failure");
                                           }];
			[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
		}
	}
}

#pragma mark - Google+ sign-in

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error {
    NSLog(@"Received error %@ and auth object %@",error, auth);
}

- (void)presentSignInViewController:(UIViewController *)viewController {
    // This is an example of how you can implement it if your app is navigation-based.
    [[self navigationController] pushViewController:viewController animated:YES];
}

@end
