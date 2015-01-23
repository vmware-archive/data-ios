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
#import <PCFData/PCFData.h>
#import "PCFRequestCache.h"

@interface PCFOfflineStore ()

@property (readonly) PCFRequestCache *requestCache;

- (PCFResponse *)errorNoConnectionWithKey:(NSString *)key;

- (BOOL)isSyncSupported;

- (BOOL)isConnected;

@end

@interface PCFOfflineStoreTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *token;
@property NSString *collection;
@property NSError *error;
@property BOOL force;

@end

@implementation PCFOfflineStoreTests

- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
    self.collection = [NSUUID UUID].UUIDString;
    
    self.error = [[NSError alloc] init];
    self.force = arc4random_uniform(2);
}

- (PCFRequest *)createRequest {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    return [[PCFRequest alloc] initWithAccessToken:self.token object:keyValue force:self.force];
}

- (PCFResponse *)createResponseWithError:(NSError *)error {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    return [[PCFResponse alloc] initWithObject:keyValue error:error];
}

- (void)testGetInvokesRemoteAndLocalStoreWhenConnectionIsAvailable {
    PCFRequest *request = [self createRequest];
    
    PCFResponse *localResponse = [self createResponseWithError:nil];
    PCFResponse *remoteResponse = [self createResponseWithError:nil];

    PCFKeyValueStore *localStore = OCMClassMock([PCFKeyValueStore class]);
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithLocalStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore getWithRequest:[OCMArg any]]).andReturn(remoteResponse);
    OCMStub([localStore putWithRequest:[OCMArg any]]).andReturn(localResponse);
    
    PCFResponse *response = [dataStore getWithRequest:request];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([remoteStore getWithRequest:request]);
    OCMVerify([localStore putWithRequest:[OCMArg any]]);
}

- (void)testGetInvokesRemoteStoreWhenConnectionIsAvailableAndErrorOccurs {
    PCFRequest *request = [self createRequest];
    
    PCFResponse *remoteResponse = [self createResponseWithError:self.error];
    
    PCFKeyValueStore *localStore = OCMClassMock([PCFKeyValueStore class]);
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithLocalStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore getWithRequest:[OCMArg any]]).andReturn(remoteResponse);
    
    PCFResponse *response = [dataStore getWithRequest:request];
    
    XCTAssertEqual(response, remoteResponse);
    
    OCMVerify([remoteStore getWithRequest:request]);
}

- (void)testGetInvokesRemoteAndLocalStoreWhenConnectionIsAvailableAndNotModifiedErrorOccurs {
    PCFRequest *request = [self createRequest];
    NSError *error = [[NSError alloc] initWithDomain:@"Not Modified" code:304 userInfo:nil];
    
    PCFResponse *remoteResponse = [self createResponseWithError:error];
    PCFResponse *localResponse = [self createResponseWithError:nil];
    
    PCFKeyValueStore *localStore = OCMClassMock([PCFKeyValueStore class]);
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithLocalStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore getWithRequest:[OCMArg any]]).andReturn(remoteResponse);
    OCMStub([localStore getWithRequest:[OCMArg any]]).andReturn(localResponse);
    
    PCFResponse *response = [dataStore getWithRequest:request];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([remoteStore getWithRequest:request]);
    OCMVerify([localStore getWithRequest:request]);
}

- (void)testGetInvokesRemoteAndLocalStoreWhenConnectionIsAvailableAndNotFoundErrorOccurs {
    PCFRequest *request = [self createRequest];
    NSError *error = [[NSError alloc] initWithDomain:@"Not Found" code:404 userInfo:nil];
    
    PCFResponse *remoteResponse = [self createResponseWithError:error];
    
    PCFKeyValueStore *localStore = OCMClassMock([PCFKeyValueStore class]);
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithLocalStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore getWithRequest:[OCMArg any]]).andReturn(remoteResponse);
    
    PCFResponse *response = [dataStore getWithRequest:request];
    
    XCTAssertEqual(response, remoteResponse);
    
    OCMVerify([remoteStore getWithRequest:request]);
    OCMVerify([localStore deleteWithRequest:request]);
}

- (void)testGetInvokesLocalStoreAndQueuesRequestWhenConnectionIsNotAvailable {
    PCFRequest *request = [self createRequest];
    PCFResponse *localResponse = [self createResponseWithError:nil];
    
    PCFKeyValueStore *localStore = OCMClassMock([PCFKeyValueStore class]);
    PCFRequestCache *requestCache = OCMClassMock([PCFRequestCache class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithLocalStore:localStore remoteStore:nil]);
    
    OCMStub([dataStore isConnected]).andReturn(false);
    OCMStub([dataStore requestCache]).andReturn(requestCache);
    OCMStub([localStore getWithRequest:[OCMArg any]]).andReturn(localResponse);
    
    PCFResponse *response = [dataStore getWithRequest:request];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([localStore getWithRequest:request]);
    OCMVerify([requestCache queueGetWithRequest:request]);
}

- (void)testPutInvokesRemoteAndLocalStoreWhenConnectionIsAvailable {
    PCFRequest *request = [self createRequest];
    
    PCFResponse *localResponse = [self createResponseWithError:nil];
    PCFResponse *remoteResponse = [self createResponseWithError:nil];
    
    PCFKeyValueStore *localStore = OCMClassMock([PCFKeyValueStore class]);
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithLocalStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore putWithRequest:[OCMArg any]]).andReturn(remoteResponse);
    OCMStub([localStore putWithRequest:[OCMArg any]]).andReturn(localResponse);
    
    PCFResponse *response = [dataStore putWithRequest:request];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([remoteStore putWithRequest:request]);
    OCMVerify([localStore putWithRequest:request]);
}

- (void)testPutInvokesRemoteStoreWhenConnectionIsAvailableAndErrorOccurs {
    PCFRequest *request = [self createRequest];
    
    PCFResponse *remoteResponse = [self createResponseWithError:self.error];
    
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithLocalStore:nil remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore putWithRequest:[OCMArg any]]).andReturn(remoteResponse);
    
    PCFResponse *response = [dataStore putWithRequest:request];
    
    XCTAssertEqual(response, remoteResponse);
    
    OCMVerify([remoteStore putWithRequest:request]);
}

- (void)testPutInvokesLocalStoreAndQueuesRequestWhenConnectionIsNotAvailableAndSyncIsSupported {
    PCFRequest *request = [self createRequest];
    
    PCFResponse *localGetResponse = [self createResponseWithError:nil];
    PCFResponse *localPutResponse = [self createResponseWithError:nil];
    
    PCFKeyValueStore *localStore = OCMClassMock([PCFKeyValueStore class]);
    PCFRequestCache *requestCache = OCMClassMock([PCFRequestCache class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithLocalStore:localStore remoteStore:nil]);
    
    OCMStub([dataStore isConnected]).andReturn(false);
    OCMStub([dataStore requestCache]).andReturn(requestCache);
    OCMStub([localStore getWithRequest:[OCMArg any]]).andReturn(localGetResponse);
    OCMStub([localStore putWithRequest:[OCMArg any]]).andReturn(localPutResponse);
    
    PCFResponse *response = [dataStore putWithRequest:request];
    
    XCTAssertEqual(response, localPutResponse);
    
    OCMVerify([localStore getWithRequest:request]);
    OCMVerify([localStore putWithRequest:request]);
    OCMVerify([requestCache queuePutWithRequest:request]);
}

- (void)testDeleteInvokesRemoteAndLocalStoreWhenConnectionIsAvailable {
    PCFRequest *request = [self createRequest];
    
    PCFResponse *localResponse = [self createResponseWithError:nil];
    PCFResponse *remoteResponse = [self createResponseWithError:nil];
    
    PCFKeyValueStore *localStore = OCMClassMock([PCFKeyValueStore class]);
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithLocalStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore deleteWithRequest:[OCMArg any]]).andReturn(remoteResponse);
    OCMStub([localStore deleteWithRequest:[OCMArg any]]).andReturn(localResponse);
    
    PCFResponse *response = [dataStore deleteWithRequest:request];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([remoteStore deleteWithRequest:request]);
    OCMVerify([localStore deleteWithRequest:request]);
}

- (void)testDeleteInvokesRemoteStoreWhenConnectionIsAvailableAndErrorOccurs {
    PCFRequest *request = [self createRequest];
    
    PCFResponse *remoteResponse = [self createResponseWithError:self.error];
    
    PCFRemoteStore *remoteStore = OCMClassMock([PCFRemoteStore class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithLocalStore:nil remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore deleteWithRequest:[OCMArg any]]).andReturn(remoteResponse);
    
    PCFResponse *response = [dataStore deleteWithRequest:request];
    
    XCTAssertEqual(response, remoteResponse);
    
    OCMVerify([remoteStore deleteWithRequest:request]);
}

- (void)testDeleteInvokesLocalStoreAndQueuesRequestWhenConnectionIsNotAvailable {
    PCFRequest *request = [self createRequest];
    
    PCFResponse *localGetResponse = [self createResponseWithError:nil];
    PCFResponse *localDeleteResponse = [self createResponseWithError:nil];
    
    PCFKeyValueStore *localStore = OCMClassMock([PCFKeyValueStore class]);
    PCFRequestCache *requestCache = OCMClassMock([PCFRequestCache class]);
    PCFOfflineStore *dataStore = OCMPartialMock([[PCFOfflineStore alloc] initWithLocalStore:localStore remoteStore:nil]);
    
    OCMStub([dataStore isConnected]).andReturn(false);
    OCMStub([dataStore requestCache]).andReturn(requestCache);
    OCMStub([localStore getWithRequest:[OCMArg any]]).andReturn(localGetResponse);
    OCMStub([localStore deleteWithRequest:[OCMArg any]]).andReturn(localDeleteResponse);
    
    PCFResponse *response = [dataStore deleteWithRequest:request];
    
    XCTAssertEqual(response, localDeleteResponse);
    
    OCMVerify([localStore getWithRequest:request]);
    OCMVerify([localStore deleteWithRequest:request]);
    OCMVerify([requestCache queueDeleteWithRequest:request]);
}

@end
