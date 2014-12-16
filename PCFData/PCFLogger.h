//
//  PCFLogger.h
//  PCFData
//
//  Created by DX122-XL on 2014-12-10.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PCFData.h"

#define DEFAULT_LOGGER [PCFLogger sharedInstance]

#define LogDebug(FMT, ...) \
    [DEFAULT_LOGGER logWithLevel:PCFLogLevelDebug format:FMT, ##__VA_ARGS__]

#define LogInfo(FMT, ...) \
    [DEFAULT_LOGGER logWithLevel:PCFLogLevelInfo format:FMT, ##__VA_ARGS__]

#define LogWarning(FMT, ...) \
    [DEFAULT_LOGGER logWithLevel:PCFLogLevelWarning format:FMT, ##__VA_ARGS__]

#define LogError(FMT, ...) \
    [DEFAULT_LOGGER logWithLevel:PCFLogLevelError format:FMT, ##__VA_ARGS__]

#define LogCritical(FMT, ...) \
    [DEFAULT_LOGGER logWithLevel:PCFLogLevelCritical format:FMT, ##__VA_ARGS__]


@interface PCFLogger : NSObject

@property PCFLogLevel level;

+ (instancetype)sharedInstance;

- (void)logWithLevel:(PCFLogLevel)level format:(NSString*)format, ...;

@end
