//
//  PCFObjectSpec.m
//  PCFDataServices Spec
//
//  Created by DX123-XL on 2014-06-02.
//  Copyright 2014 Pivotal. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "PCFObject.h"


SPEC_BEGIN(PCFObjectSpec)

describe(@"PCFObject", ^{
    
    context(@"constructing a new instance of a PCFObject", ^{
        
        it(@"should create a new empty PCFObject instance with the 'objectWithClassName' selector", ^{
            
        });
        
        it(@"should create a new populated PCFObject instance with the 'objectWithClassName:dictionary:' selector", ^{
            
        });
        
        it(@"should create a new empty PCFObject instance with the 'initWithClassName:' selector", ^{

        });
    });
    
    context(@"getting and settings PCFObject properties", ^{
        
        it(@"should return the previously set object with 'objectForKey:' selector", ^{
            
        });
        
        it(@"should assign object to the key after executing 'setObject:forKey:' selector", ^{
            
        });
        
        it(@"should remove the assigned object from the instance after executing 'removeObjectForKey:' selector", ^{
            
        });
        
        it(@"should support instance[<key>] syntax for retrieving assigned objects from an instance", ^{
            
        });
        
        it(@"should support instance[<key>] = <value> syntax for setting objects on an instance", ^{
            
        });
    });
    
    context(@"saving PCFObject instance to the Data Services server", ^{
        
        it(@"should perform PUT syncronously on remote server when 'saveAndWait:' selector performed", ^{
            
        });
        
        it(@"should populate error object if 'saveAndWait:' PUT operation fails", ^{
        });
        
        it(@"should perform PUT asyncronously on remote server when 'save' selector performed", ^{
            
        });
        
        it(@"should perform PUT asyncronously on remote server when 'saveOnSuccess:failure:' selector performed", ^{
            
        });
        
        it(@"should call success block if PUT operation is successful", ^{
            
        });
        
        it(@"should call failure block if PUT operation fails", ^{
            
        });
    });
    
    context(@"fetching PCFObject instance from the Data Services server", ^{
        it(@"should perform GET syncronously on remote server when 'fetchAndWait:' selector performed", ^{
            
        });
        
        it(@"should populate error object if 'fetchAndWait:' GET operation fails", ^{
        });
        
        it(@"should perform GET asyncronously on remote server when 'fetchOnSuccess:failure:' selector performed", ^{
            
        });
        
        it(@"should call success block if 'fetchOnSuccess:failure:' GET operation is successful", ^{
            
        });
        
        it(@"should call failure block if 'fetchOnSuccess:failure:' GET operation fails", ^{
            
        });
    });
    
    context(@"deleting PCFObject instance from the Data Services server", ^{
        
        it(@"should perform DELETE syncronously on remote server when 'deleteAndWait:' selector performed", ^{
        });
        
        it(@"should populate error object if 'deleteAndWait:' DELETE operation fails", ^{
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
