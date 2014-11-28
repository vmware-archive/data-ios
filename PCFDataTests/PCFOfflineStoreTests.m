//
//  PCFOfflineStoreTests.m
//  PCFData
//
//  Created by DX122-XL on 2014-11-20.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <PCFData/PCFLocalStore.h>
#import <PCFData/PCFRemoteStore.h>
#import <PCFData/PCFOfflineStore.h>
#import <PCFData/PCFRequestCache.h>
#import <PCFData/PCFResponse.h>

@interface PCFOfflineStoreTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *token;
@property NSString *collection;
@property NSError *error;

@end

@implementation PCFOfflineStoreTests

- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
    self.collection = [NSUUID UUID].UUIDString;
    
    self.error = [[NSError alloc] init];
}

- (void)testGetInvokesRemoteAndLocalStoreWhenConnectionIsAvailable {
    PCFResponse *localResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    PCFResponse *remoteResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];

    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore getWithKey:self.key accessToken:self.token]).andReturn(remoteResponse);
    OCMStub([localStore putWithKey:self.key value:remoteResponse.value accessToken:self.token]).andReturn(localResponse);
    
    PCFResponse *response = [dataStore getWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([remoteStore getWithKey:self.key accessToken:self.token]);
    OCMVerify([localStore putWithKey:self.key value:remoteResponse.value accessToken:self.token]);
}

- (void)testGetInvokesRemoteStoreWhenConnectionIsAvailableAndErrorOccurs {
    PCFResponse *remoteResponse = [[PCFResponse alloc] initWithKey:self.key error:self.error];
    
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:nil remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore getWithKey:self.key accessToken:self.token]).andReturn(remoteResponse);
    
    PCFResponse *response = [dataStore getWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response, remoteResponse);
    
    OCMVerify([remoteStore getWithKey:self.key accessToken:self.token]);
}

- (void)testGetInvokesLocalStoreAndQueuesRequestWhenConnectionIsNotAvailableAndSyncIsSupported {
    PCFResponse *localResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFRequestCache *requestCache = OCMClassMock([PCFRequestCache class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:nil]);
    
    OCMStub([dataStore isConnected]).andReturn(false);
    OCMStub([dataStore isSyncSupported]).andReturn(true);
    OCMStub([dataStore requestCache]).andReturn(requestCache);
    OCMStub([localStore getWithKey:self.key accessToken:self.token]).andReturn(localResponse);
    
    PCFResponse *response = [dataStore getWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([localStore getWithKey:self.key accessToken:self.token]);
    OCMVerify([requestCache queueGetWithToken:self.token collection:self.collection key:self.key]);
}

- (void)testGetInvokesLocalStoreWhenConnectionIsNotAvailableAndSyncIsNotSupported {
    PCFResponse *localResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:nil]);
    
    OCMStub([dataStore isConnected]).andReturn(false);
    OCMStub([dataStore isSyncSupported]).andReturn(false);
    OCMStub([localStore getWithKey:self.key accessToken:self.token]).andReturn(localResponse);
    
    PCFResponse *response = [dataStore getWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([localStore getWithKey:self.key accessToken:self.token]);
}

- (void)testPutInvokesRemoteAndLocalStoreWhenConnectionIsAvailable {
    PCFResponse *localResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    PCFResponse *remoteResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore putWithKey:self.key value:self.value accessToken:self.token]).andReturn(remoteResponse);
    OCMStub([localStore putWithKey:self.key value:remoteResponse.value accessToken:self.token]).andReturn(localResponse);
    
    PCFResponse *response = [dataStore putWithKey:self.key value:self.value accessToken:self.token];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([remoteStore putWithKey:self.key value:self.value accessToken:self.token]);
    OCMVerify([localStore putWithKey:self.key value:remoteResponse.value accessToken:self.token]);
}

- (void)testPutInvokesRemoteStoreWhenConnectionIsAvailableAndErrorOccurs {
    PCFResponse *remoteResponse = [[PCFResponse alloc] initWithKey:self.key error:self.error];
    
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:nil remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore putWithKey:self.key value:self.value accessToken:self.token]).andReturn(remoteResponse);
    
    PCFResponse *response = [dataStore putWithKey:self.key value:self.value accessToken:self.token];
    
    XCTAssertEqual(response, remoteResponse);
    
    OCMVerify([remoteStore putWithKey:self.key value:self.value accessToken:self.token]);
}

- (void)testPutInvokesLocalStoreAndQueuesRequestWhenConnectionIsNotAvailableAndSyncIsSupported {
    PCFResponse *localGetResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    PCFResponse *localPutResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFRequestCache *requestCache = OCMClassMock([PCFRequestCache class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:nil]);
    
    OCMStub([dataStore isConnected]).andReturn(false);
    OCMStub([dataStore isSyncSupported]).andReturn(true);
    OCMStub([dataStore requestCache]).andReturn(requestCache);
    OCMStub([localStore getWithKey:self.key accessToken:self.token]).andReturn(localGetResponse);
    OCMStub([localStore putWithKey:self.key value:self.value accessToken:self.token]).andReturn(localPutResponse);
    
    PCFResponse *response = [dataStore putWithKey:self.key value:self.value accessToken:self.token];
    
    XCTAssertEqual(response, localPutResponse);
    
    OCMVerify([localStore getWithKey:self.key accessToken:self.token]);
    OCMVerify([localStore putWithKey:self.key value:self.value accessToken:self.token]);
    OCMVerify([requestCache queuePutWithToken:self.token collection:self.collection key:self.key value:self.value fallback:localGetResponse.value]);
}

- (void)testPutFailsWhenConnectionIsNotAvailableAndSyncIsNotSupported {
    PCFResponse *failureResponse = [[PCFResponse alloc] initWithKey:self.key error:self.error];
    
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:nil]);
    
    OCMStub([dataStore isConnected]).andReturn(false);
    OCMStub([dataStore isSyncSupported]).andReturn(false);
    OCMStub([dataStore noConnectionErrorResponseWithKey:self.key]).andReturn(failureResponse);
    
    PCFResponse *response = [dataStore putWithKey:self.key value:self.value accessToken:self.token];
    
    XCTAssertEqual(response, failureResponse);
    
    OCMVerify([dataStore noConnectionErrorResponseWithKey:self.key]);
}

- (void)testDeleteInvokesRemoteAndLocalStoreWhenConnectionIsAvailable {
    PCFResponse *localResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    PCFResponse *remoteResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore deleteWithKey:self.key accessToken:self.token]).andReturn(remoteResponse);
    OCMStub([localStore deleteWithKey:self.key accessToken:self.token]).andReturn(localResponse);
    
    PCFResponse *response = [dataStore deleteWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([remoteStore deleteWithKey:self.key accessToken:self.token]);
    OCMVerify([localStore deleteWithKey:self.key accessToken:self.token]);
}

- (void)testDeleteInvokesRemoteStoreWhenConnectionIsAvailableAndErrorOccurs {
    PCFResponse *remoteResponse = [[PCFResponse alloc] initWithKey:self.key error:self.error];
    
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:nil remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore deleteWithKey:self.key accessToken:self.token]).andReturn(remoteResponse);
    
    PCFResponse *response = [dataStore deleteWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response, remoteResponse);
    
    OCMVerify([remoteStore deleteWithKey:self.key accessToken:self.token]);
}

- (void)testDeleteInvokesLocalStoreAndQueuesRequestWhenConnectionIsNotAvailableAndSyncIsSupported {
    PCFResponse *localGetResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    PCFResponse *localDeleteResponse = [[PCFResponse alloc] initWithKey:self.key value:self.value];
    
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFRequestCache *requestCache = OCMClassMock([PCFRequestCache class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:nil]);
    
    OCMStub([dataStore isConnected]).andReturn(false);
    OCMStub([dataStore isSyncSupported]).andReturn(true);
    OCMStub([dataStore requestCache]).andReturn(requestCache);
    OCMStub([localStore getWithKey:self.key accessToken:self.token]).andReturn(localGetResponse);
    OCMStub([localStore deleteWithKey:self.key accessToken:self.token]).andReturn(localDeleteResponse);
    
    PCFResponse *response = [dataStore deleteWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response, localDeleteResponse);
    
    OCMVerify([localStore getWithKey:self.key accessToken:self.token]);
    OCMVerify([localStore deleteWithKey:self.key accessToken:self.token]);
    OCMVerify([requestCache queueDeleteWithToken:self.token collection:self.collection key:self.key fallback:localGetResponse.value]);
}

- (void)testDeleteFailsWhenConnectionIsNotAvailableAndSyncIsNotSupported {
    PCFResponse *failureResponse = [[PCFResponse alloc] initWithKey:self.key error:self.error];
    
    PCFLocalStore *localStore = OCMClassMock([PCFLocalStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithCollection:self.collection localStore:localStore remoteStore:nil]);
    
    OCMStub([dataStore isConnected]).andReturn(false);
    OCMStub([dataStore isSyncSupported]).andReturn(false);
    OCMStub([dataStore noConnectionErrorResponseWithKey:self.key]).andReturn(failureResponse);
    
    PCFResponse *response = [dataStore deleteWithKey:self.key accessToken:self.token];
    
    XCTAssertEqual(response, failureResponse);
    
    OCMVerify([dataStore noConnectionErrorResponseWithKey:self.key]);
}

@end
