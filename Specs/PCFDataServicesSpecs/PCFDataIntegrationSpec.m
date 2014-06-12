//
//  PCFDataIntegrationSpec.m
//  PCFDataServices Spec
//
//  Created by Elliott Garcea on 2014-06-05.
//
//

#import <Kiwi/Kiwi.h>
#import <AFNetworking/AFNetworking.h>

#import "PCFObject.h"
#import "PCFDataSignIn+Internal.h"
#import "PCFDataTestConstants.h"
#import "PCFDataTestHelpers.h"
#import "PCFDataError.h"

SPEC_BEGIN(PCFIntegrationSpec)

static NSString *const access_token = @"eyJhbGciOiJSUzI1NiJ9.eyJhdWQiOlsianNvLWNsaWVudCJdLCJpc3MiOiJcLyIsImp0aSI6ImIzZDU5MzExLTU0OTgtNGVkZC1hY2UzLWVmZWZhM2NmNTljYiIsImlhdCI6MTQwMjAwMjI1Nn0.1BWSzI3Lt5BMtzwnssp2jzte4wkg4NYNYlr-sUqsWN6hT7ZzDG_QiYejvxh3JnvKOHDBOR4U4hAZ8N1Dja2KV9RR2TB3Xtx1kmI6nhasw2QTD6OWiJKX7vegVU4osbrbmD-4Bbv8xcqP-Yz7aG96C__u1cM7bygL_NPzMLmLQtM";
static NSInteger expires_in =  3600;
static NSString *const refresh_token = @"1/mxmcGA9RRJary4uGXK0couhmT0iYSenz9biDjIlq0NU";

describe(@"PCF Data Service Integration Tests", ^{
    
    static NSString *const kTestClassName = @"ios_integration_spec_object";
    static NSString *const kTestObjectID = @"1234";
    static NSString *const kTestObjectKey = @"RobField";
    static NSString *const kTestObjectValue = @"Rob likes cats!";
    
    beforeEach(^{
        stubKeychain(nil);
        
        setupCredentialInKeychain(access_token, refresh_token, expires_in);
        
        setupPCFDataSignInInstance(nil);
        [PCFDataSignIn sharedInstance].dataServiceURL = @"http://data-service.one.pepsi.cf-app.com";
    });
    
    context(@"save, fetch, and delete on data service server", ^{
        
        __block PCFObject *obj1;
        __block PCFObject *obj2;
        
        beforeEach(^{
            obj1 = [PCFObject objectWithClassName:kTestClassName];
            obj1.objectID = kTestObjectID;
            obj1[kTestObjectKey] = kTestObjectValue;
        });
        
        it(@"should work asynchronously", ^{
            __block BOOL blocksWereExecuted = NO;
            
            [obj1 saveOnSuccess:^(PCFObject *object) {
                obj2 = [PCFObject objectWithClassName:kTestClassName];
                obj2.objectID = kTestObjectID;
                
                [obj2 fetchOnSuccess:^(PCFObject *object) {
                    [[obj2[kTestObjectKey] should] equal:obj1[kTestObjectKey]];
                        
                    [obj1 deleteOnSuccess:^(PCFObject *object) {
                        
                        [obj2 deleteOnSuccess:^(PCFObject *object) {
                            fail(@"Delete should have failed with same objectID as obj1");
                        } failure:^(NSError *error) {
                            blocksWereExecuted = YES;
                            [[error shouldNot] beNil];
                        }];
                        
                    } failure:^(NSError *error) {
                        fail(@"Delete failed (error: '%@')", error);
                    }];

                } failure:^(NSError *error) {
                    fail(@"Delete failed (error: '%@')", error);
                }];

            } failure:^(NSError *error) {
                fail(@"Saved failed (error: '%@')", error);
            }];
            
            [[expectFutureValue(theValue(blocksWereExecuted)) shouldEventually] beTrue];
        });
    });
});

SPEC_END