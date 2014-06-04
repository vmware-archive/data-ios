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
    
    typedef NSData *(^EnqueueBlock)(NSArray *);
    typedef void (^EnqueueAsyncBlock)(NSArray *);
    
    void (^stubURLConnectionSuccess)(EnqueueBlock) = ^(EnqueueBlock block){
        [NSURLConnection stub:@selector(sendSynchronousRequest:returningResponse:error:)
                    withBlock:^id(NSArray *params) {
                        NSData *returnedData = block(params);
                        return returnedData;
                    }];
    };
    
    void (^stubURLConnectionFail)() = ^{
        [NSURLConnection stub:@selector(sendSynchronousRequest:returningResponse:error:)
                    withBlock:^id(NSArray *params) {
                        NSValue *value = (NSValue *)params[2];
                        __autoreleasing NSError **error;
                        [value getValue:&error];
                        
                        if (error) {
                            *error = [NSError errorWithDomain:@"Fake operation failed fakely" code:13 userInfo:nil];
                        }
                        return nil;
                    }];
    };
    
    void (^stubAsyncCall)(NSString *, EnqueueAsyncBlock) = ^(NSString *method, EnqueueAsyncBlock block){
        SEL stubSel = NSSelectorFromString([NSString stringWithFormat:@"%@Path:parameters:success:failure:", [method lowercaseString]]);
        [[PCFDataSignIn sharedInstance].dataServiceClient stub:stubSel
                                                     withBlock:^id(NSArray *params) {
                                                         block(params);
                                                         return nil;
                                                     }];
    };
    
    void (^stubPutAsyncCall)(EnqueueAsyncBlock) = ^(EnqueueAsyncBlock block){
        stubAsyncCall(@"PUT", block);
    };
    
    void (^stubGetAsyncCall)(EnqueueAsyncBlock) = ^(EnqueueAsyncBlock block){
        stubAsyncCall(@"GET", block);
    };
    
    void (^stubDeleteAsyncCall)(EnqueueAsyncBlock) = ^(EnqueueAsyncBlock block){
        stubAsyncCall(@"DELETE", block);
    };
    
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
        
        it(@"should not raise an exception if an attempt is made to remove an object that was not set using the 'removeObjectForKey:' selector", ^{
            [[theBlock(^{
                [newObject removeObjectForKey:key];
            }) shouldNot] raise];
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
        
        it(@"should throw an exception if dataServiceURL is not set on the 'PCFDataSignIn' sharedInstance", ^{
            [[theBlock(^{ [newObject saveSynchronously:nil]; }) should] raiseWithName:NSObjectNotAvailableException];
        });
        
        context(@"Properly setup PCFDataSignIn sharedInstance", ^{
            
            beforeEach(^{
                [PCFDataSignIn sharedInstance].dataServiceURL = @"http://testurl.com";
            });
            
            it(@"should perform PUT synchronously on remote server when 'saveSynchronously:' selector performed", ^{
                __block BOOL didCallBlock = NO;
                
                stubURLConnectionSuccess(^(NSArray *params){
                    NSURLRequest *request = params[0];
                    [[request.HTTPMethod should] equal:@"PUT"];
                    didCallBlock = YES;
                    return [NSData data];
                });
                
                [[theValue([newObject saveSynchronously:nil]) should] beTrue];
                [[theValue(didCallBlock) should] beTrue];
            });
            
            it(@"should contain set key value pairs in request body when 'saveSynchronously:' selector performed", ^{
                stubURLConnectionSuccess(^(NSArray *params){
                    NSURLRequest *request = params[0];
                    NSError *error;
                    id contents = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:&error];
                    [[contents should] equal:expectedContents];
                    [[error should] beNil];
                    return [NSData data];
                });
                
                [[theValue([newObject saveSynchronously:nil]) should] beTrue];
            });
            
            it(@"should populate error object if 'saveSyncronously:' PUT operation fails", ^{
                stubURLConnectionFail();
                
                NSError *error;
                [[theValue([newObject saveSynchronously:&error]) should] beFalse];
                [[error shouldNot] beNil];
            });
            
            it(@"should have the class name and object ID as the path in the HTTP PUT request", ^{
                stubURLConnectionSuccess(^(NSArray *params){
                    NSURLRequest *request = params[0];
                    [[[request.URL relativeString] should] endWithString:[NSString stringWithFormat:@"%@/%@", kTestClassName, kTestObjectID]];
                    return [NSData data];
                });
                
                NSError *error;
                [[theValue([newObject saveSynchronously:&error]) should] beTrue];
            });
            
            it(@"should perform asynchronous PUT method call on data service client when 'saveOnSuccess:failure:' selector performed", ^{
                [[[PCFDataSignIn sharedInstance].dataServiceClient should] receive:@selector(putPath:parameters:success:failure:)];
                [newObject saveOnSuccess:nil failure:nil];
            });
            
            it(@"should have the class name and object ID as the path when 'saveOnSuccess:failure:' selector performed", ^{
                stubPutAsyncCall(^(NSArray *params){
                    NSString *path = params[0];
                    [[path should] endWithString:[NSString stringWithFormat:@"%@/%@", kTestClassName, kTestObjectID]];
                });
                
                [newObject saveOnSuccess:nil failure:nil];
            });
            
            it(@"should contain set key value pairs in request body when 'saveOnSuccess:failure:' selector performed", ^{
                stubPutAsyncCall(^(NSArray *params){
                    NSDictionary *contents = params[1];
                    [[contents should] equal:expectedContents];
                });

                [newObject saveOnSuccess:nil failure:nil];
            });
            
            it(@"should not raise an exception if success or/and failure block are nil", ^{
                stubPutAsyncCall(^(NSArray *params){
                });
                
                [[theBlock(^{
                    [newObject saveOnSuccess:nil failure:nil];
                }) shouldNot] raise];
                
                [[theBlock(^{
                    [newObject saveOnSuccess:nil failure:^(NSError *error) {
                        NSLog(@"Failure Block");
                    }];
                }) shouldNot] raise];
                
                [[theBlock(^{
                    [newObject saveOnSuccess:^{
                        NSLog(@"Success Block");
                    } failure:nil];
                }) shouldNot] raise];
            });
            
            context(@"setting/calling success and failure blocks", ^{
                __block BOOL blockExecuted;
                
                beforeEach(^{
                    blockExecuted = NO;
                });
                
                afterEach(^{
                    [[theValue(blockExecuted) should] beTrue];
                });
                
                it(@"should set success block when performing asynchronous PUT method call on data service", ^{
                    void (^successBlock)(void) = ^{
                        blockExecuted = YES;
                    };
                    
                    void (^failureBlock)(NSError *) = ^(NSError *error){
                        fail(@"Failure block executed unexpectedly.");
                    };
                    
                    stubPutAsyncCall(^(NSArray *params){
                        void (^passedBlockSuccess)(void) = params[2];
                        passedBlockSuccess();
                    });
                    
                    [newObject saveOnSuccess:successBlock failure:failureBlock];
                });
                
                it(@"should set failure block when performing asynchronous PUT method call on data service", ^{
                    void (^successBlock)(void) = ^{
                        fail(@"Success block executed unexpectedly");
                    };
                    
                    void (^failureBlock)(NSError *) = ^(NSError *error){
                        blockExecuted = YES;
                    };
                    
                    stubPutAsyncCall(^(NSArray *params){
                        void (^passedBlockFail)(void) = params[3];
                        passedBlockFail();
                    });
                    
                    [newObject saveOnSuccess:successBlock failure:failureBlock];
                });
            });
        });
    });
    
    context(@"fetching PCFObject instance from the Data Services server", ^{
        
        __block PCFObject *newObject;
        NSData *malformedResponseData = [@"I AM NOT JSON" dataUsingEncoding:NSUTF8StringEncoding];
        
        beforeEach(^{
            newObject = [PCFObject objectWithClassName:kTestClassName];
            newObject.objectID = kTestObjectID;
        });
        
        it(@"should perform GET synchronously on remote server when sync selector performed", ^{
            stubURLConnectionSuccess(^(NSArray *params){
                NSURLRequest *request = params[0];
                [[request.HTTPMethod should] equal:@"GET"];
                [[request.URL.relativePath should] endWithString:[NSString stringWithFormat:@"%@/%@", kTestClassName, kTestObjectID]];
                return [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
            });
            
            [[theValue([newObject fetchSynchronously:nil]) should] beTrue];
        });
        
#warning TODO write tests where objectID is not set
        
        it(@"should populate error object if sync GET operation return empty response data", ^{
            stubURLConnectionFail();

            NSError *error;
            [[theValue([newObject fetchSynchronously:&error]) should] beFalse];
            [[error shouldNot] beNil];
        });
        
        it(@"should populate error object if sync GET operation returns poorly formed JSON", ^{
            stubURLConnectionSuccess(^(NSArray *params){
                NSURLRequest *request = params[0];
                [[request.HTTPMethod should] equal:@"GET"];
                return malformedResponseData;
            });
            
            NSError *error;
            [[theValue([newObject fetchSynchronously:&error]) should] beFalse];
            [[error shouldNot] beNil];
        });
        
        it(@"should perform GET asynchronously on remote server when async GET selector performed", ^{
            __block BOOL didCallBlock = NO;
            stubGetAsyncCall(^(NSArray *params){
                NSString *path = params[0];
                [[path should] endWithString:[NSString stringWithFormat:@"%@/%@", kTestClassName, kTestObjectID]];
                didCallBlock = YES;
            });
            
            [newObject fetchOnSuccess:nil failure:nil];
            [[theValue(didCallBlock) should] beTrue];
        });
        
        it(@"should call success block and populate contents if async GET operation is successful", ^{
            NSDictionary *testResponseObject = @{ @"KEY" : @"VALUE" };
            
            stubGetAsyncCall(^(NSArray *params) {
                void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = params[2];
                successBlock(nil, [NSJSONSerialization dataWithJSONObject:testResponseObject options:0 error:nil]);
            });
            
            __block BOOL didCallBlock = NO;
            [newObject fetchOnSuccess:^(PCFObject *object) {
                didCallBlock = YES;
                [testResponseObject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    [[[newObject objectForKey:key] should] equal:obj];
                }];
                
            } failure:^(NSError *error) {
                fail(@"Should not have been called");
            }];
            [[theValue(didCallBlock) should] beTrue];
        });
        
        it(@"should call failure block if response data is malformed on async GET operation", ^{
            stubGetAsyncCall(^(NSArray *params) {
                void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = params[2];
                successBlock(nil, malformedResponseData);
            });
            
            __block BOOL didCallBlock = NO;
            [newObject fetchOnSuccess:^(PCFObject *object) {
                fail(@"Should not have been called");
                
            } failure:^(NSError *error) {
                didCallBlock = YES;
                [[error shouldNot] beNil];

            }];
            [[theValue(didCallBlock) should] beTrue];
        });
        
        it(@"should call failure block and populate error if async GET operation fails", ^{
            stubGetAsyncCall(^(NSArray *params) {
                void (^failBlock)(AFHTTPRequestOperation *operation, NSError *error) = params[3];
                failBlock(nil, [NSError errorWithDomain:@"Test Domain" code:1 userInfo:nil]);
            });
            
            __block BOOL didCallBlock = NO;
            [newObject fetchOnSuccess:^(PCFObject *object) {
                fail(@"Should not have been called");
                
            } failure:^(NSError *error) {
                didCallBlock = YES;
                [[error shouldNot] beNil];
            }];
            [[theValue(didCallBlock) should] beTrue];
        });
    });
    
    context(@"deleting PCFObject instance from the Data Services server", ^{
        
        __block PCFObject *newObject;
        
        beforeEach(^{
            newObject = [PCFObject objectWithClassName:kTestClassName];
            newObject.objectID = kTestObjectID;
        });
        
        it(@"should perform DELETE synchronously on remote server", ^{
            __block BOOL didCallBlock = NO;
            
            stubURLConnectionSuccess(^(NSArray *params){
                NSURLRequest *request = params[0];
                [[request.HTTPMethod should] equal:@"DELETE"];
                [[request.URL.relativePath should] endWithString:[NSString stringWithFormat:@"%@/%@", kTestClassName, kTestObjectID]];
                didCallBlock = YES;
                return [NSData data];
            });
            
            [[theValue([newObject deleteSynchronously:nil]) should] beTrue];
            [[theValue(didCallBlock) should] beTrue];
        });
        
        it(@"should populate error object if sync DELETE operation fails", ^{
            stubURLConnectionFail();
            
            NSError *error;
            [[theValue([newObject deleteSynchronously:&error]) should] beFalse];
            [[error shouldNot] beNil];
        });
        
        it(@"should perform DELETE asynchronously on remote server", ^{
            __block BOOL didCallBlock = NO;
            stubDeleteAsyncCall(^(NSArray *params){
                NSString *path = params[0];
                [[path should] endWithString:[NSString stringWithFormat:@"%@/%@", kTestClassName, kTestObjectID]];
                didCallBlock = YES;
            });
            
            [newObject deleteOnSuccess:nil failure:nil];
            [[theValue(didCallBlock) should] beTrue];
        });
        
        it(@"should call success block if async DELETE operation is successful", ^{
            __block BOOL blockExecuted;
            
            void (^successBlock)(void) = ^{
                blockExecuted = YES;
            };
            
            void (^failureBlock)(NSError *) = ^(NSError *error){
                fail(@"Failure block executed unexpectedly.");
            };
            
            stubDeleteAsyncCall(^(NSArray *params){
                void (^passedBlock)(void) = params[2];
                passedBlock();
            });
            
            [newObject deleteOnSuccess:successBlock failure:failureBlock];
            [[theValue(blockExecuted) should] beTrue];
        });
        
        it(@"should call failure block if async DELETE operation fails", ^{
            __block BOOL blockExecuted;
            
            void (^successBlock)(void) = ^{
                fail(@"Success block executed unexpectedly.");
            };
            
            void (^failureBlock)(NSError *) = ^(NSError *error){
                blockExecuted = YES;
            };
            
            stubDeleteAsyncCall(^(NSArray *params){
                void (^passedBlockFail)(void) = params[3];
                passedBlockFail();
            });
            
            [newObject deleteOnSuccess:successBlock failure:failureBlock];
            [[theValue(blockExecuted) should] beTrue];
        });
    });
    
#warning TODO: Test OpenID connect token validity
});

SPEC_END
