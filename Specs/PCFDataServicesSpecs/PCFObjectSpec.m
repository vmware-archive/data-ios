//
//  PCFObjectSpec.m
//  PCFDataServices Spec
//
//  Created by DX123-XL on 2014-06-02.
//  Copyright 2014 Pivotal. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <AFNetworking/AFNetworking.h>

#import "PCFObject.h"
#import "PCFDataSignIn+Internal.h"

SPEC_BEGIN(PCFObjectSpec)

describe(@"PCFObject", ^{
    static NSString *const kTestClassName = @"TestClass";
    static NSString *const kTestObjectID = @"1234";
    
    context(@"constructing a new instance of a PCFObject with nil class name", ^{
        it(@"should throw an exception if passed a nil or empty class name", ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused"
            
            //nil call param
            [[theBlock(^{[PCFObject objectWithClassName:nil];}) should] raiseWithName:NSInvalidArgumentException];
            [[theBlock(^{[PCFObject objectWithClassName:nil dictionary:nil];}) should] raiseWithName:NSInvalidArgumentException];
            [[theBlock(^{[[PCFObject alloc] initWithClassName:nil];}) should] raiseWithName:NSInvalidArgumentException];
            
            //empty class param
            [[theBlock(^{[PCFObject objectWithClassName:@""];}) should] raiseWithName:NSInvalidArgumentException];
            [[theBlock(^{[PCFObject objectWithClassName:@"" dictionary:nil];}) should] raiseWithName:NSInvalidArgumentException];
            [[theBlock(^{[[PCFObject alloc] initWithClassName:@""];}) should] raiseWithName:NSInvalidArgumentException];
            
            //NSNull class param
            [[theBlock(^{[PCFObject objectWithClassName:(id)[NSNull null]];}) should] raiseWithName:NSInvalidArgumentException];
            [[theBlock(^{[PCFObject objectWithClassName:(id)[NSNull null] dictionary:nil];}) should] raiseWithName:NSInvalidArgumentException];
            [[theBlock(^{[[PCFObject alloc] initWithClassName:(id)[NSNull null]];}) should] raiseWithName:NSInvalidArgumentException];
#pragma clang diagnostic pop
        });
    });
    
    context(@"constructing an empty new instance of a PCFObject", ^{
        __block PCFObject *newObject;
        
        beforeEach(^{
            newObject = nil;
        });
        
        afterEach(^{
            [[newObject.className should] equal:kTestClassName];
            [[newObject.objectID should] beNil];
            [[theValue(newObject.allKeys.count) should] equal:theValue(0)];

        });
        
        it(@"should create a new empty PCFObject instance with the 'objectWithClassName' selector", ^{
            newObject = [PCFObject objectWithClassName:kTestClassName];
        });
        
        it(@"should create a new empty PCFObject instance with the 'objectWithClassName:dictionary:' selector with nil dictionary", ^{
            newObject = [PCFObject objectWithClassName:kTestClassName dictionary:nil];
        });
        
        it(@"should create a new empty PCFObject instance with the 'initWithClassName:' selector", ^{
            newObject = [[PCFObject alloc] initWithClassName:kTestClassName];
        });
    });
    
    context(@"constructing a new populated instance of a PCFObject", ^{
        NSDictionary *keyValuePairs = @{
                                        @"TestKey1" : @"TestValue1",
                                        @"TestKey2" : @[@"ArrayValue1", @"ArrayValue2", @"ArrayValue3"],
                                        @"TestKey3" : @{@"DictKey1" : @"DictValue1", @"DictKey2" : @"DictValue2", @"DictKey3" : @"DictValue3"},
                                        };

        it(@"should create a new populated PCFObject instance with the objectID property set when passed as a parameter", ^{
            NSString *testObjectID = @"TestObjectID";
            NSDictionary *keyValuePairs = @{ @"objectID" : @"TestObjectID" };
            PCFObject *newObject = [PCFObject objectWithClassName:kTestClassName dictionary:keyValuePairs];
            newObject.objectID = testObjectID;
            
            [[newObject.className should] equal:kTestClassName];
            [[newObject.objectID should] equal:testObjectID];
            [[theValue(newObject.allKeys.count) should] equal:theValue(keyValuePairs.count)];
        });
        
        it(@"should create a new populated PCFObject instance with set Key Value pairs from dictionary with 'objectWithClassName:dictionary:' selector", ^{
            PCFObject *newObject = [PCFObject objectWithClassName:kTestClassName dictionary:keyValuePairs];
            
            [[newObject.className should] equal:kTestClassName];
            [[theValue(newObject.allKeys.count) should] equal:theValue(keyValuePairs.allKeys.count)];
        });
        
        it(@"should set object to key when initialized with 'objectWithClassName:dictionary:' selector", ^{
            PCFObject *newObject = [PCFObject objectWithClassName:kTestClassName dictionary:keyValuePairs];
            
            [keyValuePairs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [[[newObject objectForKey:key] should] equal:obj];
            }];
        });
    });
    
    context(@"getting and settings PCFObject properties", ^{
        __block PCFObject *newObject;
        static NSString *key = @"TestKey";
        static NSString *object = @"TestObject";

        beforeEach(^{
            newObject = [PCFObject objectWithClassName:kTestClassName];
        });
        
        it(@"should set object with 'setObject:forKey:' and return the set object with 'objectForKey:' selector", ^{
            [newObject setObject:object forKey:key];
            [[[newObject objectForKey:key] should] equal:object];
        });
        
        it(@"should remove the assigned object from the instance after executing 'removeObjectForKey:' selector", ^{
            [newObject setObject:object forKey:key];
            [newObject removeObjectForKey:key];
            [[[newObject objectForKey:key] should] beNil];
        });
        
        it(@"should support instance[<key>] syntax for retrieving assigned objects from an instance", ^{
            [newObject setObject:object forKey:key];
            [[newObject[key] should] equal:object];
        });
        
        it(@"should support instance[<key>] = <value> syntax for setting objects on an instance", ^{
            newObject[key] = object;
            [[[newObject objectForKey:key] should] equal:object];
        });
    });
    
    context(@"saving PCFObject instance to the Data Services server", ^{
        __block PCFObject *newObject;
        __block NSDictionary *expectedContents;
        
        static NSString *key = @"TestKey";
        static NSString *object = @"TestObject";
        
        beforeEach(^{
            expectedContents = @{ key : object };
            newObject = [PCFObject objectWithClassName:kTestClassName dictionary:expectedContents];
            newObject.objectID = kTestObjectID;
        });
        
        typedef void (^EnqueueBlock)(NSArray *);
        
        void (^stubURLConnectionSuccess)(EnqueueBlock) = ^(EnqueueBlock block){
            [NSURLConnection stub:@selector(sendSynchronousRequest:returningResponse:error:)
                        withBlock:^id(NSArray *params) {
                            block(params);
                            return [NSData data];
                        }];
        };
        
        void (^stubURLConnectionFail)() = ^{
            [NSURLConnection stub:@selector(sendSynchronousRequest:returningResponse:error:)
                        withBlock:^id(NSArray *params) {
                            return nil;
                        }];
        };
        
        it(@"should throw an exception if dataServiceURL is not set on the 'PCFDataSignIn' sharedInstance", ^{
            [[theBlock(^{ [newObject saveSynchronously:nil]; }) should] raiseWithName:NSObjectNotAvailableException];
        });
        
        context(@"Properly setup PCFDataSignIn sharedInstance", ^{
            
            beforeEach(^{
                [PCFDataSignIn sharedInstance].dataServiceURL = @"http://testurl.com";
            });
            
            it(@"should perform PUT synchronously on remote server when 'saveSyncronously:' selector performed", ^{
                stubURLConnectionSuccess(^(NSArray *params){
                    NSURLRequest *request = params[0];
                    [[request.HTTPMethod should] equal:@"PUT"];
                });
                
                [[theValue([newObject saveSynchronously:nil]) should] beTrue];
            });
            
            it(@"should contain set key value pairs in request body when 'saveSyncronously:' selector performed", ^{
                stubURLConnectionSuccess(^(NSArray *params){
                    NSURLRequest *request = params[0];
                    NSError *error;
                    id contents = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:&error];
                    [[contents should] equal:expectedContents];
                    [[error should] beNil];
                });
                
                [[theValue([newObject saveSynchronously:nil]) should] beTrue];
            });
            
            it(@"should populate error object if 'saveSyncronously:' PUT operation fails", ^{
                stubURLConnectionFail();
                
                NSError *error;
                [[theValue([newObject saveSynchronously:&error]) should] beFalse];
            });
            
            it(@"should have the class name and object ID as the path in the HTTP PUT request", ^{
                stubURLConnectionSuccess(^(NSArray *params){
                    NSURLRequest *request = params[0];
                    [[[request.URL relativeString] should] endWithString:[NSString stringWithFormat:@"%@/%@", kTestClassName, kTestObjectID]];
                });
                
                NSError *error;
                [[theValue([newObject saveSynchronously:&error]) should] beTrue];
            });
            
            it(@"should perform PUT asyncronously on remote server when 'saveOnSuccess:failure:' selector performed", ^{
                
            });
            
            it(@"should call success block if PUT operation is successful", ^{
                
            });
            
            it(@"should call failure block if PUT operation fails", ^{
                
            });
        });
    });
    
    context(@"fetching PCFObject instance from the Data Services server", ^{
        it(@"should perform GET syncronously on remote server when 'fetchSyncronously:' selector performed", ^{
            
        });
        
        it(@"should populate error object if 'fetchSyncronously:' GET operation fails", ^{
        });
        
        it(@"should perform GET asyncronously on remote server when 'fetchOnSuccess:failure:' selector performed", ^{
            
        });
        
        it(@"should call success block if 'fetchOnSuccess:failure:' GET operation is successful", ^{
            
        });
        
        it(@"should call failure block if 'fetchOnSuccess:failure:' GET operation fails", ^{
            
        });
    });
    
    context(@"deleting PCFObject instance from the Data Services server", ^{
        
        it(@"should perform DELETE syncronously on remote server when 'deleteSyncronously:' selector performed", ^{
        });
        
        it(@"should populate error object if 'deleteSyncronously:' DELETE operation fails", ^{
        });
        
        it(@"should perform DELETE asyncronously on remote server when 'delete' selector performed", ^{
            
        });
        
        it(@"should perform DELETE asyncronously on remote server when 'deleteOnSuccess:failure:' selector performed", ^{
            
        });
        
        it(@"should call success block if 'deleteOnSuccess:failure:' DELETE operation is successful", ^{
            
        });
        
        it(@"should call failure block if 'deleteOnSuccess:failure:' DELETE operation fails", ^{
            
        });
    });
});

SPEC_END
