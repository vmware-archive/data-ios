//
//  PCFRequestCacheQueue.m
//  PCFData
//
//  Created by DX122-XL on 2015-01-13.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import "PCFRequestCacheQueue.h"
#import "PCFDataPersistence.h"
#import "PCFPendingRequest.h"


@interface PCFRequestCacheQueue ()

@property PCFDataPersistence *persistence;

@end

@implementation PCFRequestCacheQueue

static NSString* const PCFDataRequestCache = @"PCFData:RequestCache";

- (instancetype)initWithPersistence:(PCFDataPersistence *)persistence {
    _persistence = persistence;
    return self;
}

- (void)addRequest:(PCFPendingRequest *)request {
    @synchronized(self) {
        NSMutableArray *array = [[self.persistence getValueForKey:PCFDataRequestCache] mutableCopy];
        
        if (!array) {
            array = [[NSMutableArray alloc] initWithObjects:[request toDictionary], nil];
        } else {
            [array addObject:[request toDictionary]];
        }
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
        NSString *serialized = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        [self.persistence putValue:serialized forKey:PCFDataRequestCache];
    }
}

- (NSArray *)empty {
    NSString *serialized;
    
    @synchronized(self) {
        serialized = [self.persistence getValueForKey:PCFDataRequestCache];
        [self.persistence deleteValueForKey:PCFDataRequestCache];
    }
    
    NSData *data = [serialized dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *requestDicts = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSMutableArray *requests = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in requestDicts) {
        [requests addObject:[[PCFPendingRequest alloc] initWithDictionary:dict]];
    }
    
    return requests;
}

@end
