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
    
    [PCFData syncWhenNetworkAvailableWithBlock:^() {
        [PCFData syncWithAccessToken:nil];
    }];
    
    return YES;
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [PCFData syncWithAccessToken:nil completionHandler:completionHandler];
}

@end
