//
//  PCFLogger.m
//  PCFData
//
//  Created by DX122-XL on 2014-12-10.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFLogger.h"

@interface PCFLogger ()

@end

@implementation PCFLogger

static BOOL isDebugEnabled = false;

+ (void)setDebug:(BOOL)enabled {
    isDebugEnabled = enabled;
}

+ (BOOL)isDebugEnabled {
    return isDebugEnabled;
}

+ (void)log:(NSString *)fmt, ... {
    if (isDebugEnabled) {
        va_list args;
        va_start(args, fmt);
        NSLogv(fmt, args);
        va_end(args);
    }
}

@end
