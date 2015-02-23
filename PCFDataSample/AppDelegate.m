//
//  AppDelegate.m
//  PCFDataSample
//
//  Created by DX122-XL on 2015-01-16.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "AppDelegate.h"
#import <PCFData/PCFData.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [PCFData registerTokenProviderBlock:^() {
        return @"eyJhbGciOiJSUzI1NiJ9.eyJqdGkiOiJiNjIyMDI2OS1mNjhhLTQ5YmYtOTE0Yy02YmI2NGEyYWIzNWIiLCJzdWIiOiI5MWEzMWVmMi1mYTU3LTQ3ODItOWY2YS04YTMxODYwYjc5M2YiLCJzY29wZSI6WyJwYXNzd29yZC53cml0ZSIsIm9wZW5pZCIsImNsb3VkX2NvbnRyb2xsZXIud3JpdGUiLCJjbG91ZF9jb250cm9sbGVyLnJlYWQiXSwiY2xpZW50X2lkIjoiY2YiLCJjaWQiOiJjZiIsInVzZXJfaWQiOiI5MWEzMWVmMi1mYTU3LTQ3ODItOWY2YS04YTMxODYwYjc5M2YiLCJ1c2VyX25hbWUiOiJ0ZXN0IiwiZW1haWwiOiJ0ZXN0QHRlc3QuY29tIiwiaWF0IjoxNDIzMjQwOTI4LCJleHAiOjE0MjMyODQxMjgsImlzcyI6Imh0dHBzOi8vdWFhLnNoZXJyeS53aW5lLmNmLWFwcC5jb20vb2F1dGgvdG9rZW4iLCJhdWQiOlsib3BlbmlkIiwiY2xvdWRfY29udHJvbGxlciIsInBhc3N3b3JkIl19.PtgL7G-BD0De9ak8fBXYhCjVVWAwOFdj7SJ3T-nqmhpyHxwxrplUulxg6VyTgPXxCLr9yE__38E63_59vIEbHEZo552v773eSY2U5Vq9Rp3eTrmd1IGH55JajZvmdsAsLYjuCQUgsyzcdXht4WOJP2giQXA5ZydbaQRGadcq2UqWRsECbjkKt4-7D7_yc9_l6bZ_O0YCR-3540w5q_BTt04irWxatu_GcSgT42rPU9grwHprMUNynlyp2KcDwp1nhdvaugWOuGzWz5mv37dEnkz7DC7UmfBMNtiktx790FmdRogV_YRGekAvYxgWAUO5rRvUAeKdStya-Egh0DTw9g";
    }];
    
    [PCFData registerTokenInvalidatorBlock:^() {

    }];
    
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [PCFData performSyncWithCompletionHandler:completionHandler];
}

@end
