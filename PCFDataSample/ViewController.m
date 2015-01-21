//
//  ViewController.m
//  PCFDataSample
//
//  Created by DX122-XL on 2015-01-16.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "PCFReachability.h"
#import <PCFData/PCFData.h>

#define kAccessToken @"eyJhbGciOiJSUzI1NiJ9.eyJqdGkiOiI1MjhkZGMwNy0yNjBmLTRjZWEtYTVjOS04NmI4YTgwY2ZkNzkiLCJzdWIiOiIyOWY3OGUwNy05MzM3LTQ4MzItODE0YS00NDIxMGQ0OTc1NzAiLCJzY29wZSI6WyJzY2ltLnJlYWQiLCJjbG91ZF9jb250cm9sbGVyLmFkbWluIiwicGFzc3dvcmQud3JpdGUiLCJzY2ltLndyaXRlIiwib3BlbmlkIiwiY2xvdWRfY29udHJvbGxlci53cml0ZSIsImNsb3VkX2NvbnRyb2xsZXIucmVhZCJdLCJjbGllbnRfaWQiOiJjZiIsImNpZCI6ImNmIiwidXNlcl9pZCI6IjI5Zjc4ZTA3LTkzMzctNDgzMi04MTRhLTQ0MjEwZDQ5NzU3MCIsInVzZXJfbmFtZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbiIsImlhdCI6MTQyMTg3MjcxOCwiZXhwIjoxNDIxOTE1OTE4LCJpc3MiOiJodHRwczovL3VhYS5zaGVycnkud2luZS5jZi1hcHAuY29tL29hdXRoL3Rva2VuIiwiYXVkIjpbInNjaW0iLCJvcGVuaWQiLCJjbG91ZF9jb250cm9sbGVyIiwicGFzc3dvcmQiXX0.P4CcRtkxv_LoqWPl1zChGxMOdxumDKblJGNUEwa7VKvcGEtjtqdTrqrY0zsNxBPzbe7-3Oh-9EKPHAl3io-wMGuBhWRMY3fb_bfGKKftQxCpNK2PUEcrgodHIia_WcjUm-jImtDEo5sjRXkKDMfkkwQ2U34rXlweCV-Rq8lHGTgqbI0oM0UcbR0dFeUdnYdweAM-PB0tw7-QsHoYeg4oxYp_OTKzqtDYXO2euNUGgo5xWBMGC2MYvST8pj1OdF3XWB26_dejQEivA-27cE90St-UPrwKN6tQJI8HluqSKcridsEjaw65EwcFu3PrLDPNldvdHz0fogvZtTODMFzyqg"

@implementation ViewController

static NSString* const PCFDataRequestCache = @"PCFData:RequestCache";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [PCFData logLevel:PCFDataLogLevelDebug];
    
    self.object = [[PCFKeyValueObject alloc] initWithCollection:@"objects" key:@"key"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults addObserver:self forKeyPath:PCFDataRequestCache options:NSKeyValueObservingOptionNew context:0];
}

- (void)dealloc {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObserver:self forKeyPath:PCFDataRequestCache];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[NSUserDefaults class]]) {
        if ([keyPath isEqualToString:PCFDataRequestCache]) {
            NSString *content = [object objectForKey:PCFDataRequestCache];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@ changed.", PCFDataRequestCache);
                
                self.cachedContent.text = content;
            });
        }
    }
}

- (IBAction)fetchObject:(id)sender {
    [self.object getWithAccessToken:kAccessToken force:self.force completionBlock:^(PCFResponse *response) {
        [self handleResponse:response];
    }];
}

- (IBAction)saveObject:(id)sender {
    [self.object putWithAccessToken:kAccessToken value:self.textField.text force:self.force completionBlock:^(PCFResponse *response) {
        [self handleResponse:response];
    }];
}

- (IBAction)deleteObject:(id)sender {
    [self.object deleteWithAccessToken:kAccessToken force:self.force completionBlock:^(PCFResponse *response) {
        [self handleResponse:response];
    }];
}

- (BOOL)force {
    return !self.etagSwitch.isOn;
}

- (void)handleResponse:(PCFResponse *)response {
    
    PCFKeyValue *keyValue = (PCFKeyValue *)response.object;

    self.textField.text = keyValue.value;
    
    if (response.error) {
        NSLog(@"PCFResponse error: %@", response.error);
        
        NSString *errorCode = [NSString stringWithFormat: @"%d", (int) response.error.code];
        
        if (errorCode == nil || [errorCode isEqual:@""]) {
            errorCode = @"none";
        }
        
        NSString *errorDescription = [[response error] localizedDescription];
        
        if (errorDescription == nil) {
            errorDescription = @"";
        }
        
        [self.errorLabel setText:[NSString stringWithFormat:@"Error Code: %@\n\nDescription: %@", errorCode, errorDescription]];
    } else {
        NSLog(@"PCFResponse value: %@", keyValue.value);
        
        [self.errorLabel setText:@""];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end