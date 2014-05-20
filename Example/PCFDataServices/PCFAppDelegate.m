//
//  PCFAppDelegate.m
//  PCFDataServices
//
//  Created by DX123-XL on 2014-05-15.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <GooglePlus/GooglePlus.h>
#import <AFOAuth2Client/AFOAuth2Client.h>
#import <AFNetworking/AFNetworking.h>

#import "PCFAppDelegate.h"

@implementation PCFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    static NSString *const kOAuthServerURL = @"https://accounts.google.com/";
    static NSString *const kClientID2 = @"958201466680-j991tfkh55de7vrlaqfn06ntichvaum3.apps.googleusercontent.com";
    static NSString *const kClientSecret2 = @"ceadvC4aJ8fjm34ZPeGoO8zw";
    
    __block NSString *code;
    NSArray *pairs = [url.query componentsSeparatedByString:@"&"];
    [pairs enumerateObjectsUsingBlock:^(NSString *pair, NSUInteger idx, BOOL *stop) {
        if ([pair hasPrefix:@"code"]) {
            code = [pair substringFromIndex:5];
            *stop = YES;
        }
    }];
    
    AFOAuth2Client *client = [AFOAuth2Client clientWithBaseURL:[NSURL URLWithString:kOAuthServerURL]
                                                      clientID:kClientID2
                                                        secret:kClientSecret2];
    [client authenticateUsingOAuthWithPath:@"/o/oauth2/token"
                                      code:code
                               redirectURI:@"com.pivotal.PCFDataServices:/oauth2callback"
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
                                                                                                                               NSLog(@"FAILURE");                                                                  }];
                                       [operation start];
                                   } failure:^(NSError *error) {
                                       NSLog(@"Failure");
                                   }];

    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}

@end
