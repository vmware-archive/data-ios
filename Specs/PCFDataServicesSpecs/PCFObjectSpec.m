//
//  PCFObjectSpec.m
//  PCFDataServices Spec
//
//  Created by DX123-XL on 2014-06-02.
//  Copyright 2014 Pivotal. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <AFNetworking/AFNetworking.h>
#import "AFOAuth2Client.h"

#import "PCFObject+Internal.h"
#import "PCFDataSignIn+Internal.h"
#import "PCFDataTestConstants.h"
#import "PCFDataTestHelpers.h"
#import "PCFDataError.h"

SPEC_BEGIN(PCFObjectSpec)

static NSString *const kTestClassName = @"TestClass";
static NSString *const kTestObjectID = @"1234";

describe(@"PCFObject no Auth in keychain", ^{
    __block PCFObject *newObject;
    __block BOOL wasBlockExecuted;
    
    void (^failblock)(NSError *) = ^(NSError *error){
        [[error shouldNot] beNil];
        [[theValue(error.code) should] equal:theValue(PCFDataServicesAuthorizationRequired)];
        wasBlockExecuted = YES;
    };
    
    beforeEach(^{
        stubKeychain(nil);
        
        [AFOAuthCredential deleteCredentialWithIdentifier:kPCFOAuthCredentialID];
        
        newObject = [PCFObject objectWithClassName:kTestClassName];
        newObject.objectID = kTestObjectID;
        
        PCFDataSignIn *signIn = [PCFDataSignIn sharedInstance];
        signIn.dataServiceURL = kTestDataServiceURL;
        wasBlockExecuted = NO;
    });
    
    afterEach(^{
        [[theValue(wasBlockExecuted) should] beTrue];
    });
    
    it(@"should populate and return error on fetch", ^{
        [newObject fetchOnSuccess:^(PCFObject *object) {
            fail(@"Should not be called");
            
        } failure:failblock];
    });
    
    it(@"should populate and return error on delete", ^{
        [newObject deleteOnSuccess:^(PCFObject *object){
            fail(@"Should not be called");
            
        } failure:failblock];
    });
    
    it(@"should populate and return error on save", ^{
        [newObject saveOnSuccess:^(PCFObject *object){
            fail(@"Should not be called");
            
        } failure:failblock];
    });
});

describe(@"PCFObject Auth in keychain", ^{
    
    beforeEach(^{
        stubKeychain(nil);
        
        [AFOAuthCredential deleteCredentialWithIdentifier:kPCFOAuthCredentialID];
        setupDefaultCredentialInKeychain();
    });
    
    context(@"constructing a new instance of a PCFObject with nil class name", ^{
        typedef void (^AssertBlock)(void);
        void (^assertRaiseInvalidArgumentException)(AssertBlock) = ^(AssertBlock block){
            [[theBlock(block) should] raiseWithName:NSInvalidArgumentException];
        };
        
        it(@"should throw an exception if passed a nil or empty class name", ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused"
            
            //nil call param
            assertRaiseInvalidArgumentException(^{[PCFObject objectWithClassName:nil];});
            assertRaiseInvalidArgumentException(^{[PCFObject objectWithClassName:nil dictionary:nil];});
            assertRaiseInvalidArgumentException(^{[[PCFObject alloc] initWithClassName:nil];});
            
            //empty class param
            assertRaiseInvalidArgumentException(^{[PCFObject objectWithClassName:@""];});
            assertRaiseInvalidArgumentException(^{[PCFObject objectWithClassName:@"" dictionary:nil];});
            assertRaiseInvalidArgumentException(^{[[PCFObject alloc] initWithClassName:@""];});
            
            //NSNull class param
            assertRaiseInvalidArgumentException(^{[PCFObject objectWithClassName:(id)[NSNull null]];});
            assertRaiseInvalidArgumentException(^{[PCFObject objectWithClassName:(id)[NSNull null] dictionary:nil];});
            assertRaiseInvalidArgumentException(^{[[PCFObject alloc] initWithClassName:(id)[NSNull null]];});
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
    
    context(@"getting and setting PCFObject properties", ^{
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
            [PCFDataSignIn setSharedInstance:nil];
            expectedContents = @{ key : object };
            newObject = [PCFObject objectWithClassName:kTestClassName dictionary:expectedContents];
            newObject.objectID = kTestObjectID;
        });
        
        it(@"should throw an exception if dataServiceURL is not set on the 'PCFDataSignIn' sharedInstance", ^{
            [[[[PCFDataSignIn sharedInstance] dataServiceURL] should] beNil];
            [[theBlock(^{ [newObject saveOnSuccess:nil failure:nil]; }) should] raiseWithName:NSObjectNotAvailableException];
        });
        
        context(@"Properly setup PCFDataSignIn sharedInstance", ^{
            
            typedef void(^NoRaiseBlock)(void);
            void (^shouldNotRaise)(NoRaiseBlock) = ^(NoRaiseBlock block){
                [[theBlock(block) shouldNot] raise];
            };
            
            beforeEach(^{
                setupPCFDataSignInInstance(nil);
                setupForSuccessfulSilentAuth();
                [PCFDataSignIn sharedInstance].dataServiceURL = @"http://testurl.com";
            });
            
            it(@"should perform PUT method call on data service client when 'saveOnSuccess:failure:' selector performed", ^{
                AFHTTPClient *client = [[PCFDataSignIn sharedInstance] dataServiceClient:nil];
                [[client should] receive:@selector(putPath:parameters:success:failure:)];
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
                stubPutAsyncCall(^(NSArray *params){ });
                
                shouldNotRaise(^{
                    [newObject saveOnSuccess:nil failure:nil];
                });
                
                shouldNotRaise(^{
                    [newObject saveOnSuccess:nil failure:^(NSError *error) {
                        NSLog(@"Failure Block");
                    }];
                });
                
                shouldNotRaise(^{
                    [newObject saveOnSuccess:^(PCFObject *object){
                        NSLog(@"Success Block");
                    } failure:nil];
                });
            });
            
            context(@"setting/calling success and failure blocks", ^{
                __block BOOL blockExecuted;
                
                beforeEach(^{
                    blockExecuted = NO;
                });
                
                afterEach(^{
                    [[theValue(blockExecuted) should] beTrue];
                });
                
                it(@"should set success block when performing PUT method call on data service", ^{
                    void (^successBlock)(PCFObject *object) = ^(PCFObject *object){
                        blockExecuted = YES;
                    };
                    
                    void (^failureBlock)(NSError *) = ^(NSError *error){
                        fail(@"Failure block executed unexpectedly.");
                    };
                    
                    stubPutAsyncCall(^(NSArray *params){
                        void (^passedBlockSuccess)(AFHTTPRequestOperation *, NSError *) = params[2];
                        passedBlockSuccess(nil, nil);
                    });
                    
                    [newObject saveOnSuccess:successBlock failure:failureBlock];
                });
                
                it(@"should set failure block when performing PUT method call on data service", ^{
                    void (^successBlock)(PCFObject *object) = ^(PCFObject *object){
                        fail(@"Success block executed unexpectedly");
                    };
                    
                    void (^failureBlock)(NSError *) = ^(NSError *error){
                        blockExecuted = YES;
                    };
                    
                    stubPutAsyncCall(^(NSArray *params){
                        void (^passedBlockFail)(AFHTTPRequestOperation *operation, NSError *error) = params[3];
                        passedBlockFail(nil, nil);
                    });
                    
                    [newObject saveOnSuccess:successBlock failure:failureBlock];
                });
            });
        });
    });
    
    context(@"fetching PCFObject instance from the Data Services server", ^{
        
        __block PCFObject *newObject;
        __block BOOL wasBlockExecuted = NO;
        
        NSData *malformedResponseData = [@"I AM NOT JSON" dataUsingEncoding:NSUTF8StringEncoding];
        
        beforeEach(^{
            newObject = [PCFObject objectWithClassName:kTestClassName];
            newObject.objectID = kTestObjectID;
            
            wasBlockExecuted = NO;
        });
        
        afterEach(^{
            [[theValue(wasBlockExecuted) should] beTrue];
        });
        
        it(@"should perform GET on remote server when GET selector performed", ^{
            stubGetAsyncCall(^(NSArray *params){
                NSString *path = params[0];
                [[path should] endWithString:[NSString stringWithFormat:@"%@/%@", kTestClassName, kTestObjectID]];
                wasBlockExecuted = YES;
            });
            
            [newObject fetchOnSuccess:nil failure:nil];
        });
        
        it(@"should call success block and populate contents if GET operation is successful", ^{
            NSDictionary *testResponseObject = @{ @"KEY" : @"VALUE" };
            
            stubGetAsyncCall(^(NSArray *params) {
                void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = params[2];
                successBlock(nil, [NSJSONSerialization dataWithJSONObject:testResponseObject options:0 error:nil]);
            });
            
            [newObject fetchOnSuccess:^(PCFObject *object) {
                wasBlockExecuted = YES;
                [[object should] equal:newObject];
                
                [testResponseObject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    [[[newObject objectForKey:key] should] equal:obj];
                }];
                
            } failure:^(NSError *error) {
                fail(@"Should not have been called");
            }];
        });
        
        it(@"should call failure block if response data is malformed on GET operation", ^{
            stubGetAsyncCall(^(NSArray *params) {
                void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = params[2];
                successBlock(nil, malformedResponseData);
            });
            
            [newObject fetchOnSuccess:^(PCFObject *object) {
                fail(@"Should not have been called");
                
            } failure:^(NSError *error) {
                wasBlockExecuted = YES;
                [[error shouldNot] beNil];
            }];
        });
        
        it(@"should call failure block and populate error if GET operation fails", ^{
            stubGetAsyncCall(^(NSArray *params) {
                void (^failBlock)(AFHTTPRequestOperation *operation, NSError *error) = params[3];
                failBlock(nil, [NSError errorWithDomain:@"Test Domain" code:1 userInfo:nil]);
            });
            
            [newObject fetchOnSuccess:^(PCFObject *object) {
                fail(@"Should not have been called");
                
            } failure:^(NSError *error) {
                wasBlockExecuted = YES;
                [[error shouldNot] beNil];
            }];
        });
        
        describe(@"merging data during fetch between local and remote contexts", ^{
            
            __block NSDictionary *remoteData;
            __block NSDictionary *expectedData;
            
            __block void (^testAsynchronously)(PCFObject *) = ^(PCFObject *object) {
                [object fetchOnSuccess:^(PCFObject *returnedObject) {
                    wasBlockExecuted = YES;
                    
                } failure:^(NSError *error) {
                    fail(@"Failure block executed incorrectly");
                }];
            };
            
            beforeEach(^{
                AFHTTPClient *client = [[PCFDataSignIn sharedInstance] dataServiceClient:nil];
                [client stub:@selector(getPath:parameters:success:failure:) withBlock:^id(NSArray *params) {
                    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = params[2];
                    successBlock(nil, [NSJSONSerialization dataWithJSONObject:remoteData options:0 error:nil]);
                    return nil;
                }];
                
                [newObject setObjectsForKeysWithDictionary:@{
                                                             @"A" : @"A",
                                                             @"B" : @"B",
                                                             @"C" : @"C",
                                                             }];
            });
            
            afterEach(^{
                assertObjectEqual(self, expectedData, newObject);
            });
            
            it(@"should overwrite existing values with remote values with the same key", ^{
                remoteData =   @{
                                 @"A" : @"A*",
                                 @"B" : @"B*",
                                 @"C" : @"C*",
                                 };
                expectedData = @{
                                 @"A" : @"A*",
                                 @"B" : @"B*",
                                 @"C" : @"C*",
                                 };
                testAsynchronously(newObject);
            });
            
            it(@"should keep local key/values that do not exist remotely", ^{
                remoteData =   @{
                                 @"A" : @"A*",
                                 @"B" : @"B*",
                                 };
                expectedData = @{
                                 @"A" : @"A*",
                                 @"B" : @"B*",
                                 @"C" : @"C",
                                 };
                testAsynchronously(newObject);
            });
            
            it(@"should keep local key/value if remote data is empty", ^{
                remoteData =   @{};
                expectedData = @{
                                 @"A" : @"A",
                                 @"B" : @"B",
                                 @"C" : @"C",
                                 };
                testAsynchronously(newObject);
            });
        });
    });
    
    context(@"attempting operations without an object ID set", ^{
        
        __block PCFObject *newObject;
        __block BOOL wasBlockExecuted = NO;
        
        beforeEach(^{
            newObject = [PCFObject objectWithClassName:kTestClassName];
            
            wasBlockExecuted = NO;
        });
        
        afterEach(^{
            [[theValue(wasBlockExecuted) should] beTrue];
        });
        
        context(@"objectID not set", ^{
            
            void (^successBlock)(PCFObject *object) = ^(PCFObject *object){
                fail(@"Failure block executed unexpectedly.");
            };
            
            void (^failureBlock)(NSError *) = ^(NSError *error){
                [[error.domain should] equal:kPCFDataServicesErrorDomain];
                [[theValue(error.code) should] equal:theValue(PCFDataServicesObjectIDRequired)];
                wasBlockExecuted = YES;
            };
            
            it(@"should fail while deleting on the remote server", ^{
                
                stubDeleteAsyncCall(^(NSArray *params){
                    fail(@"block should not have been called");
                });
                
                [newObject deleteOnSuccess:successBlock failure:failureBlock];
            });
            
            it(@"should fail while fetching on the remote server", ^{
                
                stubGetAsyncCall(^(NSArray *params){
                    fail(@"block should not have been called");
                });
                
                [newObject fetchOnSuccess:successBlock failure:failureBlock];
            });
            
            it(@"should fail while saving on the remote server", ^{
                
                stubPutAsyncCall(^(NSArray *params){
                    fail(@"block should not have been called");
                });
                
                [newObject saveOnSuccess:successBlock failure:failureBlock];
            });
        });
    });
    
    context(@"deleting PCFObject instance from the Data Services server", ^{
        
        __block PCFObject *newObject;
        __block BOOL wasBlockExecuted = NO;
        
        beforeEach(^{
            newObject = [PCFObject objectWithClassName:kTestClassName];
            newObject.objectID = kTestObjectID;
            
            wasBlockExecuted = NO;
        });
        
        afterEach(^{
            [[theValue(wasBlockExecuted) should] beTrue];
        });

        it(@"should perform DELETE on remote server", ^{
            
            stubDeleteAsyncCall(^(NSArray *params){
                NSString *path = params[0];
                [[path should] endWithString:[NSString stringWithFormat:@"%@/%@", kTestClassName, kTestObjectID]];
                wasBlockExecuted = YES;
            });
            
            [newObject deleteOnSuccess:nil failure:nil];
        });
        
        it(@"should call success block if DELETE operation is successful", ^{
            void (^successBlock)(PCFObject *object) = ^(PCFObject *object){
                wasBlockExecuted = YES;
            };
            
            void (^failureBlock)(NSError *) = ^(NSError *error){
                fail(@"Failure block executed unexpectedly.");
            };
            
            stubDeleteAsyncCall(^(NSArray *params){
                void (^passedBlock)(AFHTTPRequestOperation *, NSError *) = params[2];
                passedBlock(nil, nil);
            });
            
            [newObject deleteOnSuccess:successBlock failure:failureBlock];
        });
        
        it(@"should call failure block if DELETE operation fails", ^{
            void (^successBlock)(PCFObject *object) = ^(PCFObject *object){
                fail(@"Success block executed unexpectedly.");
            };
            
            void (^failureBlock)(NSError *) = ^(NSError *error){
                wasBlockExecuted = YES;
            };
            
            stubDeleteAsyncCall(^(NSArray *params){
                void (^passedBlockFail)(AFHTTPRequestOperation *operation, NSError *error) = params[3];
                passedBlockFail(nil, nil);
            });
            
            [newObject deleteOnSuccess:successBlock failure:failureBlock];
        });
    });
    
    context(@"OpenID connect token validity on data service", ^{
        __block PCFObject *newObject;
        __block AFHTTPClient *client;
        __block BOOL wasBlockExecuted;
        __block BOOL wasAuthBlockExecuted;
        __block NSInteger failureCount;
        __block NSDictionary *expectedDictionary;
        
        id (^asyncPathHandlerBlock)(NSArray *) = ^id(NSArray *params) {
            if (failureCount > 0) {
                failureCount--;
                
                void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = params[3];
                failureBlock(nil, unauthorizedError());
                
            } else {
                void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject) = params[2];
                successBlock(nil, [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil]);
            }
            return nil;
        };
        
        beforeAll(^{
            expectedDictionary = @{
                                   @"A" : @"A",
                                   @"B" : @"B",
                                   @"C" : @"C",
                                   };
        });

        beforeEach(^{
            [PCFDataSignIn setSharedInstance:nil];
            
            newObject = [PCFObject objectWithClassName:kTestClassName];
            [newObject setObjectID:kTestObjectID];
            [newObject setObjectsForKeysWithDictionary:expectedDictionary];

            setupPCFDataSignInInstance(nil);
            PCFDataSignIn *sharedInstance = [PCFDataSignIn sharedInstance];
            sharedInstance.dataServiceURL = kTestDataServiceURL;
            
            wasBlockExecuted = NO;
        });
        
        afterEach(^{
            [[theValue(wasBlockExecuted) should] beTrue];
            assertObjectEqual(self, expectedDictionary, newObject);
        });
        
        typedef id (^AuthStubBlock)(NSArray *params);
        void (^stubAuthClient)(AuthStubBlock) = ^(AuthStubBlock block){
            [[PCFDataSignIn sharedInstance].authClient stub:@selector(authenticateUsingOAuthWithPath:refreshToken:success:failure:)
                                                  withBlock:block];
        };
        
        context(@"invalid token", ^{
            void (^failureBlock)(NSError*) = ^(NSError *error) {
                [[theValue(error.code) should] equal:theValue(PCFDataServicesAuthorizationRequired)];
                wasBlockExecuted = YES;
            };

            beforeEach(^{
                setupDefaultCredentialInKeychain();
                
                stubAuthClient(^id(NSArray *params) {
                    wasAuthBlockExecuted = YES;
                    void (^failure)(NSError *) = params[3];
                    failure(unauthorizedError());
                    return nil;
                });
                
                client = [[PCFDataSignIn sharedInstance] dataServiceClient:nil];
                [[client shouldNot] beNil];
                
                wasAuthBlockExecuted = NO;
                
                failureCount = 2;
            });
            
            afterEach(^{
                [[theValue(wasAuthBlockExecuted) should] beTrue];
                assertObjectEqual(self, expectedDictionary, newObject);
            });
            
            it(@"should attempt a token refresh and then call failure block on Fetch HTTP requests", ^{
                [client stub:@selector(getPath:parameters:success:failure:) withBlock:asyncPathHandlerBlock];
                [newObject fetchOnSuccess:nil failure:failureBlock];
            });
            
            it(@"should attempt a token refresh and then call failure block on Delete HTTP requests", ^{
                [client stub:@selector(deletePath:parameters:success:failure:) withBlock:asyncPathHandlerBlock];
                [newObject deleteOnSuccess:nil failure:failureBlock];
            });
            
            it(@"should attempt a token refresh and then call failure block on Save HTTP requests", ^{
                [client stub:@selector(putPath:parameters:success:failure:) withBlock:asyncPathHandlerBlock];
                [newObject saveOnSuccess:nil failure:failureBlock];
            });
        });
        
        context(@"valid token", ^{
            void (^successBlock)(PCFObject *object) = ^(PCFObject *object){
                wasBlockExecuted = YES;
            };
            
            beforeEach(^{
                setupDefaultCredentialInKeychain();
                
                stubAuthClient(^id(NSArray *params) {
                    wasAuthBlockExecuted = YES;
                    void (^success)() = params[2];
                    success(nil);
                    return nil;
                });
                
                client = [[PCFDataSignIn sharedInstance] dataServiceClient:nil];
                [[client shouldNot] beNil];
                
                wasAuthBlockExecuted = NO;
                
                failureCount = 1;
            });
            
            afterEach(^{
                [[theValue(wasAuthBlockExecuted) should] beTrue];
            });
            
            it(@"should attempt a token refresh and then call failure block on Fetch HTTP requests", ^{
                [client stub:@selector(getPath:parameters:success:failure:) withBlock:asyncPathHandlerBlock];
                [newObject fetchOnSuccess:successBlock failure:nil];
            });
            
            it(@"should attempt a token refresh and then call success block on Delete HTTP requests", ^{
                [client stub:@selector(deletePath:parameters:success:failure:) withBlock:asyncPathHandlerBlock];
                [newObject deleteOnSuccess:successBlock failure:nil];
            });
            
            it(@"should attempt a token refresh and then call success block on Save HTTP requests", ^{
                [client stub:@selector(putPath:parameters:success:failure:) withBlock:asyncPathHandlerBlock];
                [newObject saveOnSuccess:successBlock failure:nil];
            });
        });
    });
    
    context(@"Authentication Header Key and Bearer token value", ^{
        __block PCFObject *newObject;
        __block BOOL wasBlockExecuted;
        
        beforeEach(^{
            AFHTTPClient *client = [[PCFDataSignIn sharedInstance] dataServiceClient:nil];
            [[PCFDataSignIn sharedInstance] setCredential:[PCFDataSignIn sharedInstance].credential];
            
            [client stub:@selector(enqueueHTTPRequestOperation:)
               withBlock:^id(NSArray *params) {
                   AFHTTPRequestOperation *operation = params[0];
                   verifyAuthorizationInRequest(self, operation.request);
                   wasBlockExecuted = YES;
                   return nil;
               }];
            
            newObject = [PCFObject objectWithClassName:kTestClassName];
            newObject.objectID = kTestObjectID;
        });
        
        afterEach(^{
            [[theValue(wasBlockExecuted) should] beTrue];
        });
        
        it(@"should be included for Fetch HTTP requests", ^{
            [newObject fetchOnSuccess:nil failure:nil];
        });
        
        it(@"should be included for Delete HTTP requests", ^{
            [newObject deleteOnSuccess:nil failure:nil];
        });
        
        it(@"should be included for Save HTTP requests", ^{
            [newObject saveOnSuccess:nil failure:nil];
        });
    });
});

SPEC_END
