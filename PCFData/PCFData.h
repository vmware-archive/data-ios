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

typedef void (^PCFNetworkBlock) (void);
typedef NSString* (^PCFTokenBlock) (void);

@interface PCFData : NSObject

+ (void)registerTokenProviderBlock:(PCFTokenBlock)block;

+ (void)registerTokenProviderWithUserPromptBlock:(PCFTokenBlock)block;

+ (void)registerNetworkConnectedBlock:(PCFNetworkBlock)block;

+ (void)registerNetworkDisconnectedBlock:(PCFNetworkBlock)block;

+ (void)performSync;

+ (void)performSyncWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

+ (void)logLevel:(PCFDataLogLevel)level;

@end