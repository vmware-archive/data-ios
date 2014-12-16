//
//  PCFLoggerTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-12-10.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PCFData/PCFData.h>
#import "PCFLogger.h"

@interface PCFLoggerTests : XCTestCase

@end

@implementation PCFLoggerTests

- (void)testLogLevelDebug {
    [PCFLogger sharedInstance].level = PCFLogLevelDebug;
    
    NSLog(@"=========== PCFLogLevelDebug ================");
    
    LogDebug(@"Log level %@: SUCCESS", @"Debug");
    LogInfo(@"Log level %@: SUCCESS", @"Info");
    LogWarning(@"Log level %@: SUCCESS", @"Warning");
    LogError(@"Log level %@: SUCCESS", @"Error");
    LogCritical(@"Log level %@: SUCCESS", @"Critical");
    
    NSLog(@"=============================================");
}

- (void)testLogLevelInfo {
    [PCFLogger sharedInstance].level = PCFLogLevelInfo;
    
    NSLog(@"=========== PCFLogLevelInfo =================");
    
    LogDebug(@"Log level %@: FAILURE", @"Debug");
    LogInfo(@"Log level %@: SUCCESS", @"Info");
    LogWarning(@"Log level %@: SUCCESS", @"Warning");
    LogError(@"Log level %@: SUCCESS", @"Error");
    LogCritical(@"Log level %@: SUCCESS", @"Critical");
    
    NSLog(@"=============================================");
}

- (void)testLogLevelWarning {
    [PCFLogger sharedInstance].level = PCFLogLevelWarning;
    
    NSLog(@"=========== PCFLogLevelWarning ==============");
    
    LogDebug(@"Log level %@: FAILURE", @"Debug");
    LogInfo(@"Log level %@: FAILURE", @"Info");
    LogWarning(@"Log level %@: SUCCESS", @"Warning");
    LogError(@"Log level %@: SUCCESS", @"Error");
    LogCritical(@"Log level %@: SUCCESS", @"Critical");
    
    NSLog(@"=============================================");
}

- (void)testLogLevelError {
    [PCFLogger sharedInstance].level = PCFLogLevelError;
    
    NSLog(@"=========== PCFLogLevelError ================");
    
    LogDebug(@"Log level %@: FAILURE", @"Debug");
    LogInfo(@"Log level %@: FAILURE", @"Info");
    LogWarning(@"Log level %@: FAILURE", @"Warning");
    LogError(@"Log level %@: SUCCESS", @"Error");
    LogCritical(@"Log level %@: SUCCESS", @"Critical");
    
    NSLog(@"=============================================");
}

- (void)testLogLevelCritical {
    [PCFLogger sharedInstance].level = PCFLogLevelCritical;
    
    NSLog(@"=========== PCFLogLevelCritical =============");
    
    LogDebug(@"Log level %@: FAILURE", @"Debug");
    LogInfo(@"Log level %@: FAILURE", @"Info");
    LogWarning(@"Log level %@: FAILURE", @"Warning");
    LogError(@"Log level %@: FAILURE", @"Error");
    LogCritical(@"Log level %@: SUCCESS", @"Critical");
    
    NSLog(@"=============================================");
}

- (void)testLogLevelNone {
    [PCFLogger sharedInstance].level = PCFLogLevelNone;
    
    NSLog(@"=========== PCFLogLevelNone =================");
    
    LogDebug(@"Log level %@: FAILURE", @"Debug");
    LogInfo(@"Log level %@: FAILURE", @"Info");
    LogWarning(@"Log level %@: FAILURE", @"Warning");
    LogError(@"Log level %@: FAILURE", @"Error");
    LogCritical(@"Log level %@: FAILURE", @"Critical");
    
    NSLog(@"=============================================");
}

@end
