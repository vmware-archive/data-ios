//
//  PCFData.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PCFData/PCFDataStore.h>
#import <PCFData/PCFKeyValue.h>
#import <PCFData/PCFKeyValueObject.h>
#import <PCFData/PCFKeyValueStore.h>
#import <PCFData/PCFRemoteStore.h>
#import <PCFData/PCFOfflineStore.h>
#import <PCFData/PCFResponse.h>
#import <PCFData/PCFRequest.h>

typedef void (^SyncBlock) (void);

typedef NS_ENUM(NSInteger, PCFDataLogLevel) {
    PCFDataLogLevelDebug = 0,
    PCFDataLogLevelInfo,
    PCFDataLogLevelWarning,
    PCFDataLogLevelError,
    PCFDataLogLevelCritical,
    PCFDataLogLevelNone
};

@interface PCFData : NSObject

+ (void)startSyncingWithBlock:(SyncBlock)syncBlock;

+ (void)syncWithAccessToken:(NSString *)accessToken;

+ (void)syncWithAccessToken:(NSString *)accessToken completionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

+ (void)logLevel:(PCFDataLogLevel)level;

@end