//
//  PCFResponseTests.swift
//  PCFData
//
//  Created by DX122-XL on 2014-10-29.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

import XCTest
import Foundation

class PCFResponseTests: XCTestCase {

    let key = NSUUID().UUIDString
    let value = NSUUID().UUIDString
    
    let error = NSError()
    

    func testSuccess() {
        let response = PCFResponse(key: key, value: value)
        
        XCTAssertEqual(response.key, key, "Key is set")
        XCTAssertEqual(response.value, value, "Value is set")
    }

    func testFailure() {
        let response = PCFResponse(key: key, error: error)
        
        XCTAssertEqual(response.key, key, "Key is set")
        XCTAssertEqual(response.error, error, "Error is set")
    }
    
}
