//
//  PCFLogger.h
//  PCFData
//
//  Created by DX122-XL on 2014-12-10.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCFLogger : NSObject

+ (void)setDebug:(BOOL)enabled;

+ (BOOL)isDebugEnabled;

+ (void)log:(NSString *)fmt, ...;

@end
