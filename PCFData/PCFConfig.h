//
//  PCFConfig.h
//  PCFData
//
//  Created by DX122-XL on 2014-12-08.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, PCFCollisionStrategy) {
    PCFCollisionStrategyLastWriteWins = 0,
    PCFCollisionStrategyOptimisticLocking
};

@interface PCFConfig : NSObject

+ (PCFConfig *)sharedInstance;

+ (NSString *)serviceUrl;

+ (PCFCollisionStrategy)collisionStrategy;

@end