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
    
    let key = NSUUID().UUIDString
    let value = NSUUID().UUIDString
    let collection = NSUUID().UUIDString
    let accessToken = NSUUID().UUIDString
    
    let error = NSError()
        
    func testGetSucceedsWithValue() {
        let defaults = MockUserDefaults(values: [key: value])!
        let dataStore = PCFLocalStore(collection: collection, defaults: defaults)
        let response = dataStore.getWithKey(key, accessToken: accessToken)

        XCTAssertEqual(response.key, key, "Response contains the key")
        XCTAssertEqual(response.value, value, "Response contains the value")

        XCTAssertTrue(defaults.wasGetInvoked, "Get invoked")
    }
    
    func testGetSucceedsWithEmptyValue() {
        let defaults = MockUserDefaults(values: NSDictionary())!
        let dataStore = PCFLocalStore(collection: collection, defaults: defaults)
        let response = dataStore.getWithKey(key, accessToken: accessToken)
        
        XCTAssertEqual(response.key, key, "Response contains the key")
        XCTAssertNil(response.value, "Response value is nil");
        
        XCTAssertTrue(defaults.wasGetInvoked, "Get invoked")
    }
    
    func testPutSucceedsWithValue() {
        var defaults = MockUserDefaults(values: [key: value])!
        let dataStore = PCFLocalStore(collection: collection, defaults: defaults)
        let response = dataStore.putWithKey(key, value: value, accessToken: accessToken)
        
        XCTAssertEqual(response.key, key, "Response contains the key")
        XCTAssertEqual(response.value, value, "Response contains the value")
        
        XCTAssertTrue(defaults.wasSetInvoked, "Set invoked")
        XCTAssertTrue(defaults.assertValueForKey(key, expected: value), "Key value pair added to backing dictionary")
    }
    
    func testPutSucceedsWithEmptyValue() {
        var defaults = MockUserDefaults(values: [key: value])!
        let dataStore = PCFLocalStore(collection: collection, defaults: defaults)
        let response = dataStore.putWithKey(key, value: "", accessToken: accessToken)
        
        XCTAssertEqual(response.key, key, "Response contains the key")
        XCTAssertEqual(response.value, "", "Response contains empty value")
        
        XCTAssertTrue(defaults.wasSetInvoked, "Set invoked")
        XCTAssertTrue(defaults.assertValueForKey(key, expected: ""), "Key value pair added to backing dictionary")
    }
    
    func testDeleteWithExistingKey() {
        var defaults = MockUserDefaults(values: [key: value])!
        let dataStore = PCFLocalStore(collection: collection, defaults: defaults)
        let response = dataStore.deleteWithKey(key, accessToken: accessToken)
        
        XCTAssertEqual(response.key, key, "Response contains the key")
        XCTAssertNil(response.value, "Response value is nil");
        
        XCTAssertTrue(defaults.wasDeleteInvoked, "Delete invoked")
        XCTAssertTrue(defaults.assertValueForKey(key, expected: nil), "Key value pair removed from backing defaults")
    }
    
    func testDeleteWithNonexistingKey() {
        var defaults = MockUserDefaults(values: ["not-key": "not-value"])!
        let dataStore = PCFLocalStore(collection: collection, defaults: defaults)
        let response = dataStore.deleteWithKey(key, accessToken: accessToken)
        
        XCTAssertEqual(response.key, key, "Response contains the key")
        XCTAssertNil(response.value, "Response value is nil");
        
        XCTAssertTrue(defaults.wasDeleteInvoked, "Delete invoked")
        XCTAssertTrue(defaults.assertValueForKey(key, expected: nil), "Key value pair still doesn't exist in backing defaults")
    }

}


