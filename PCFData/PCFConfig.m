//
//  PCFConfig.m
//  PCFData
//
//  Created by DX122-XL on 2014-12-08.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFConfig.h"

@interface PCFConfig () {
    NSDictionary *_values;
}

@property (readonly) NSDictionary *values;
@property (readwrite) NSDictionary *collisionTypes;

@end


@implementation PCFConfig

static NSString* const PCFServiceUrl = @"pivotal.data.serviceUrl";
static NSString* const PCFStrategy = @"pivotal.data.collisionStrategy";


+ (PCFConfig *)sharedInstance {
    static PCFConfig *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PCFConfig alloc] init];
    });
    return sharedInstance;
}

+ (NSString *)serviceUrl {
    return [[PCFConfig sharedInstance] serviceUrl];
}

+ (PCFCollisionStrategy)collisionStrategy {
    return [[PCFConfig sharedInstance] collisionStrategy];
}

- (instancetype)init {
    self.collisionTypes = @{
        @"OptimisticLocking" : [NSNumber numberWithInt:PCFCollisionStrategyOptimisticLocking],
        @"LastWriteWins" : [NSNumber numberWithInt:PCFCollisionStrategyLastWriteWins]
    };
    return self;
}

- (NSString *)serviceUrl {
    return [self.values objectForKey:PCFServiceUrl];
}

- (PCFCollisionStrategy)collisionStrategy {
    NSString *strategy = [self.values objectForKey:PCFStrategy];
    return [[self.collisionTypes objectForKey:strategy] intValue];
}

- (NSDictionary *)values {
    if (!_values) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Pivotal" ofType:@"plist"];
        _values = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return _values;
}

@end
