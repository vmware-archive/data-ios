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
static NSString *const id_token = @"eyJhbGciOiJSUzI1NiIsImtpZCI6IjE2NzI5OTRkOTJlZmQ3Zjk0MjEwZjZlNjU1OGJiZmM2ODE5ZTI4MGIifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiaWQiOiIxMDk3MjczMzEzMTA5MjM4NTkwODEiLCJzdWIiOiIxMDk3MjczMzEzMTA5MjM4NTkwODEiLCJhenAiOiI0MDc0MDg3MTgxOTIuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJlbWFpbCI6ImVnYXJjZWFAcGl2b3RhbGxhYnMuY29tIiwiYXRfaGFzaCI6IjVIQlJFSkM3VDV2WG9oNkxYMUNjdlEiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXVkIjoiNDA3NDA4NzE4MTkyLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiaGQiOiJwaXZvdGFsbGFicy5jb20iLCJ0b2tlbl9oYXNoIjoiNUhCUkVKQzdUNXZYb2g2TFgxQ2N2USIsInZlcmlmaWVkX2VtYWlsIjp0cnVlLCJjaWQiOiI0MDc0MDg3MTgxOTIuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJpYXQiOjE0MDIwMDEzNTcsImV4cCI6MTQwMjAwNTI1N30.L9320Ygue8d6TcZe5xTkpq6cg8MUhRVmkIGxTflR_QHgm_dlH_Nl7pdF-KguAW4wuYm_frk6CMnzLBGcow6ppT5T2DBdcZ-WqmD9znu07i9xzeQ0abqP9Gg7JyjEN6PCIG7Yk1cFjX4ha_ula7A1Jy74kapRzNhiAtftseVhJOU";

describe(@"PCF Data Service Integration Tests", ^{
    
    static NSString *const kTestClassName = @"objects";
    static NSString *const kTestObjectID = @"1234";
    
    beforeEach(^{
        setupCredentialInKeychain(access_token, refresh_token, expires_in);
        
        setupPCFDataSignInInstance(nil);
        [PCFDataSignIn sharedInstance].dataServiceURL = @"http://data-service.one.pepsi.cf-app.com";
    });
    
    it(@"should perform save on data service server", ^{
        PCFObject *newObject = [PCFObject objectWithClassName:kTestClassName];
        newObject.objectID = kTestObjectID;
        newObject[@"RobField"] = @"Rob likes beer!";
        
        NSError *error;
        if (![newObject saveSynchronously:&error]) {
            fail(@"Saved failed (error: '%@')", error);
            
        } else {
            PCFObject *newObject2 = [PCFObject objectWithClassName:kTestClassName];
            newObject2.objectID = kTestObjectID;
            if (![newObject2 fetchSynchronously:&error]){
                fail(@"Saved failed (error: '%@')", error);
                
            } else {
                [[newObject2[@"RobField"] should] equal:newObject[@"RobField"]];
            }
        }
    });
});

SPEC_END