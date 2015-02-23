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

@interface PCFKeyValueOfflineStore ()

@property (readonly) PCFRequestCache *requestCache;

- (PCFDataResponse *)getWithRequest:(PCFDataRequest *)request;

- (PCFDataResponse *)executeRequestWithFallback:(PCFDataRequest *)request;

- (PCFDataResponse *)errorNoConnectionWithKey:(NSString *)key;

- (BOOL)isSyncSupported;

- (BOOL)isConnected;

@end

@interface PCFKeyValueOfflineStoreTests : XCTestCase

@property NSString *key;
@property NSString *value;
@property NSString *token;
@property NSString *collection;
@property NSError *error;
@property BOOL force;

@property id getArg;
@property id putArg;
@property id deleteArg;

@end

@implementation PCFKeyValueOfflineStoreTests

- (void)setUp {
    [super setUp];
    
    self.key = [NSUUID UUID].UUIDString;
    self.value = [NSUUID UUID].UUIDString;
    self.token = [NSUUID UUID].UUIDString;
    self.collection = [NSUUID UUID].UUIDString;
    self.error = [[NSError alloc] init];
    self.force = arc4random_uniform(2);
    
    self.getArg = [OCMArg checkWithBlock:^BOOL(id value) {
        return [(PCFDataRequest *)value method] == PCF_HTTP_GET;
    }];
    
    self.putArg = [OCMArg checkWithBlock:^BOOL(id value) {
        return [(PCFDataRequest *)value method] == PCF_HTTP_PUT;
    }];
    
    self.deleteArg = [OCMArg checkWithBlock:^BOOL(id value) {
        return [(PCFDataRequest *)value method] == PCF_HTTP_DELETE;
    }];
}

- (PCFDataRequest *)createRequestForMethod:(int)method {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    return [[PCFDataRequest alloc] initWithMethod:method object:keyValue fallback:nil force:self.force];
}

- (PCFDataResponse *)createResponseWithError:(NSError *)error {
    PCFKeyValue *keyValue = [[PCFKeyValue alloc] initWithCollection:self.collection key:self.key value:self.value];
    return [[PCFDataResponse alloc] initWithObject:keyValue error:error];
}

- (void)testExecuteGetRequestInvokesGetWithRequest {
    PCFDataRequest *request = [self createRequestForMethod:PCF_HTTP_GET];
    PCFDataResponse *response = [self createResponseWithError:nil];
    
    PCFKeyValueOfflineStore *dataStore = OCMPartialMock([[PCFKeyValueOfflineStore alloc] init]);
    
    OCMStub([dataStore getWithRequest:[OCMArg any]]).andReturn(response);
    
    XCTAssertEqual(response, [dataStore executeRequest:request]);
    
    OCMVerify([dataStore getWithRequest:request]);
}

- (void)testExecutePutRequestInvokesExecuteRequestWithFallback {
    PCFDataRequest *request = [self createRequestForMethod:PCF_HTTP_PUT];
    PCFDataResponse *response = [self createResponseWithError:nil];
    
    PCFKeyValueOfflineStore *dataStore = OCMPartialMock([[PCFKeyValueOfflineStore alloc] init]);
    
    OCMStub([dataStore executeRequestWithFallback:[OCMArg any]]).andReturn(response);
    
    XCTAssertEqual(response, [dataStore executeRequest:request]);
    
    OCMVerify([dataStore executeRequestWithFallback:request]);
}

- (void)testExecuteDeleteRequestInvokesExecuteRequestWithFallback {
    PCFDataRequest *request = [self createRequestForMethod:PCF_HTTP_DELETE];
    PCFDataResponse *response = [self createResponseWithError:nil];
    
    PCFKeyValueOfflineStore *dataStore = OCMPartialMock([[PCFKeyValueOfflineStore alloc] init]);
    
    OCMStub([dataStore executeRequestWithFallback:[OCMArg any]]).andReturn(response);
    
    XCTAssertEqual(response, [dataStore executeRequest:request]);
    
    OCMVerify([dataStore executeRequestWithFallback:request]);
}

- (void)testExecuteUnsupportedRequestReturnsErrorResponse {
    PCFDataRequest *request = [self createRequestForMethod:0];
    
    PCFKeyValueOfflineStore *dataStore = OCMPartialMock([[PCFKeyValueOfflineStore alloc] init]);
    
    PCFDataResponse *errorResponse = [dataStore executeRequest:request];
    
    XCTAssertNotNil(errorResponse.error);
}

- (void)testGetInvokesRemoteAndLocalStoreWhenConnectionIsAvailable {
    PCFDataRequest *request = [self createRequestForMethod:PCF_HTTP_GET];
    PCFDataResponse *localResponse = [self createResponseWithError:nil];
    PCFDataResponse *remoteResponse = [self createResponseWithError:nil];

    PCFKeyValueLocalStore *localStore = OCMClassMock([PCFKeyValueLocalStore class]);
    PCFKeyValueRemoteStore *remoteStore = OCMClassMock([PCFKeyValueRemoteStore class]);
    PCFKeyValueOfflineStore *dataStore = OCMPartialMock([[PCFKeyValueOfflineStore alloc] initWithLocalStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore executeRequest:[OCMArg any]]).andReturn(remoteResponse);
    OCMStub([localStore executeRequest:self.putArg]).andReturn(localResponse);
    
    PCFDataResponse *response = [dataStore getWithRequest:request];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([remoteStore executeRequest:request]);
    OCMVerify([localStore executeRequest:[OCMArg any]]);
}

- (void)testGetInvokesRemoteStoreWhenConnectionIsAvailableAndErrorOccurs {
    PCFDataRequest *request = [self createRequestForMethod:PCF_HTTP_GET];
    PCFDataResponse *remoteResponse = [self createResponseWithError:self.error];
    
    PCFKeyValueLocalStore *localStore = OCMClassMock([PCFKeyValueLocalStore class]);
    PCFKeyValueRemoteStore *remoteStore = OCMClassMock([PCFKeyValueRemoteStore class]);
    PCFKeyValueOfflineStore *dataStore = OCMPartialMock([[PCFKeyValueOfflineStore alloc] initWithLocalStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore executeRequest:[OCMArg any]]).andReturn(remoteResponse);
    
    PCFDataResponse *response = [dataStore getWithRequest:request];
    
    XCTAssertEqual(response, remoteResponse);
    
    OCMVerify([remoteStore executeRequest:request]);
}

- (void)testGetInvokesRemoteAndLocalStoreWhenConnectionIsAvailableAndNotModifiedErrorOccurs {
    PCFDataRequest *request = [self createRequestForMethod:PCF_HTTP_GET];
    NSError *error = [[NSError alloc] initWithDomain:@"Not Modified" code:304 userInfo:nil];
    
    PCFDataResponse *remoteResponse = [self createResponseWithError:error];
    PCFDataResponse *localResponse = [self createResponseWithError:nil];
    
    PCFKeyValueLocalStore *localStore = OCMClassMock([PCFKeyValueLocalStore class]);
    PCFKeyValueRemoteStore *remoteStore = OCMClassMock([PCFKeyValueRemoteStore class]);
    PCFKeyValueOfflineStore *dataStore = OCMPartialMock([[PCFKeyValueOfflineStore alloc] initWithLocalStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore executeRequest:[OCMArg any]]).andReturn(remoteResponse);
    OCMStub([localStore executeRequest:[OCMArg any]]).andReturn(localResponse);
    
    PCFDataResponse *response = [dataStore getWithRequest:request];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([remoteStore executeRequest:request]);
    OCMVerify([localStore executeRequest:request]);
}

- (void)testGetInvokesRemoteAndLocalStoreWhenConnectionIsAvailableAndNotFoundErrorOccurs {
    PCFDataRequest *request = [self createRequestForMethod:PCF_HTTP_GET];
    NSError *error = [[NSError alloc] initWithDomain:@"Not Found" code:404 userInfo:nil];
    
    PCFDataResponse *remoteResponse = [self createResponseWithError:error];
    
    PCFKeyValueLocalStore *localStore = OCMClassMock([PCFKeyValueLocalStore class]);
    PCFKeyValueRemoteStore *remoteStore = OCMClassMock([PCFKeyValueRemoteStore class]);
    PCFKeyValueOfflineStore *dataStore = OCMPartialMock([[PCFKeyValueOfflineStore alloc] initWithLocalStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore executeRequest:[OCMArg any]]).andReturn(remoteResponse);
    OCMStub([localStore executeRequest:self.deleteArg]).andDo(nil);
    
    PCFDataResponse *response = [dataStore getWithRequest:request];
    
    XCTAssertEqual(response, remoteResponse);
    
    OCMVerify([remoteStore executeRequest:request]);
    OCMVerify([localStore executeRequest:[OCMArg any]]);
}

- (void)testGetInvokesLocalStoreAndQueuesRequestWhenConnectionIsNotAvailable {
    PCFDataRequest *request = [self createRequestForMethod:PCF_HTTP_GET];
    PCFDataResponse *localResponse = [self createResponseWithError:nil];
    
    PCFRequestCache *requestCache = OCMClassMock([PCFRequestCache class]);
    PCFKeyValueLocalStore *localStore = OCMClassMock([PCFKeyValueLocalStore class]);
    PCFKeyValueOfflineStore *dataStore = OCMPartialMock([[PCFKeyValueOfflineStore alloc] initWithLocalStore:localStore remoteStore:nil]);
    
    OCMStub([dataStore isConnected]).andReturn(false);
    OCMStub([dataStore requestCache]).andReturn(requestCache);
    OCMStub([localStore executeRequest:[OCMArg any]]).andReturn(localResponse);
    
    PCFDataResponse *response = [dataStore getWithRequest:request];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([localStore executeRequest:request]);
    OCMVerify([requestCache queueRequest:request]);
}

- (void)testExecuteRequestWithFallbackInvokesRemoteAndLocalStoreWhenConnectionIsAvailable {
    PCFDataRequest *request = [self createRequestForMethod:PCF_HTTP_PUT];
    PCFDataResponse *localResponse = [self createResponseWithError:nil];
    PCFDataResponse *remoteResponse = [self createResponseWithError:nil];
    
    PCFKeyValueLocalStore *localStore = OCMClassMock([PCFKeyValueLocalStore class]);
    PCFKeyValueRemoteStore *remoteStore = OCMClassMock([PCFKeyValueRemoteStore class]);
    PCFKeyValueOfflineStore *dataStore = OCMPartialMock([[PCFKeyValueOfflineStore alloc] initWithLocalStore:localStore remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore executeRequest:[OCMArg any]]).andReturn(remoteResponse);
    OCMStub([localStore executeRequest:[OCMArg any]]).andReturn(localResponse);
    
    PCFDataResponse *response = [dataStore executeRequestWithFallback:request];
    
    XCTAssertEqual(response, localResponse);
    
    OCMVerify([remoteStore executeRequest:request]);
    OCMVerify([localStore executeRequest:request]);
}

- (void)testExecuteRequestWithFallbackInvokesRemoteStoreWhenConnectionIsAvailableAndErrorOccurs {
    PCFDataRequest *request = [self createRequestForMethod:PCF_HTTP_PUT];
    PCFDataResponse *remoteResponse = [self createResponseWithError:self.error];
    
    PCFKeyValueRemoteStore *remoteStore = OCMClassMock([PCFKeyValueRemoteStore class]);
    PCFKeyValueOfflineStore *dataStore = OCMPartialMock([[PCFKeyValueOfflineStore alloc] initWithLocalStore:nil remoteStore:remoteStore]);
    
    OCMStub([dataStore isConnected]).andReturn(true);
    OCMStub([remoteStore executeRequest:[OCMArg any]]).andReturn(remoteResponse);
    
    PCFDataResponse *response = [dataStore executeRequestWithFallback:request];
    
    XCTAssertEqual(response, remoteResponse);
    
    OCMVerify([remoteStore executeRequest:request]);
}

- (void)testExecuteRequestWithFallbackInvokesLocalStoreAndQueuesRequestWhenConnectionIsNotAvailableAndSyncIsSupported {
    PCFDataRequest *request = [self createRequestForMethod:PCF_HTTP_PUT];
    PCFDataResponse *localGetResponse = [self createResponseWithError:nil];
    PCFDataResponse *localPutResponse = [self createResponseWithError:nil];
    
    PCFRequestCache *requestCache = OCMClassMock([PCFRequestCache class]);
    PCFKeyValueLocalStore *localStore = OCMClassMock([PCFKeyValueLocalStore class]);
    PCFKeyValueOfflineStore *dataStore = OCMPartialMock([[PCFKeyValueOfflineStore alloc] initWithLocalStore:localStore remoteStore:nil]);
    
    OCMStub([dataStore isConnected]).andReturn(false);
    OCMStub([dataStore requestCache]).andReturn(requestCache);
    OCMStub([localStore executeRequest:self.getArg]).andReturn(localGetResponse);
    OCMStub([localStore executeRequest:[OCMArg any]]).andReturn(localPutResponse);
    
    PCFDataResponse *response = [dataStore executeRequestWithFallback:request];
    
    XCTAssertEqual(response, localPutResponse);
    
    OCMVerify([localStore executeRequest:[OCMArg any]]);
    OCMVerify([localStore executeRequest:request]);
    OCMVerify([requestCache queueRequest:request]);
}

@end
