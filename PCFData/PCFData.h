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
#import "PCFKeyValueLocalStore.h"
#import "PCFKeyValueRemoteStore.h"
#import "PCFKeyValueOfflineStore.h"
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
typedef NSString* (^PCFTokenProviderBlock) ();
typedef void (^PCFTokenInvalidatorBlock) ();

@interface PCFData : NSObject

+ (void)registerTokenProviderBlock:(PCFTokenProviderBlock)block;

+ (void)unregisterTokenProviderBlock;

+ (void)registerTokenInvalidatorBlock:(PCFTokenInvalidatorBlock)block;

+ (void)unregisterTokenInvalidatorBlock;

+ (void)registerNetworkObserverBlock:(PCFNetworkBlock)block;

+ (void)unregisterNetworkObserverBlock;

+ (void)performSync;

+ (void)performSyncWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

+ (void)clearCachedData;

+ (void)logLevel:(PCFDataLogLevel)level;

@end