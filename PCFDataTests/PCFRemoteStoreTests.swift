//
//  PCFRemoteStoreTests.swift
//  PCFData
//
//  Created by DX122-XL on 2014-10-29.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

import XCTest
import Foundation

class PCFRemoteStoreTests: XCTestCase {

    let key = NSUUID().UUIDString
    let value = NSUUID().UUIDString
    let accessToken = NSUUID().UUIDString
    
    let error = NSError()
    
    func testGetSucceedsWithValue() {
        let client = MockRemoteClient(mockResult: value)
        let dataStore = PCFRemoteStore(client: client)
        let response = dataStore.getWithKey(key, accessToken: accessToken)
        
        XCTAssertEqual(response.key, key, "Response contains key")
        XCTAssertEqual(response.value, value, "Response contains value")
        XCTAssert(client.wasGetInvoked, "Get was invoked")
    }
    
    func testGetFailsWithError() {
        let client = MockRemoteClient(mockError: error)
        let dataStore = PCFRemoteStore(client: client)
        let response = dataStore.getWithKey(key, accessToken: accessToken)
        
        XCTAssertEqual(response.key, key, "Response contains key")
        XCTAssertEqual(response.error, error, "Response contains error")
        XCTAssert(client.wasGetInvoked, "Get was invoked")
    }
    
    func testPutSucceedsWithValue() {
        let client = MockRemoteClient(mockResult: value)
        let dataStore = PCFRemoteStore(client: client)
        let response = dataStore.putWithKey(key, value: value, accessToken: accessToken)
        
        XCTAssertEqual(response.key, key, "Response contains key")
        XCTAssertEqual(response.value, value, "Response contains value")
        XCTAssert(client.wasPutInvoked, "Put was invoked")
    }
    
    func testPutFailsWithError() {
        let client = MockRemoteClient(mockError: error)
        let dataStore = PCFRemoteStore(client: client)
        let response = dataStore.putWithKey(key, value: value, accessToken: accessToken)
        
        XCTAssertEqual(response.key, key, "Response contains key")
        XCTAssertEqual(response.error, error, "Response contains error")
        XCTAssert(client.wasPutInvoked, "Put was invoked")
    }
    
    func testDeleteSucceedsWithValue() {
        let client = MockRemoteClient(mockResult: value)
        let dataStore = PCFRemoteStore(client: client)
        let response = dataStore.deleteWithKey(key, accessToken: accessToken)
        
        XCTAssertEqual(response.key, key, "Response contains key")
        XCTAssertEqual(response.value, value, "Response contains value")
        XCTAssert(client.wasDeleteInvoked, "Delete was invoked")
    }
    
    func testDeleteFailsWithError() {
        let client = MockRemoteClient(mockError: error)
        let dataStore = PCFRemoteStore(client: client)
        let response = dataStore.deleteWithKey(key, accessToken: accessToken)
        
        XCTAssertEqual(response.key, key, "Response contains key")
        XCTAssertEqual(response.error, error, "Response contains error")
        XCTAssert(client.wasDeleteInvoked, "Delete was invoked")
    }
    
    class MockRemoteClient : PCFRemoteClient {
        
        var result : NSString?, error : NSError?
        var wasGetInvoked: Bool = false
        var wasPutInvoked: Bool = false
        var wasDeleteInvoked: Bool = false
        
        init(mockResult: String? = nil, mockError: NSError? = nil) {
            result = mockResult
            error = mockError
        }
        
        override func getWithAccessToken(accessToken: String!, url: NSURL!, error: NSErrorPointer) -> String! {
            wasGetInvoked = true
            if error != nil {
                error.memory = self.error
            }
            return result
        }
        
        override func putWithAccessToken(accessToken: String!, value: String!, url: NSURL!, error: NSErrorPointer) -> String! {
            wasPutInvoked = true
            if error != nil {
                error.memory = self.error
            }
            return result
        }
        
        override func deleteWithAccessToken(accessToken: String!, url: NSURL!, error: NSErrorPointer) -> String! {
            wasDeleteInvoked = true
            if error != nil {
                error.memory = self.error
            }
            return result
        }
    }
}
