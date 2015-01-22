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
#import "PCFDataLogger.h"

@interface PCFLoggerTests : XCTestCase

@end

@implementation PCFLoggerTests

- (void)testLogLevelDebug {
    [PCFDataLogger sharedInstance].level = PCFDataLogLevelDebug;
    
    NSLog(@"=========== PCFDataLogLevelDebug ================");
    
    LogDebug(@"Log level %@: SUCCESS", @"Debug");
    LogInfo(@"Log level %@: SUCCESS", @"Info");
    LogWarning(@"Log level %@: SUCCESS", @"Warning");
    LogError(@"Log level %@: SUCCESS", @"Error");
    LogCritical(@"Log level %@: SUCCESS", @"Critical");
    
    NSLog(@"=============================================");
}

- (void)testLogLevelInfo {
    [PCFDataLogger sharedInstance].level = PCFDataLogLevelInfo;
    
    NSLog(@"=========== PCFDataLogLevelInfo =================");
    
    LogDebug(@"Log level %@: FAILURE", @"Debug");
    LogInfo(@"Log level %@: SUCCESS", @"Info");
    LogWarning(@"Log level %@: SUCCESS", @"Warning");
    LogError(@"Log level %@: SUCCESS", @"Error");
    LogCritical(@"Log level %@: SUCCESS", @"Critical");
    
    NSLog(@"=============================================");
}

- (void)testLogLevelWarning {
    [PCFDataLogger sharedInstance].level = PCFDataLogLevelWarning;
    
    NSLog(@"=========== PCFDataLogLevelWarning ==============");
    
    LogDebug(@"Log level %@: FAILURE", @"Debug");
    LogInfo(@"Log level %@: FAILURE", @"Info");
    LogWarning(@"Log level %@: SUCCESS", @"Warning");
    LogError(@"Log level %@: SUCCESS", @"Error");
    LogCritical(@"Log level %@: SUCCESS", @"Critical");
    
    NSLog(@"=============================================");
}

- (void)testLogLevelError {
    [PCFDataLogger sharedInstance].level = PCFDataLogLevelError;
    
    NSLog(@"=========== PCFDataLogLevelError ================");
    
    LogDebug(@"Log level %@: FAILURE", @"Debug");
    LogInfo(@"Log level %@: FAILURE", @"Info");
    LogWarning(@"Log level %@: FAILURE", @"Warning");
    LogError(@"Log level %@: SUCCESS", @"Error");
    LogCritical(@"Log level %@: SUCCESS", @"Critical");
    
    NSLog(@"=============================================");
}

- (void)testLogLevelCritical {
    [PCFDataLogger sharedInstance].level = PCFDataLogLevelCritical;
    
    NSLog(@"=========== PCFDataLogLevelCritical =============");
    
    LogDebug(@"Log level %@: FAILURE", @"Debug");
    LogInfo(@"Log level %@: FAILURE", @"Info");
    LogWarning(@"Log level %@: FAILURE", @"Warning");
    LogError(@"Log level %@: FAILURE", @"Error");
    LogCritical(@"Log level %@: SUCCESS", @"Critical");
    
    NSLog(@"=============================================");
}

- (void)testLogLevelNone {
    [PCFDataLogger sharedInstance].level = PCFDataLogLevelNone;
    
    NSLog(@"=========== PCFDataLogLevelNone =================");
    
    LogDebug(@"Log level %@: FAILURE", @"Debug");
    LogInfo(@"Log level %@: FAILURE", @"Info");
    LogWarning(@"Log level %@: FAILURE", @"Warning");
    LogError(@"Log level %@: FAILURE", @"Error");
    LogCritical(@"Log level %@: FAILURE", @"Critical");
    
    NSLog(@"=============================================");
}

@end
