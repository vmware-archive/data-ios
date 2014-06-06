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
    
    static NSString *const kTestClassName = @"objects";
    static NSString *const kTestObjectID = @"1234";
    static NSString *const kTestObjectKey = @"RobField";
    static NSString *const kTestObjectValue = @"Rob likes cats!";
    
    beforeEach(^{
        setupCredentialInKeychain(access_token, refresh_token, expires_in);
        
        setupPCFDataSignInInstance(nil);
        [PCFDataSignIn sharedInstance].dataServiceURL = @"http://data-service.one.pepsi.cf-app.com";
    });
    
    context(@"save, fetch, and delete on data service server", ^{
        
        __block PCFObject *obj1;
        __block PCFObject *obj2;
        __block NSError *error;
        
        beforeEach(^{
            obj1 = [PCFObject objectWithClassName:kTestClassName];
            obj1.objectID = kTestObjectID;
            obj1[kTestObjectKey] = kTestObjectValue;
            [[theValue(obj1.isDirty) should] beTrue];
        });
        
        it(@"should work synchronously", ^{
            if (![obj1 saveSynchronously:&error]) {
                fail(@"Saved failed (error: '%@')", error);
                
            } else {
                [[theValue(obj1.isDirty) should] beFalse];
                obj2 = [PCFObject objectWithClassName:kTestClassName];
                obj2.objectID = kTestObjectID;
                
                if (![obj2 fetchSynchronously:&error]){
                    fail(@"Delete failed (error: '%@')", error);
                    
                } else {
                    [[theValue(obj2.isDirty) should] beFalse];
                    [[obj2[kTestObjectKey] should] equal:obj1[kTestObjectKey]];
                    
                    if (![obj1 deleteSynchronously:&error]) {
                        fail(@"Delete failed (error: '%@')", error);
                        
                    } else {
                        [[theValue(obj1.isDirty) should] beTrue];
                    }
                    
                    //Delete obj with same objectID should fail
                    if ([obj2 deleteSynchronously:&error]) {
                        fail(@"Delete failed (error: '%@')", error);
                    }
                }
            }
        });
        
        it(@"should work asynchronously", ^{
            [obj1 saveOnSuccess:^{
                [[theValue(obj1.isDirty) should] beFalse];
                obj2 = [PCFObject objectWithClassName:kTestClassName];
                obj2.objectID = kTestObjectID;
                
                [obj2 fetchOnSuccess:^(PCFObject *object) {
                    [[theValue(obj2.isDirty) should] beFalse];
                    [[obj2[kTestObjectKey] should] equal:obj1[kTestObjectKey]];
                        
                    [obj1 deleteOnSuccess:^{
                        [[theValue(obj1.isDirty) should] beTrue];
                        
                        [obj2 deleteOnSuccess:^{
                            fail(@"Delete should have failed with same objectID as obj1");
                        } failure:^(NSError *error) {
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
        });
    });
});

SPEC_END