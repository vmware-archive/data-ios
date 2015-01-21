//
//  PCFData.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCFDataStore.h"
#import "PCFKeyValue.h"
#import "PCFKeyValueObject.h"
#import "PCFKeyValueStore.h"
#import "PCFRemoteStore.h"
#import "PCFOfflineStore.h"
#import "PCFResponse.h"
#import "PCFRequest.h"

typedef NS_ENUM(NSInteger, PCFDataLogLevel) {
    PCFDataLogLevelDebug = 0,
    PCFDataLogLevelInfo,
    PCFDataLogLevelWarning,
    PCFDataLogLevelError,
    PCFDataLogLevelCritical,
    PCFDataLogLevelNone
};

typedef void (^SyncBlock) (void);

@interface PCFData : NSObject

+ (void)syncWhenNetworkAvailableWithBlock:(SyncBlock)syncBlock;

+ (void)syncWithAccessToken:(NSString *)accessToken;

+ (void)syncWithAccessToken:(NSString *)accessToken completionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

+ (void)logLevel:(PCFDataLogLevel)level;

@end