//
//  PCFLocalStoreTests.swift
//  PCFData
//
//  Created by DX122-XL on 2014-10-28.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

import XCTest
import Foundation

class PCFLocalStoreTests: XCTestCase {

    func testGetSucceedsWithValue() {
        let dataStore = PCFLocalStore(values: NSMutableDictionary(dictionary: ["key": "value"]))
        let response = dataStore.getWithKey("key", accessToken: "accessToken")

        XCTAssertEqual(response.key, "key", "Response contains the key")
        XCTAssertEqual(response.value, "value", "Response contains the value")
    }
    
    func testGetSucceedsWithEmptyValue() {
        let dataStore = PCFLocalStore(values: NSMutableDictionary())
        let response = dataStore.getWithKey("key", accessToken: "accessToken")
        
        XCTAssertEqual(response.key, "key", "Response contains the key")
        XCTAssertEqual(response.value, "", "Response contains the value")
    }
    
    func testPutSucceedsWithValue() {
        var dictionary = NSMutableDictionary()
        let dataStore = PCFLocalStore(values: dictionary)
        let response = dataStore.putWithKey("key", value: "value", accessToken: "accessToken")
        
        XCTAssertEqual(response.key, "key", "Response contains the key")
        XCTAssertEqual(response.value, "value", "Response contains the value")
        
        XCTAssertEqual(dictionary["key"]! as String, "value", "Key value pair added to backing dictionary")
    }
    
    func testPutSucceedsWithEmptyValue() {
        var dictionary = NSMutableDictionary(dictionary: ["key":"value"])
        let dataStore = PCFLocalStore(values: dictionary)
        let response = dataStore.putWithKey("key", value: "", accessToken: "accessToken")
        
        XCTAssertEqual(response.key, "key", "Response contains the key")
        XCTAssertEqual(response.value, "", "Response contains the value")
        
        XCTAssertEqual(dictionary["key"]! as String, "", "Key value pair added to backing dictionary")
    }
    
    func testPutSucceedsWithNilValue() {
        var dictionary = NSMutableDictionary(dictionary: ["key":"value"])
        let dataStore = PCFLocalStore(values: dictionary)
        let response = dataStore.putWithKey("key", value: nil, accessToken: "accessToken")
        
        XCTAssertEqual(response.key, "key", "Response contains the key")
        XCTAssertEqual(response.value, "", "Response contains the value")
        
        XCTAssertEqual(dictionary["key"]! as String, "", "Key value pair added to backing dictionary")
    }
    
    func testDeleteWithExistingKey() {
        var dictionary = NSMutableDictionary(dictionary: ["key":"value"])
        let dataStore = PCFLocalStore(values: dictionary)
        let response = dataStore.deleteWithKey("key", accessToken: "accessToken")
        
        XCTAssertEqual(response.key, "key", "Response contains the key")
        XCTAssertNil(response.value, "Response value is nil")
        
        XCTAssertNil(dictionary["key"], "Key value pair removed from backing dictionary")
    }
    
    func testDeleteWithNonexistingKey() {
        var dictionary = NSMutableDictionary(dictionary: ["key":"value"])
        let dataStore = PCFLocalStore(values: dictionary)
        let response = dataStore.deleteWithKey("key2", accessToken: "accessToken")
        
        XCTAssertEqual(response.key, "key2", "Response contains the key")
        XCTAssertNil(response.value, "Response value is nil")
        
        XCTAssertNil(dictionary["key2"], "Key value pair still doesn't exist in backing dictionary")
    }

}
