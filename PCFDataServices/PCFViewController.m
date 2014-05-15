//
//  PCFViewController.m
//  PCFDataServices
//
//  Created by DX123-XL on 2014-05-15.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Security/SecItem.h>
#import <AFNetworking/AFNetworking.h>

#import "PCFViewController.h"
#import "PCFTableViewController.h"

#import "AFOAuth2Client.h"

static NSString *const kOAuthServerURL = @"https://accounts.google.com/";
static NSString *const kClientID = @"958201466680-dd8mf4n57g6echld0km7senh80ahf1s6.apps.googleusercontent.com";
static NSString *const kClientSecret = @"cxmDXp45JC1zdqcgk1cSgmTZ";

static NSString *const kClientID2 = @"958201466680.apps.googleusercontent.com";

static NSString *const kRedirectURI1 = @"urn:ietf:wg:oauth:2.0:oob";
static NSString *const kRedirectURI2 = @"http://localhost";

@interface PCFViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation PCFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInButtonPressed:(id)sender
{
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(self.view.frame) - 20, CGRectGetHeight(self.view.frame) - 20)];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://accounts.google.com/o/oauth2/auth?state=/profile&redirect_uri=%@&response_type=code&client_id=%@&approval_prompt=force&access_type=offline&scope=openid%%20email%%20profile", kRedirectURI1, kClientID]]]];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
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

@end
