//
//  PCFRequestCacheTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-11-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFData.h>

@interface PCFRequestCache ()
- (void)executePendingRequestsWithToken:(NSString *)accessToken requests:(NSArray *)requests;
@end

@interface PCFRequestCacheTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *token;
@property NSString *collection;
@property NSString *fallback;
@property int method;

@end

@implementation PCFRequestCacheTests

static int const HTTP_GET = 0;
static int const HTTP_PUT = 1;
static int const HTTP_DELETE = 2;

static NSString* const PCFMethod = @"PCFData:method";
static NSString* const PCFAccessToken = @"PCFData:accessToken";
static NSString* const PCFCollection = @"PCFData:collection";
static NSString* const PCFKey = @"PCFData:key";
static NSString* const PCFValue = @"PCFData:value";
static NSString* const PCFFallback = @"PCFData:fallback";

static NSString* const PCFDataRequestCache = @"PCFData:RequestCache";

- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
    self.collection = [NSUUID UUID].UUIDString;
    self.fallback = [NSUUID UUID].UUIDString;
    self.method = arc4random() % 3;
}

- (void)testQueueGetWithToken {
    id request = OCMClassMock([PCFPendingRequest class]);
    PCFRequestCache *cache = OCMPartialMock([[PCFRequestCache alloc] init]);
    
    OCMStub([cache queuePendingRequest:[OCMArg any]]).andDo(nil);
    OCMStub([request alloc]).andReturn(request);
    OCMStub([request initWithMethod:HTTP_GET accessToken:[OCMArg any] collection:[OCMArg any] key:[OCMArg any] value:[OCMArg any] fallback:[OCMArg any]]).andReturn(request);
    
    [cache queueGetWithToken:self.token collection:self.collection key:self.key];
    
    OCMVerify([cache queuePendingRequest:request]);
    OCMVerify([request initWithMethod:HTTP_GET accessToken:self.token collection:self.collection key:self.key value:nil fallback:nil]);
    
    [request stopMocking];
}

- (void)testQueuePutWithToken {
    id request = OCMClassMock([PCFPendingRequest class]);
    PCFRequestCache *cache = OCMPartialMock([[PCFRequestCache alloc] init]);
    
    OCMStub([cache queuePendingRequest:[OCMArg any]]).andDo(nil);
    OCMStub([request alloc]).andReturn(request);
    OCMStub([request initWithMethod:HTTP_PUT accessToken:[OCMArg any] collection:[OCMArg any] key:[OCMArg any] value:[OCMArg any] fallback:[OCMArg any]]).andReturn(request);
    
    [cache queuePutWithToken:self.token collection:self.collection key:self.key value:self.value fallback:self.fallback];
    
    OCMVerify([cache queuePendingRequest:request]);
    OCMVerify([request initWithMethod:HTTP_PUT accessToken:self.token collection:self.collection key:self.key value:self.value fallback:self.fallback]);
    
    [request stopMocking];
}

- (void)testQueueDeleteWithToken {
    id request = OCMClassMock([PCFPendingRequest class]);
    PCFRequestCache *cache = OCMPartialMock([[PCFRequestCache alloc] init]);
    
    OCMStub([cache queuePendingRequest:[OCMArg any]]).andDo(nil);
    OCMStub([request alloc]).andReturn(request);
    OCMStub([request initWithMethod:HTTP_DELETE accessToken:[OCMArg any] collection:[OCMArg any] key:[OCMArg any] value:[OCMArg any] fallback:[OCMArg any]]).andReturn(request);
    
    [cache queueDeleteWithToken:self.token collection:self.collection key:self.key fallback:self.fallback];
    
    OCMVerify([cache queuePendingRequest:request]);
    OCMVerify([request initWithMethod:HTTP_DELETE accessToken:self.token collection:self.collection key:self.key value:nil fallback:self.fallback]);
    
    [request stopMocking];
}

- (void)testQueuePendingWithExistingArray {
    NSUserDefaults *userDefaults = OCMClassMock([NSUserDefaults class]);
    NSMutableArray *array = OCMClassMock([NSMutableArray class]);
    PCFPendingRequest *request = OCMClassMock([PCFPendingRequest class]);
    PCFRequestCache *cache = OCMPartialMock([[PCFRequestCache alloc] initWithDefaults:userDefaults]);
    
    OCMStub([userDefaults objectForKey:[OCMArg any]]).andReturn(array);
    OCMStub([array mutableCopy]).andReturn(array);

    [cache queuePendingRequest:request];
    
    OCMVerify([array addObject:request.values]);
    OCMVerify([userDefaults objectForKey:PCFDataRequestCache]);
    OCMVerify([userDefaults setObject:array forKey:PCFDataRequestCache]);
}

- (void)testQueuePendingWithoutExistingArray {
    NSUserDefaults *userDefaults = OCMClassMock([NSUserDefaults class]);
    PCFPendingRequest *request = OCMClassMock([PCFPendingRequest class]);
    PCFRequestCache *cache = OCMPartialMock([[PCFRequestCache alloc] initWithDefaults:userDefaults]);
    
    OCMStub([userDefaults objectForKey:[OCMArg any]]).andReturn(nil);
    
    [cache queuePendingRequest:request];
    
    OCMVerify([userDefaults objectForKey:PCFDataRequestCache]);
    OCMVerify([userDefaults setObject:[OCMArg isNotNil] forKey:PCFDataRequestCache]);
}

- (void)testExecutePendingRequestsWithTokenAndHandlerNewData {
    NSUserDefaults *userDefaults = OCMClassMock([NSUserDefaults class]);
    NSArray *requestArray = OCMClassMock([NSArray class]);
    PCFRequestCache *cache = OCMPartialMock([[PCFRequestCache alloc] initWithDefaults:userDefaults]);
    
    OCMStub([requestArray count]).andReturn(1);
    OCMStub([userDefaults objectForKey:[OCMArg any]]).andReturn(requestArray);
    OCMStub([cache executePendingRequestsWithToken:[OCMArg any] requests:[OCMArg any]]).andDo(nil);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    [cache executePendingRequestsWithToken:self.token completionHandler:^(UIBackgroundFetchResult arg){
        XCTAssertEqual(arg, UIBackgroundFetchResultNewData);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OCMVerify([userDefaults objectForKey:PCFDataRequestCache]);
    OCMVerify([userDefaults setObject:nil forKey:PCFDataRequestCache]);
    OCMVerify([cache executePendingRequestsWithToken:self.token requests:requestArray]);
}

- (void)testExecutePendingRequestsWithTokenAndHandlerNoData {
    NSUserDefaults *userDefaults = OCMClassMock([NSUserDefaults class]);
    PCFRequestCache *cache = OCMPartialMock([[PCFRequestCache alloc] initWithDefaults:userDefaults]);

    OCMStub([userDefaults objectForKey:[OCMArg any]]).andReturn(nil);
    OCMStub([cache executePendingRequestsWithToken:[OCMArg any] requests:[OCMArg any]]).andDo(nil);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    [cache executePendingRequestsWithToken:self.token completionHandler:^(UIBackgroundFetchResult arg){
        XCTAssertEqual(arg, UIBackgroundFetchResultNoData);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    OCMVerify([userDefaults objectForKey:PCFDataRequestCache]);
    OCMVerify([userDefaults setObject:nil forKey:PCFDataRequestCache]);
}

- (void)testExecutePendingRequestsWithTokenAndRequests {
    PCFOfflineStore *offlineStore = OCMClassMock([PCFOfflineStore class]);
    PCFRequestCache *cache = OCMPartialMock([[PCFRequestCache alloc] init]);
    
    NSArray *requestArray = @[
        @{PCFMethod : [NSNumber numberWithInt:HTTP_GET], PCFAccessToken : self.token, PCFCollection : self.collection, PCFKey : self.key, PCFValue : self.value, PCFFallback : self.fallback },
        @{PCFMethod : [NSNumber numberWithInt:HTTP_PUT], PCFAccessToken : self.token, PCFCollection : self.collection, PCFKey : self.key, PCFValue : self.value, PCFFallback : self.fallback },
        @{PCFMethod : [NSNumber numberWithInt:HTTP_DELETE], PCFAccessToken : self.token, PCFCollection : self.collection, PCFKey : self.key, PCFValue : self.value, PCFFallback : self.fallback },
        @{PCFMethod : [NSNumber numberWithInt:(3 + arc4random() % 97)], PCFAccessToken : self.token, PCFCollection : self.collection, PCFKey : self.key, PCFValue : self.value, PCFFallback : self.fallback }
    ];
    
    OCMStub([cache createOfflineStoreWithCollection:[OCMArg any]]).andReturn(offlineStore);
    
    [cache executePendingRequestsWithToken:self.token requests:requestArray];
    
    OCMVerify([offlineStore getWithKey:self.key accessToken:self.token]);
    OCMVerify([offlineStore putWithKey:self.key value:self.value accessToken:self.token]);
    OCMVerify([offlineStore deleteWithKey:self.key accessToken:self.token]);
}

- (void)testExecutePendingRequestsWithTokenAndRequestsUsingCachedToken {
    PCFOfflineStore *offlineStore = OCMClassMock([PCFOfflineStore class]);
    PCFRequestCache *cache = OCMPartialMock([[PCFRequestCache alloc] init]);
    
    NSString *token = [NSUUID UUID].UUIDString;
    
    NSArray *requestArray = @[
        @{PCFMethod : [NSNumber numberWithInt:HTTP_GET], PCFAccessToken : token, PCFCollection : self.collection, PCFKey : self.key, PCFValue : self.value, PCFFallback : self.fallback }
    ];
    
    OCMStub([cache createOfflineStoreWithCollection:[OCMArg any]]).andReturn(offlineStore);
    
    [cache executePendingRequestsWithToken:nil requests:requestArray];
    
    OCMVerify([offlineStore getWithKey:self.key accessToken:token]);
}

- (void)testExecutePendingRequestsWithTokenAndRequestsRevertingPutRequest {
    PCFOfflineStore *offlineStore = OCMClassMock([PCFOfflineStore class]);
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    NSError *error = [[NSError alloc] init];
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFRequestCache *cache = OCMPartialMock([[PCFRequestCache alloc] init]);
    
    NSArray *requestArray = @[
        @{PCFMethod : [NSNumber numberWithInt:HTTP_PUT], PCFAccessToken : self.token, PCFCollection : self.collection, PCFKey : self.key, PCFValue : self.value, PCFFallback : self.fallback }
    ];
    
    OCMStub([cache createOfflineStoreWithCollection:[OCMArg any]]).andReturn(offlineStore);
    OCMStub([cache createLocalStoreWithCollection:[OCMArg any]]).andReturn(localStore);
    OCMStub([offlineStore putWithKey:[OCMArg any] value:[OCMArg any] accessToken:[OCMArg any]]).andReturn(response);
    OCMStub([response error]).andReturn(error);
    
    [cache executePendingRequestsWithToken:self.token requests:requestArray];
    
    OCMVerify([offlineStore putWithKey:self.key value:self.value accessToken:self.token]);
    OCMVerify([localStore putWithKey:self.key value:self.fallback accessToken:self.token]);
}

- (void)testExecutePendingRequestsWithTokenAndRequestsRevertingDeleteRequest {
    PCFOfflineStore *offlineStore = OCMClassMock([PCFOfflineStore class]);
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    NSError *error = [[NSError alloc] init];
    PCFResponse *response = OCMClassMock([PCFResponse class]);
    PCFRequestCache *cache = OCMPartialMock([[PCFRequestCache alloc] init]);
    
    NSArray *requestArray = @[
        @{PCFMethod : [NSNumber numberWithInt:HTTP_DELETE], PCFAccessToken : self.token, PCFCollection : self.collection, PCFKey : self.key, PCFValue : self.value, PCFFallback : self.fallback }
    ];
    
    OCMStub([cache createOfflineStoreWithCollection:[OCMArg any]]).andReturn(offlineStore);
    OCMStub([cache createLocalStoreWithCollection:[OCMArg any]]).andReturn(localStore);
    OCMStub([offlineStore deleteWithKey:[OCMArg any] accessToken:[OCMArg any]]).andReturn(response);
    OCMStub([response error]).andReturn(error);
    
    [cache executePendingRequestsWithToken:self.token requests:requestArray];
    
    OCMVerify([offlineStore deleteWithKey:self.key accessToken:self.token]);
    OCMVerify([localStore putWithKey:self.key value:self.fallback accessToken:self.token]);
}

- (void)testCreateOfflineStoreWithCollection {
    id offlineStore = OCMClassMock([PCFOfflineStore class]);
    OCMStub([offlineStore alloc]).andReturn(offlineStore);
    
    PCFRequestCache *cache = [[PCFRequestCache alloc] init];
    [cache createOfflineStoreWithCollection:self.collection];
    
    OCMVerify([offlineStore initWithCollection:self.collection]);
}

- (void)testSharedInstance {
    id cache = OCMClassMock([PCFRequestCache class]);
    
    PCFRequestCache *cache1 = [PCFRequestCache sharedInstance];
    PCFRequestCache *cache2 = [PCFRequestCache sharedInstance];
    
    XCTAssertNotNil(cache1);
    XCTAssertEqual(cache1, cache2);
    
    [cache stopMocking];
}

@end
