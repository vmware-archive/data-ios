//
//  PMSSObjectSpec.m
//  PMSSDataServices Spec
//
//  Created by DX123-XL on 2014-06-02.
//  Copyright 2014 Pivotal. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <AFNetworking/AFNetworking.h>
#import "AFOAuth2Client.h"
#import "AFHTTPClient+PMSSMethods.h"

#import "PMSSObject+Internal.h"
#import "PMSSDataSignIn+Internal.h"
#import "PMSSDataTestConstants.h"
#import "PMSSDataTestHelpers.h"
#import "PMSSDataError.h"

SPEC_BEGIN(PMSSObjectSpec)

static NSString *const kTestClassName = @"TestClass";
static NSString *const kTestObjectID = @"1234";

describe(@"PMSSObject no Auth in keychain", ^{
    __block PMSSObject *newObject;
    __block BOOL wasBlockExecuted;
    
    void (^failblock)(NSError *) = ^(NSError *error){
        [[error shouldNot] beNil];
        [[theValue(error.code) should] equal:theValue(PMSSDataServicesAuthorizationRequired)];
        wasBlockExecuted = YES;
    };
    
    beforeEach(^{
        stubKeychain(nil);
        
        [AFOAuthCredential deleteCredentialWithIdentifier:kPMSSOAuthCredentialID];
        
        newObject = [PMSSObject objectWithClassName:kTestClassName];
        newObject.objectID = kTestObjectID;
        
        PMSSDataSignIn *signIn = [PMSSDataSignIn sharedInstance];
        signIn.dataServiceURL = kTestDataServiceURL;
        wasBlockExecuted = NO;
    });
    
    afterEach(^{
        [[theValue(wasBlockExecuted) should] beTrue];
    });
    
    it(@"should populate and return error on fetch", ^{
        [newObject fetchOnSuccess:^(PMSSObject *object) {
            fail(@"Should not be called");
            
        } failure:failblock];
    });
    
    it(@"should populate and return error on delete", ^{
        [newObject deleteOnSuccess:^(PMSSObject *object){
            fail(@"Should not be called");
            
        } failure:failblock];
    });
    
    it(@"should populate and return error on save", ^{
        [newObject saveOnSuccess:^(PMSSObject *object){
            fail(@"Should not be called");
            
        } failure:failblock];
    });
});

describe(@"PMSSObject Auth in keychain", ^{
    
    beforeEach(^{
        stubKeychain(nil);
        
        [AFOAuthCredential deleteCredentialWithIdentifier:kPMSSOAuthCredentialID];
        setupDefaultCredentialInKeychain();
    });
    
    context(@"constructing a new instance of a PMSSObject with nil class name", ^{
        typedef void (^AssertBlock)(void);
        void (^assertRaiseInvalidArgumentException)(AssertBlock) = ^(AssertBlock block){
            [[theBlock(block) should] raiseWithName:NSInvalidArgumentException];
        };
        
        it(@"should throw an exception if passed a nil or empty class name", ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused"
            
            //nil call param
            assertRaiseInvalidArgumentException(^{[PMSSObject objectWithClassName:nil];});
            assertRaiseInvalidArgumentException(^{[PMSSObject objectWithClassName:nil dictionary:nil];});
            assertRaiseInvalidArgumentException(^{[[PMSSObject alloc] initWithClassName:nil];});
            
            //empty class param
            assertRaiseInvalidArgumentException(^{[PMSSObject objectWithClassName:@""];});
            assertRaiseInvalidArgumentException(^{[PMSSObject objectWithClassName:@"" dictionary:nil];});
            assertRaiseInvalidArgumentException(^{[[PMSSObject alloc] initWithClassName:@""];});
            
            //NSNull class param
            assertRaiseInvalidArgumentException(^{[PMSSObject objectWithClassName:(id)[NSNull null]];});
            assertRaiseInvalidArgumentException(^{[PMSSObject objectWithClassName:(id)[NSNull null] dictionary:nil];});
            assertRaiseInvalidArgumentException(^{[[PMSSObject alloc] initWithClassName:(id)[NSNull null]];});
#pragma clang diagnostic pop
        });
    });
    
    context(@"constructing an empty new instance of a PMSSObject", ^{
        __block PMSSObject *newObject;
        
        beforeEach(^{
            newObject = nil;
        });
        
        afterEach(^{
            [[newObject.className should] equal:kTestClassName];
            [[newObject.objectID should] beNil];
            [[theValue(newObject.allKeys.count) should] equal:theValue(0)];
        });
        
        it(@"should create a new empty PMSSObject instance with the 'objectWithClassName' selector", ^{
            newObject = [PMSSObject objectWithClassName:kTestClassName];
        });
        
        it(@"should create a new empty PMSSObject instance with the 'objectWithClassName:dictionary:' selector with nil dictionary", ^{
            newObject = [PMSSObject objectWithClassName:kTestClassName dictionary:nil];
        });
        
        it(@"should create a new empty PMSSObject instance with the 'initWithClassName:' selector", ^{
            newObject = [[PMSSObject alloc] initWithClassName:kTestClassName];
        });
    });
    
    context(@"constructing a new populated instance of a PMSSObject", ^{
        NSDictionary *keyValuePairs = @{
                                        @"TestKey1" : @"TestValue1",
                                        @"TestKey2" : @[@"ArrayValue1", @"ArrayValue2", @"ArrayValue3"],
                                        @"TestKey3" : @{@"DictKey1" : @"DictValue1", @"DictKey2" : @"DictValue2", @"DictKey3" : @"DictValue3"},
                                        };

        it(@"should create a new populated PMSSObject instance with the objectID property set when passed as a parameter", ^{
            NSString *testObjectID = @"TestObjectID";
            NSDictionary *keyValuePairs = @{ @"objectID" : @"TestObjectID" };
            PMSSObject *newObject = [PMSSObject objectWithClassName:kTestClassName dictionary:keyValuePairs];
            newObject.objectID = testObjectID;
            
            [[newObject.className should] equal:kTestClassName];
            [[newObject.objectID should] equal:testObjectID];
            [[theValue(newObject.allKeys.count) should] equal:theValue(keyValuePairs.count)];
        });
        
        it(@"should create a new populated PMSSObject instance with set Key Value pairs from dictionary with 'objectWithClassName:dictionary:' selector", ^{
            PMSSObject *newObject = [PMSSObject objectWithClassName:kTestClassName dictionary:keyValuePairs];
            
            [[newObject.className should] equal:kTestClassName];
            [[theValue(newObject.allKeys.count) should] equal:theValue(keyValuePairs.allKeys.count)];
        });
        
        it(@"should set object to key when initialized with 'objectWithClassName:dictionary:' selector", ^{
            PMSSObject *newObject = [PMSSObject objectWithClassName:kTestClassName dictionary:keyValuePairs];
            
            [keyValuePairs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [[[newObject objectForKey:key] should] equal:obj];
            }];
        });
    });
    
    context(@"getting and setting PMSSObject properties", ^{
        __block PMSSObject *newObject;
        static NSString *key = @"TestKey";
        static NSString *object = @"TestObject";

        beforeEach(^{
            newObject = [PMSSObject objectWithClassName:kTestClassName];
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
        
        it(@"should support setting NSData as a value", ^{
            NSData *objectData = [object dataUsingEncoding:NSUTF8StringEncoding];
            [newObject setObject:objectData forKey:key];
            [[[newObject objectForKey:key] should] equal:objectData];
        });
    });
    
    context(@"saving PMSSObject instance to the Data Services server", ^{
        __block PMSSObject *newObject;
        __block NSDictionary *expectedContents;
        
        static NSString *key = @"TestKey";
        static NSString *object = @"TestObject";
        
        beforeEach(^{
            [PMSSDataSignIn setSharedInstance:nil];
            expectedContents = @{ key : object };
            newObject = [PMSSObject objectWithClassName:kTestClassName dictionary:expectedContents];
            newObject.objectID = kTestObjectID;
        });
        
        it(@"should throw an exception if dataServiceURL is not set on the 'PMSSDataSignIn' sharedInstance", ^{
            [[[[PMSSDataSignIn sharedInstance] dataServiceURL] should] beNil];
            [[theBlock(^{ [newObject saveOnSuccess:nil failure:nil]; }) should] raiseWithName:NSObjectNotAvailableException];
        });
        
        context(@"Properly setup PMSSDataSignIn sharedInstance", ^{
            
            typedef void(^NoRaiseBlock)(void);
            void (^shouldNotRaise)(NoRaiseBlock) = ^(NoRaiseBlock block){
                [[theBlock(block) shouldNot] raise];
            };
            
            beforeEach(^{
                setupPMSSDataSignInInstance(nil);
                setupForSuccessfulSilentAuth();
                [PMSSDataSignIn sharedInstance].dataServiceURL = @"http://testurl.com";
            });
            
            it(@"should perform PUT method call on data service client when 'saveOnSuccess:failure:' selector performed", ^{
                AFHTTPClient *client = [[PMSSDataSignIn sharedInstance] dataServiceClient:nil];
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
                    [newObject saveOnSuccess:^(PMSSObject *object){
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
                    void (^successBlock)(PMSSObject *object) = ^(PMSSObject *object){
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
                    void (^successBlock)(PMSSObject *object) = ^(PMSSObject *object){
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
    
    context(@"fetching PMSSObject instance from the Data Services server", ^{
        
        __block PMSSObject *newObject;
        __block BOOL wasBlockExecuted = NO;
        
        NSData *malformedResponseData = [@"I AM NOT JSON" dataUsingEncoding:NSUTF8StringEncoding];
        
        beforeEach(^{
            newObject = [PMSSObject objectWithClassName:kTestClassName];
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
                HTTPSuccessBlock successBlock = params[2];
                successBlock(nil, [NSJSONSerialization dataWithJSONObject:testResponseObject options:0 error:nil]);
            });
            
            [newObject fetchOnSuccess:^(PMSSObject *object) {
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
                HTTPSuccessBlock successBlock = params[2];
                successBlock(nil, malformedResponseData);
            });
            
            [newObject fetchOnSuccess:^(PMSSObject *object) {
                fail(@"Should not have been called");
                
            } failure:^(NSError *error) {
                wasBlockExecuted = YES;
                [[error shouldNot] beNil];
            }];
        });
        
        it(@"should call failure block and populate error if GET operation fails", ^{
            stubGetAsyncCall(^(NSArray *params) {
                HTTPFailureBlock failBlock = params[3];
                failBlock(nil, [NSError errorWithDomain:@"Test Domain" code:1 userInfo:nil]);
            });
            
            [newObject fetchOnSuccess:^(PMSSObject *object) {
                fail(@"Should not have been called");
                
            } failure:^(NSError *error) {
                wasBlockExecuted = YES;
                [[error shouldNot] beNil];
            }];
        });
        
        describe(@"merging data during fetch between local and remote contexts", ^{
            
            __block NSDictionary *remoteData;
            __block NSDictionary *expectedData;
            
            __block void (^testAsynchronously)(PMSSObject *) = ^(PMSSObject *object) {
                [object fetchOnSuccess:^(PMSSObject *returnedObject) {
                    wasBlockExecuted = YES;
                    
                } failure:^(NSError *error) {
                    fail(@"Failure block executed incorrectly");
                }];
            };
            
            beforeEach(^{
                AFHTTPClient *client = [[PMSSDataSignIn sharedInstance] dataServiceClient:nil];
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
            
            it(@"should merge in nested dictionaries", ^{
                remoteData =   @{ @"KEY": @{ @"SUB1" : @"VALUE1", @"SUB2" : @"VALUE2" } };
                expectedData = @{
                                 @"A" : @"A",
                                 @"B" : @"B",
                                 @"C" : @"C",
                                 @"KEY": @{ @"SUB1" : @"VALUE1", @"SUB2" : @"VALUE2" }
                                 };
                testAsynchronously(newObject);
            });
        });
    });
    
    context(@"attempting operations without an object ID set", ^{
        
        __block PMSSObject *newObject;
        __block BOOL wasBlockExecuted = NO;
        
        beforeEach(^{
            newObject = [PMSSObject objectWithClassName:kTestClassName];
            
            wasBlockExecuted = NO;
        });
        
        afterEach(^{
            [[theValue(wasBlockExecuted) should] beTrue];
        });
        
        context(@"objectID not set", ^{
            
            void (^successBlock)(PMSSObject *object) = ^(PMSSObject *object){
                fail(@"Failure block executed unexpectedly.");
            };
            
            void (^failureBlock)(NSError *) = ^(NSError *error){
                [[error.domain should] equal:kPMSSDataServicesErrorDomain];
                [[theValue(error.code) should] equal:theValue(PMSSDataServicesObjectIDRequired)];
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
    
    context(@"deleting PMSSObject instance from the Data Services server", ^{
        
        __block PMSSObject *newObject;
        __block BOOL wasBlockExecuted = NO;
        
        beforeEach(^{
            newObject = [PMSSObject objectWithClassName:kTestClassName];
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
            void (^successBlock)(PMSSObject *object) = ^(PMSSObject *object){
                wasBlockExecuted = YES;
            };
            
            void (^failureBlock)(NSError *) = ^(NSError *error){
                fail(@"Failure block executed unexpectedly.");
            };
            
            stubDeleteAsyncCall(^(NSArray *params){
                HTTPSuccessBlock successBlock = params[2];
                successBlock(nil, nil);
            });
            
            [newObject deleteOnSuccess:successBlock failure:failureBlock];
        });
        
        it(@"should call failure block if DELETE operation fails", ^{
            void (^successBlock)(PMSSObject *object) = ^(PMSSObject *object){
                fail(@"Success block executed unexpectedly.");
            };
            
            void (^failureBlock)(NSError *) = ^(NSError *error){
                wasBlockExecuted = YES;
            };
            
            stubDeleteAsyncCall(^(NSArray *params){
                HTTPSuccessBlock successBlock = params[3];
                successBlock(nil, nil);
            });
            
            [newObject deleteOnSuccess:successBlock failure:failureBlock];
        });
    });
    
    context(@"OpenID connect token validity on data service", ^{
        __block PMSSObject *newObject;
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
            [PMSSDataSignIn setSharedInstance:nil];
            
            newObject = [PMSSObject objectWithClassName:kTestClassName];
            [newObject setObjectID:kTestObjectID];
            [newObject setObjectsForKeysWithDictionary:expectedDictionary];

            setupPMSSDataSignInInstance(nil);
            PMSSDataSignIn *sharedInstance = [PMSSDataSignIn sharedInstance];
            sharedInstance.dataServiceURL = kTestDataServiceURL;
            
            wasBlockExecuted = NO;
        });
        
        afterEach(^{
            [[theValue(wasBlockExecuted) should] beTrue];
            assertObjectEqual(self, expectedDictionary, newObject);
        });
        
        typedef id (^AuthStubBlock)(NSArray *params);
        void (^stubAuthClient)(AuthStubBlock) = ^(AuthStubBlock block){
            [[PMSSDataSignIn sharedInstance].authClient stub:@selector(authenticateUsingOAuthWithPath:refreshToken:success:failure:)
                                                  withBlock:block];
        };
        
        context(@"invalid token", ^{
            void (^failureBlock)(NSError*) = ^(NSError *error) {
                [[theValue(error.code) should] equal:theValue(PMSSDataServicesAuthorizationRequired)];
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
                
                client = [[PMSSDataSignIn sharedInstance] dataServiceClient:nil];
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
            void (^successBlock)(PMSSObject *object) = ^(PMSSObject *object){
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
                
                client = [[PMSSDataSignIn sharedInstance] dataServiceClient:nil];
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
        __block PMSSObject *newObject;
        __block BOOL wasBlockExecuted;
        
        beforeEach(^{
            AFHTTPClient *client = [[PMSSDataSignIn sharedInstance] dataServiceClient:nil];
            [[PMSSDataSignIn sharedInstance] setCredential:[PMSSDataSignIn sharedInstance].credential];
            
            [client stub:@selector(enqueueHTTPRequestOperation:)
               withBlock:^id(NSArray *params) {
                   AFHTTPRequestOperation *operation = params[0];
                   verifyAuthorizationInRequest(self, operation.request);
                   wasBlockExecuted = YES;
                   return nil;
               }];
            
            newObject = [PMSSObject objectWithClassName:kTestClassName];
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
    
    context(@"saving and getting complex data structures", ^{
        __block PMSSObject *newObject;
        __block NSDictionary *expectedDictionary;
        __block NSData *savedRequestData;
        __block BOOL wasPutBlockExecuted;
        __block BOOL wasGetBlockExecuted;
        __block BOOL wasSaveOnSuccessBlockExecuted;
        
        beforeEach(^{
            [PMSSDataSignIn setSharedInstance:nil];
            
            [[PMSSDataSignIn sharedInstance] setDataServiceURL:kTestDataServiceURL];
            [[PMSSDataSignIn sharedInstance] setCredential:[PMSSDataSignIn sharedInstance].credential];

            AFHTTPClient *client = [[PMSSDataSignIn sharedInstance] dataServiceClient:nil];
            
            [client stub:@selector(enqueueHTTPRequestOperation:)
               withBlock:^id(NSArray *params) {
                   AFHTTPRequestOperation *operation = params[0];
                   NSError *error;
                   savedRequestData = operation.request.HTTPBody;
                   NSDictionary *requestDictionary = [NSJSONSerialization JSONObjectWithData:savedRequestData options:0 error:&error];
                   [[error should] beNil];
                   [[requestDictionary should] equal:expectedDictionary];
                   
                   operation.completionBlock();
                   wasPutBlockExecuted = YES;
                   return nil;
               }];
            
            stubGetAsyncCall(^(NSArray *params){
                HTTPSuccessBlock successBlock = params[2];
                wasGetBlockExecuted = YES;
                successBlock(nil, savedRequestData);
            });
            
            newObject = [PMSSObject objectWithClassName:kTestClassName];
            newObject.objectID = kTestObjectID;
            
            wasPutBlockExecuted = NO;
            wasGetBlockExecuted = NO;
            wasSaveOnSuccessBlockExecuted = NO;
        });
        
        afterEach(^{
            [[expectFutureValue(theValue(wasPutBlockExecuted)) shouldEventually] beTrue];
            [[expectFutureValue(theValue(wasGetBlockExecuted)) shouldEventually] beTrue];
            [[expectFutureValue(theValue(wasSaveOnSuccessBlockExecuted)) shouldEventually] beTrue];
        });
        
        it(@"should pass a single key/value pair in the request", ^{
            expectedDictionary = @{ @"TACO" : @"CAT" };
            [newObject setObject:@"CAT" forKey:@"TACO"];
            
            [newObject saveOnSuccess:^(PMSSObject *object) {
                // NOTE - this block run AFTER the fetch is completed since it is asynchronous
                wasSaveOnSuccessBlockExecuted = YES;
            } failure:^(NSError *error) {
                fail(@"Should not have failed");
            }];

            PMSSObject *fetchedObject = [PMSSObject objectWithClassName:kTestClassName];
            fetchedObject.objectID = kTestObjectID;
            
            [fetchedObject fetchOnSuccess:^(PMSSObject *object) {
                assertObjectEqual(self, expectedDictionary, object);
            } failure:^(NSError *error) {
                fail(@"Should not have failed");
            }];
        });
    });
});

SPEC_END
