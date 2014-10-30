//
//  TestHelpers.swift
//  PCFData
//
//  Created by DX122-XL on 2014-10-30.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

import Foundation

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

class MockRemoteStore : PCFRemoteStore {
    
    override func getWithKey(key: String!, accessToken: String!, completionBlock: ((PCFResponse!) -> Void)!) {
        completionBlock(self.getWithKey(key, accessToken: accessToken))
    }

    override func putWithKey(key: String!, value: String!, accessToken: String!, completionBlock: ((PCFResponse!) -> Void)!) {
        completionBlock(self.putWithKey(key, value: value, accessToken: accessToken))
    }
    
    override func deleteWithKey(key: String!, accessToken: String!, completionBlock: ((PCFResponse!) -> Void)!) {
        completionBlock(self.deleteWithKey(key, accessToken: accessToken))
    }
    
}

class MockOfflineStore : PCFOfflineStore {
    
    var isOnline: Bool = true;
    
    func isConnected() -> Bool {
        return isOnline
    }
    
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