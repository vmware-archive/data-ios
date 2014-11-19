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
        let response = PCFResponse(key: key, value: value)
        let dataStore = MockDataStore(mockResponse: response)
        let dataObject = PCFDataObject(dataStore: dataStore, key: key)
        
        XCTAssertEqual(dataObject.getWithAccessToken(accessToken), response, "Data exists")
        XCTAssert(dataStore.wasGetInvoked, "Get was invoked")
    }
    
    func testPut() {
        let response = PCFResponse(key: key, value: value)
        let dataStore = MockDataStore(mockResponse: response)
        let dataObject = PCFDataObject(dataStore: dataStore, key: key)
        
        XCTAssertEqual(dataObject.putWithAccessToken(accessToken, value: value), response, "Data was put")
        XCTAssert(dataStore.wasPutInvoked, "Put was invoked")
    }
    
    func testDelete() {
        let response = PCFResponse(key: key, value: value)
        let dataStore = MockDataStore(mockResponse: response)
        let dataObject = PCFDataObject(dataStore: dataStore, key: key)
        
        XCTAssertEqual(dataObject.deleteWithAccessToken(accessToken), response, "Data was deleted")
        XCTAssert(dataStore.wasDeleteInvoked, "Delete was invoked")
    }
}
