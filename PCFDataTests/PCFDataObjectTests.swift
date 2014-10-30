//
//  PCFDataObjectTests.swift
//  PCFData
//
//  Created by DX122-XL on 2014-10-29.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

import XCTest
import Foundation

class PCFDataObjectTests: XCTestCase {

    let key = NSUUID().UUIDString
    let value = NSUUID().UUIDString
    let accessToken = NSUUID().UUIDString
    
    func testGet() {
        let dataStore = MockDataStore(mockResponse: PCFResponse(key: key, value: value))
        let dataObject = PCFDataObject(dataStore: dataStore, key: key)
        
        XCTAssertEqual(dataObject.getWithAccessToken(accessToken), value, "Data exists")
        XCTAssert(dataStore.wasGetInvoked, "Get was invoked")
    }
    
    func testPut() {
        let dataStore = MockDataStore(mockResponse: PCFResponse(key: key, value: value))
        let dataObject = PCFDataObject(dataStore: dataStore, key: key)
        
        XCTAssertEqual(dataObject.putWithAccessToken(accessToken, value: value), value, "Data was put")
        XCTAssert(dataStore.wasPutInvoked, "Put was invoked")
    }
    
    func testDelete() {
        let dataStore = MockDataStore(mockResponse: PCFResponse(key: key, value: value))
        let dataObject = PCFDataObject(dataStore: dataStore, key: key)
        
        XCTAssertEqual(dataObject.deleteWithAccessToken(accessToken), value, "Data was deleted")
        XCTAssert(dataStore.wasDeleteInvoked, "Delete was invoked")
    }
    
    class MockDataStore : NSObject, PCFDataStore {
        
        var wasGetInvoked: Bool = false;
        var wasPutInvoked: Bool = false;
        var wasDeleteInvoked: Bool = false;
        
        var response: PCFResponse;
        
        init(mockResponse: PCFResponse) {
            response = mockResponse;
        }
        
        func getWithKey(key: String!, accessToken: String!) -> PCFResponse! {
            wasGetInvoked = true;
            return response;
        }
        
        func putWithKey(key: String!, value: String!, accessToken: String!) -> PCFResponse! {
            wasPutInvoked = true;
            return response;
        }
        
        func deleteWithKey(key: String!, accessToken: String!) -> PCFResponse! {
            wasDeleteInvoked = true;
            return response;
        }
    }

}
