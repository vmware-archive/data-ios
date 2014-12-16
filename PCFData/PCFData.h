//
//  PCFData.h
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PCFData/PCFDataObject.h>
#import <PCFData/PCFDataStore.h>
#import <PCFData/PCFLocalStore.h>
#import <PCFData/PCFRemoteStore.h>
#import <PCFData/PCFOfflineStore.h>
#import <PCFData/PCFResponse.h>

typedef void (^SyncBlock) (void);

typedef NS_ENUM(NSInteger, PCFLogLevel) {
    PCFLogLevelDebug = 0,
    PCFLogLevelInfo,
    PCFLogLevelWarning,
    PCFLogLevelError,
    PCFLogLevelCritical,
    PCFLogLevelNone
};

@interface PCFData : NSObject

+ (void)startSyncingWithBlock:(SyncBlock)syncBlock;

+ (void)syncWithAccessToken:(NSString *)accessToken;

+ (void)syncWithAccessToken:(NSString *)accessToken completionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

+ (void)logLevel:(PCFLogLevel)level;

@end