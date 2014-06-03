//
//  PCFViewController.m
//  PCFDataServices
//
//  Created by DX123-XL on 2014-05-15.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Security/Security.h>
#import <AFNetworking/AFNetworking.h>

#import "PCFDataSignIn.h"

#import "PCFViewController.h"


static NSString *const kOAuthServerURL = @"http://cfmos-identity.cfapps.io";
static NSString *const kClientID = @"739e8ae7-e518-4eac-b100-ceec2dd65459";
static NSString *const kClientSecret = @"AON8owWAztcnrnWDyOb1j_WOIS0LrnFbVoAzUATAYEjO92LGaq4ZG60-TCAxM6hAStfdrj9rY29_t6dJ_yO2Vno";

@interface PCFViewController () <PCFSignInDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *userInfoButton;

@property (strong, nonatomic) PCFDataSignIn *signIn;

@end

@implementation PCFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.signIn = [PCFDataSignIn sharedInstance];
    
    self.signIn.openIDConnectURL = kOAuthServerURL;
    self.signIn.clientID = kClientID;
    self.signIn.clientSecret = kClientSecret;
    
    self.signIn.delegate = self;
    
    [self.signIn trySilentAuthentication];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signInButtonPressed:(id)sender
{
    [self.signIn authenticate];
}

- (IBAction)getUserInfoButtonPressed:(id)sender
{
}
#pragma mark - PCFDataSignInDelegate

- (void)finishedWithAuth:(AFOAuthCredential *)auth
                   error:(NSError *)error
{
    NSLog(@"Received error %@ and auth object %@",error, auth);
}

@end
