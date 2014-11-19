//
//  PCFOfflineStoreTests.swift
//  PCFData
//
//  Created by DX122-XL on 2014-10-30.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

import Foundation
import XCTest

class PCFOfflineStoreTests: XCTestCase {
    
    let key = NSUUID().UUIDString
    let value = NSUUID().UUIDString
    let collection = NSUUID().UUIDString
    let accessToken = NSUUID().UUIDString

    let error = NSError()

    
    class TestOfflineStore : PCFOfflineStore {
        
        let isOnline: Bool = false;
        
        init(online: Bool, collection: String, remoteStore: PCFRemoteStore, localStore: PCFLocalStore) {
            isOnline = online;
            super.init(collection: collection, remoteStore: remoteStore, localStore: localStore)
        }
        
        func isConnected() -> Bool {
            return isOnline
        }
    }
    
//    func testGetSucceedsWhileOnline() {
//        let response = PCFResponse(key: key, value: value)
//        let remoteStore = MockRemoteStore(mockResponse: response)
//        let localStore = MockLocalStore(mockResponse: response)
//        
//        let offlineStore = TestOfflineStore(online: true, collection: collection, remoteStore: remoteStore, localStore: localStore)
//        let result = offlineStore.getWithKey(key, accessToken: accessToken)
//        
//        XCTAssertEqual(result.key, key, "Response has key")
//        XCTAssertEqual(result.value, value, "Response has value")
//        
//        XCTAssertTrue(localStore.wasGetInvoked, "Get was invoked on local store")
//        XCTAssertTrue(remoteStore.wasAsyncGetInvoked, "Async get was invoked on remote store")
//        XCTAssertTrue(localStore.wasPutInvoked, "Put was invoked on local store")
//    }
//
//    func testGetFailsWhileOnline() {
//        let response = PCFResponse(key: key, error: error)
//        let remoteStore = MockRemoteStore(mockResponse: response)
//        let localStore = MockLocalStore(mockResponse: response)
//        
//        let offlineStore = TestOfflineStore(online: true, collection: collection, remoteStore: remoteStore, localStore: localStore)
//        let result = offlineStore.getWithKey(key, accessToken: accessToken)
//        
//        XCTAssertEqual(result.key, key, "Response has key")
//        
//        XCTAssertTrue(localStore.wasGetInvoked, "Get was invoked on local store")
//        XCTAssertTrue(remoteStore.wasAsyncGetInvoked, "Async get was invoked on remote store")
//    }
//
//    func testGetFailsWhileOnline() {
//        let remoteClient = MockRemoteClient(mockResult: nil, mockError: error)
//        let remoteStore = MockRemoteStore(client: remoteClient, collection: collection)
//        let localStore = PCFLocalStore(defaults: MockUserDefaults(values: [key: value]))
//        let offlineStore = MockOfflineStore(remoteStore: remoteStore, localStore: localStore, collection: collection)
//        
//        XCTAssertEqual(localStore.getWithKey(key, accessToken: accessToken).value, value, "Local store contains current value")
//        
//        let result = offlineStore.getWithKey(key, accessToken: accessToken)
//        XCTAssert(result.isMemberOfClass(PCFPendingResponse), "Response is a pending response")
//        
//        XCTAssert(remoteClient.wasGetInvoked, "Get is invoked on the client")
//        XCTAssertEqual(remoteClient.error!, error, "Error present on remote client")
//        XCTAssertEqual(localStore.getWithKey(key, accessToken: accessToken).value, value, "Value is not changed locally")
//    }
//    
//    func testGetSucceedsWithNoPriorValueWhileOnline() {
//        let remoteClient = MockRemoteClient(mockResult: networkValue, mockError: nil)
//        let remoteStore = MockRemoteStore(client: remoteClient, collection: collection)
//        let localStore = PCFLocalStore(defaults: MockUserDefaults(values: NSDictionary()))
//        let offlineStore = MockOfflineStore(remoteStore: remoteStore, localStore: localStore, collection: collection)
//        
//        XCTAssertEqual(localStore.getWithKey(key, accessToken: accessToken).value, "", "Local store contains empty value")
//        
//        let result = offlineStore.getWithKey(key, accessToken: accessToken)
//        
//        XCTAssert(result.isMemberOfClass(PCFPendingResponse), "Response is a pending response")
//        XCTAssert(remoteClient.wasGetInvoked, "Get is invoked on the client")
//        XCTAssertEqual(localStore.getWithKey(key, accessToken: accessToken).value, networkValue, "Local store has updated value")
//    }
//    
//    func testGetWhileOffline() {
//        let remoteClient = MockRemoteClient(mockResult: networkValue, mockError: nil)
//        let remoteStore = MockRemoteStore(client: remoteClient, collection: collection)
//        let localStore = PCFLocalStore(defaults: MockUserDefaults(values: [key: value]))
//        let offlineStore = MockOfflineStore(remoteStore: remoteStore, localStore: localStore, collection: collection)
//        offlineStore.isOnline = false
//        
//        XCTAssertEqual(localStore.getWithKey(key, accessToken: accessToken).value, value, "Local store contains current value")
//        
//        let result = offlineStore.getWithKey(key, accessToken: accessToken)
//        
//        XCTAssert(result.isMemberOfClass(PCFPendingResponse), "Response is a pending response")
//        XCTAssertFalse(remoteClient.wasGetInvoked, "Get is not invoked while offline")
//        XCTAssertEqual(localStore.getWithKey(key, accessToken: accessToken).value, value, "Local store value doesn't change")
//        XCTAssertEqual(result.value, value, "Offline store response contains local value")
//    }
//    
//    func testPutSucceedsWhileOnline() {
//        let remoteClient = MockRemoteClient(mockResult: networkValue, mockError: nil)
//        let remoteStore = MockRemoteStore(client: remoteClient, collection: collection)
//        let localStore = PCFLocalStore(defaults: MockUserDefaults(values: [key: value]))
//        let offlineStore = MockOfflineStore(remoteStore: remoteStore, localStore: localStore, collection: collection)
//        
//        XCTAssertEqual(localStore.getWithKey(key, accessToken: accessToken).value, value, "Local store contains current value")
//        
//        let result = offlineStore.putWithKey(key, value: networkValue, accessToken: accessToken)
//        
//        XCTAssert(result.isMemberOfClass(PCFPendingResponse), "Response is a pending response")
//        XCTAssert(remoteClient.wasPutInvoked, "Put is invoked on the client")
//        XCTAssertEqual(localStore.getWithKey(key, accessToken: accessToken).value, networkValue, "Local store value changes")
//        XCTAssertEqual(result.value, networkValue, "Offline store response contains updated value")
//    }
//    
//    func testPutFailsWhileOnline() {
//        let remoteClient = MockRemoteClient(mockResult: networkValue, mockError: error)
//        let remoteStore = MockRemoteStore(client: remoteClient, collection: collection)
//        let localStore = PCFLocalStore(defaults: MockUserDefaults(values: [key: value]))
//        let offlineStore = MockOfflineStore(remoteStore: remoteStore, localStore: localStore, collection: collection)
//        
//        XCTAssertEqual(localStore.getWithKey(key, accessToken: accessToken).value, value, "Local store contains current value")
//        
//        let result = offlineStore.putWithKey(key, value: networkValue, accessToken: accessToken)
//        
//        XCTAssert(result.isMemberOfClass(PCFPendingResponse), "Response is a pending response")
//        XCTAssert(remoteClient.wasPutInvoked, "Put is invoked on the client")
//        XCTAssertEqual(localStore.getWithKey(key, accessToken: accessToken).value, networkValue, "Local store value changes")
//        XCTAssertEqual(remoteClient.error!, error, "Remote client has an error")
//        XCTAssertEqual(result.value, networkValue, "Offline store response contains updated value")
//    }
//    
//    func testPutWhileOffline() {
//        let remoteClient = MockRemoteClient(mockResult: networkValue, mockError: error)
//        let remoteStore = MockRemoteStore(client: remoteClient, collection: collection)
//        let localStore = PCFLocalStore(defaults: MockUserDefaults(values: [key: value]))
//        let offlineStore = MockOfflineStore(remoteStore: remoteStore, localStore: localStore, collection: collection)
//        offlineStore.isOnline = false
//        
//        XCTAssertEqual(localStore.getWithKey(key, accessToken: accessToken).value, value, "Local store contains current value")
//        
//        let result = offlineStore.putWithKey(key, value: networkValue, accessToken: accessToken)
//        
//        XCTAssert(result.isMemberOfClass(PCFPendingResponse), "Response is a pending response")
//        XCTAssertFalse(remoteClient.wasPutInvoked, "Put is not invoked on the client while offline")
//        XCTAssertEqual(localStore.getWithKey(key, accessToken: accessToken).value, networkValue, "Local store value changes")
//        XCTAssertEqual(result.value, networkValue, "Offline store response contains updated value")
//    }
//    
//    func testDeleteWhileOnline() {
//        let remoteClient = MockRemoteClient(mockResult: networkValue, mockError: error)
//        let remoteStore = MockRemoteStore(client: remoteClient, collection: collection)
//        let localStore = PCFLocalStore(defaults: MockUserDefaults(values: [key: value]))
//        let offlineStore = MockOfflineStore(remoteStore: remoteStore, localStore: localStore, collection: collection)
//     
//        XCTAssertEqual(localStore.getWithKey(key, accessToken: accessToken).value, value, "Local store contains current value")
//        
//        let result = offlineStore.deleteWithKey(key, accessToken: accessToken)
//        
//        XCTAssert(result.isMemberOfClass(PCFPendingResponse), "Response is a pending response")
//        XCTAssert(remoteClient.wasDeleteInvoked, "Delete is invoked on the client")
//        XCTAssertEqual(localStore.getWithKey(key, accessToken: accessToken).value, "", "Local store value is empty")
//        XCTAssertEqual(result.value, "", "Offline store response value is empty")
//    }
//    
//    func testDeleteWhileOffline() {
//        let remoteClient = MockRemoteClient(mockResult: networkValue, mockError: error)
//        let remoteStore = MockRemoteStore(client: remoteClient, collection: collection)
//        let localStore = PCFLocalStore(defaults: MockUserDefaults(values: [key: value]))
//        let offlineStore = MockOfflineStore(remoteStore: remoteStore, localStore: localStore, collection: collection)
//        offlineStore.isOnline = false
//        
//        XCTAssertEqual(localStore.getWithKey(key, accessToken: accessToken).value, value, "Local store contains current value")
//        
//        let result = offlineStore.deleteWithKey(key, accessToken: accessToken)
//        XCTAssert(result.isMemberOfClass(PCFPendingResponse), "Response is a pending response")
//        XCTAssertFalse(remoteClient.wasDeleteInvoked, "Delete is not invoked on the client while offline")
//        XCTAssertEqual(localStore.getWithKey(key, accessToken: accessToken).value, "", "Local store value is empty")
//        XCTAssertEqual(result.value, "", "Offline store response value is empty")
//    }
}