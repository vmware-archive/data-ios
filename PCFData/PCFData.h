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
#import "PCFDataResponse.h"
#import "PCFDataRequest.h"

typedef NS_ENUM(NSInteger, PCFDataLogLevel) {
    PCFDataLogLevelDebug = 0,
    PCFDataLogLevelInfo,
    PCFDataLogLevelWarning,
    PCFDataLogLevelError,
    PCFDataLogLevelCritical,
    PCFDataLogLevelNone
};

typedef void (^PCFNetworkBlock) (BOOL connected);
typedef NSString* (^PCFTokenBlock) (BOOL promptUser);

@interface PCFData : NSObject

+ (void)registerTokenProviderBlock:(PCFTokenBlock)block;

+ (void)registerNetworkObserverBlock:(PCFNetworkBlock)block;

+ (void)performSync;

+ (void)performSyncWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

+ (void)logLevel:(PCFDataLogLevel)level;

@end