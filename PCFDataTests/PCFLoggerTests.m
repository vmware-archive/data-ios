//
//  PCFLoggerTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-12-10.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PCFData/PCFLogger.h>

@interface PCFLoggerTests : XCTestCase

@end

@implementation PCFLoggerTests

- (void)testLog {
    [PCFLogger setDebug:true];
    
    [PCFLogger log:@"Logger %@", @"test"];
}

@end
