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

static NSString* const PCFRequestCacheKey = @"RequestCache";

- (instancetype)initWithPersistence:(PCFDataPersistence *)persistence {
    _persistence = persistence;
    return self;
}

- (void)addRequest:(PCFPendingRequest *)request {
    @synchronized(self) {
        NSString *serialized = [self.persistence getValueForKey:PCFRequestCacheKey];
        
        NSMutableArray *array;
        
        if (!serialized) {
            array = [NSMutableArray arrayWithObject:[request toDictionary]];
        } else {
            NSData *data = [serialized dataUsingEncoding:NSUTF8StringEncoding];
            array = [[NSJSONSerialization JSONObjectWithData:data options:0 error:nil] mutableCopy];
            
            [array addObject:[request toDictionary]];
        }
        
        NSData *newData = [NSJSONSerialization dataWithJSONObject:array options:0 error:nil];
        NSString *newSerialized = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
        
        [self.persistence putValue:newSerialized forKey:PCFRequestCacheKey];
    }
}

- (NSArray *)empty {
    NSString *serialized;
    
    @synchronized(self) {
        serialized = [self.persistence getValueForKey:PCFRequestCacheKey];
        [self.persistence deleteValueForKey:PCFRequestCacheKey];
    }
    
    NSMutableArray *requests = [[NSMutableArray alloc] init];
    
    if (serialized) {
        NSData *data = [serialized dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *requestDicts = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
        for (NSDictionary *dict in requestDicts) {
            [requests addObject:[[PCFPendingRequest alloc] initWithDictionary:dict]];
        }
    }
    
    return requests;
}

@end
