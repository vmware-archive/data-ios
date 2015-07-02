//
//  PCFConfig.m
//  PCFData
//
//  Created by DX122-XL on 2014-12-08.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFDataConfig.h"

@interface PCFDataConfig () {
    NSDictionary *_values;
}

@property (readonly) NSDictionary *values;
@property (readwrite) NSDictionary *collisionTypes;

@end


@implementation PCFDataConfig

static NSString* const PCFConfiguration = @"PCFConfiguration";
static NSString* const PCFPropertyMissing = @"Property missing from Pivotal.plist: ";

static NSString* const PCFServiceUrl = @"pivotal.data.serviceUrl";
static NSString* const PCFStrategy = @"pivotal.data.collisionStrategy";
static NSString* const PCFTrustAllSSLCertificates = @"pivotal.data.trustAllSslCertificates";
static NSString* const PCFPinnedSSLCertificateNames = @"pivotal.data.pinnedSslCertificateNames";


+ (PCFDataConfig *)sharedInstance {
    static PCFDataConfig *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PCFDataConfig alloc] init];
    });
    return sharedInstance;
}

+ (NSString *)serviceUrl {
    return [[PCFDataConfig sharedInstance] serviceUrl];
}

+ (BOOL)areEtagsEnabled {
    return [PCFDataConfig collisionStrategy] == PCFCollisionStrategyOptimisticLocking;
}

+ (PCFCollisionStrategy)collisionStrategy {
    return [[PCFDataConfig sharedInstance] collisionStrategy];
}

+ (BOOL)trustAllSSLCertificates {
    return [[PCFDataConfig sharedInstance] trustAllSSLCertificates];
}

+ (NSString *)pinnedSSLCertificateNames {
    return [[PCFDataConfig sharedInstance] pinnedSSLCertificateNames];
}

- (instancetype)init {
    self.collisionTypes = @{
        @"OptimisticLocking" : [NSNumber numberWithInt:PCFCollisionStrategyOptimisticLocking],
        @"LastWriteWins" : [NSNumber numberWithInt:PCFCollisionStrategyLastWriteWins]
    };
    return self;
}

- (NSString *)serviceUrl {
    NSString *serviceUrl = [self.values objectForKey:PCFServiceUrl];
    if (!serviceUrl) {
        NSString *reason = [PCFPropertyMissing stringByAppendingString:PCFServiceUrl];
        @throw [NSException exceptionWithName:PCFConfiguration reason:reason userInfo:nil];
    }
    return serviceUrl;
}

- (PCFCollisionStrategy)collisionStrategy {
    NSString *strategy = [self.values objectForKey:PCFStrategy];
    return [[self.collisionTypes objectForKey:strategy] intValue];
}

- (BOOL)trustAllSSLCertificates {
    NSString *trustAllSSLCertificates = [self.values objectForKey:PCFTrustAllSSLCertificates];
    return [trustAllSSLCertificates boolValue];
}

- (NSString *)pinnedSSLCertificateNames {
    NSString *pinnedSSLCertificateNames = [self.values objectForKey:PCFPinnedSSLCertificateNames];
    if (!pinnedSSLCertificateNames) {
        NSString *reason = [PCFPropertyMissing stringByAppendingString:PCFPinnedSSLCertificateNames];
        @throw [NSException exceptionWithName:PCFConfiguration reason:reason userInfo:nil];
    }
    return pinnedSSLCertificateNames;
}

- (NSDictionary *)values {
    if (!_values) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Pivotal" ofType:@"plist"];
        _values = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return _values;
}

@end
