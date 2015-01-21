//
//  PCFEtagStore.m
//  PCFData
//
//  Created by DX122-XL on 2014-12-08.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFEtagStore.h"
#import "PCFResponse.h"
#import "PCFDataPersistence.h"

@interface PCFEtagStore ()

@property (readonly) PCFDataPersistence *persistence;

@end

@implementation PCFEtagStore

static NSString* const PCFDataEtagPrefix = @"PCFData:Etag:";

- (instancetype)init {
    return [self initWithPersistence:[[PCFDataPersistence alloc] init]];
}

- (instancetype)initWithPersistence:(PCFDataPersistence *)persistence {
    _persistence = persistence;
    return self;
}

- (NSString *)etagForUrl:(NSURL *)url {
    if (url) {
        return [self.persistence getValueForKey:[PCFDataEtagPrefix stringByAppendingString:[url absoluteString]]];
    } else {
        return nil;
    }
}

- (void)putEtagForUrl:(NSURL *)url etag:(NSString *)etag {
    if (url) {
        [self.persistence putValue:etag forKey:[PCFDataEtagPrefix stringByAppendingString:[url absoluteString]]];
    }
}

@end