//
//  TestHelpers.swift
//  PCFData
//
//  Created by DX122-XL on 2014-10-30.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

import Foundation

class MockDataStore : NSObject, PCFDataStore {
    
    var wasGetInvoked: Bool = false
    var wasPutInvoked: Bool = false
    var wasDeleteInvoked: Bool = false
    
    var response: PCFResponse;
    
    init(mockResponse: PCFResponse) {
        response = mockResponse;
    }
    
    func getWithKey(key: String!, accessToken: String!) -> PCFResponse! {
        wasGetInvoked = true
        return response
    }
    
    func getWithKey(key: String!, accessToken: String!, completionBlock: ((PCFResponse!) -> Void)!) {
        
    }
    
    func putWithKey(key: String!, value: String!, accessToken: String!) -> PCFResponse! {
        wasPutInvoked = true
        return response
    }
    
    func putWithKey(key: String!, value: String!, accessToken: String!, completionBlock: ((PCFResponse!) -> Void)!) {
        
    }
    
    func deleteWithKey(key: String!, accessToken: String!) -> PCFResponse! {
        wasDeleteInvoked = true
        return response
    }
    
    func deleteWithKey(key: String!, accessToken: String!, completionBlock: ((PCFResponse!) -> Void)!) {
        
    }
}

class MockLocalStore : PCFLocalStore {
    
    var wasGetInvoked: Bool = false
    var wasPutInvoked: Bool = false
    var wasDeleteInvoked: Bool = false
    
    var response: PCFResponse;
    
    init(mockResponse: PCFResponse) {
        response = mockResponse;
        super.init()
    }
    
    override func getWithKey(key: String!, accessToken: String!) -> PCFResponse! {
        wasGetInvoked = true
        return response
    }
    
    override func putWithKey(key: String!, value: String!, accessToken: String!) -> PCFResponse! {
        wasPutInvoked = true
        return response
    }
    
    override func deleteWithKey(key: String!, accessToken: String!) -> PCFResponse! {
        wasDeleteInvoked = true
        return response
    }
    
}

class MockRemoteStore : PCFRemoteStore {
    
    var wasGetInvoked: Bool = false
    var wasPutInvoked: Bool = false
    var wasDeleteInvoked: Bool = false
    
    var wasAsyncGetInvoked: Bool = false
    var wasAsyncPutInvoked: Bool = false
    var wasAsyncDeleteInvoked: Bool = false
    
    var response: PCFResponse;
    
    init(mockResponse: PCFResponse) {
        response = mockResponse;
        super.init()
    }
    
    override func getWithKey(key: String!, accessToken: String!) -> PCFResponse! {
        wasGetInvoked = true
        return response
    }
    
    override func putWithKey(key: String!, value: String!, accessToken: String!) -> PCFResponse! {
        wasPutInvoked = true
        return response
    }
    
    override func deleteWithKey(key: String!, accessToken: String!) -> PCFResponse! {
        wasDeleteInvoked = true
        return response
    }
    
    override func getWithKey(key: String!, accessToken: String!, completionBlock: ((PCFResponse!) -> Void)!) {
        wasAsyncGetInvoked = true
        completionBlock(response)
    }

    override func putWithKey(key: String!, value: String!, accessToken: String!, completionBlock: ((PCFResponse!) -> Void)!) {
        wasAsyncPutInvoked = true
        completionBlock(response)
    }
    
    override func deleteWithKey(key: String!, accessToken: String!, completionBlock: ((PCFResponse!) -> Void)!) {
        wasAsyncDeleteInvoked = true
        completionBlock(response)
    }
}

class MockOfflineStore : PCFOfflineStore {
    
    var isOnline: Bool = true;
    
    func isConnected() -> Bool {
        return isOnline
    }
    
}

class MockUserDefaults:  NSUserDefaults {
    let keyPrefix = "PCFData:";

    var mockValues : NSMutableDictionary

    var wasGetInvoked: Bool = false
    var wasSetInvoked: Bool = false
    var wasDeleteInvoked: Bool = false
    
    init?(values: NSDictionary) {
        mockValues = NSMutableDictionary(dictionary: values)
        super.init(suiteName: "")
    }
    
    override func objectForKey(defaultName: String) -> AnyObject? {
        wasGetInvoked = true;
        return mockValues[stripKeyPrefix(defaultName)]
    }
    
    override func setObject(value: AnyObject?, forKey defaultName: String) {
        wasSetInvoked = true;
        mockValues[stripKeyPrefix(defaultName)] = value;
    }
    
    override func removeObjectForKey(defaultName: String) {
        wasDeleteInvoked = true;
        mockValues.removeObjectForKey(stripKeyPrefix(defaultName))
    }
    
    func stripKeyPrefix(defaultName: String) -> String {
        let prefixRange = defaultName.rangeOfString(keyPrefix, options: NSStringCompareOptions.LiteralSearch, range: nil, locale: nil);
        return defaultName.stringByReplacingCharactersInRange(prefixRange!, withString: "")
    }
    
    func assertValueForKey(key: String, expected: String?) -> Bool {
        return mockValues[key] as String? == expected
    }
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
    
    override func putWithAccessToken(accessToken: String!, url: NSURL!, value: String!, error: NSErrorPointer) -> String! {
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