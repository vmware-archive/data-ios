//
//  PCFEtagStore.m
//  PCFData
//
//  Created by DX122-XL on 2014-12-08.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFEtagStore.h"
#import "PCFResponse.h"

@interface PCFEtagStore ()

@property (readonly) NSUserDefaults *defaults;

@end

@implementation PCFEtagStore

static NSString* const PCFDataEtagPrefix = @"PCFData:Etag:";

- (instancetype)init {
    return [self initWithDefaults:[NSUserDefaults standardUserDefaults]];
}

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults {
    _defaults = defaults;
    return self;
}

- (NSString *)etagForUrl:(NSURL *)url {
    if (url) {
        return [self.defaults objectForKey:[PCFDataEtagPrefix stringByAppendingString:[url absoluteString]]];
    } else {
        return nil;
    }
}

- (void)putEtagForUrl:(NSURL *)url etag:(NSString *)etag {
    if (url) {
        [self.defaults setObject:etag forKey:[PCFDataEtagPrefix stringByAppendingString:[url absoluteString]]];
    }
}

@end