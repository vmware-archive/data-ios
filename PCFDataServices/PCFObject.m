//
//  PCFObject.m
//  
//
//  Created by DX123-XL on 2014-05-30.
//
//

#import "PCFObject.h"

@implementation PCFObject

+ (instancetype)objectWithClassName:(NSString *)className
{
    
}

+ (PCFObject *)objectWithClassName:(NSString *)className dictionary:(NSDictionary *)dictionary
{
    
}

- (id)initWithClassName:(NSString *)newClassName
{
    
}

- (NSArray *)allKeys
{
    
}

#pragma mark -
#pragma mark Get and set

- (id)objectForKey:(NSString *)key
{
    
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    
}

- (void)removeObjectForKey:(NSString *)key
{
    
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    
}

#pragma mark -
#pragma mark Save

- (BOOL)save:(NSError **)error
{
    
}

- (void)saveInBackground
{
    
}

- (void)saveInBackgroundWithBlock:(PCFBooleanResultBlock)block
{
    
}

- (void)saveInBackgroundWithTarget:(id)target selector:(SEL)selector
{
    
}

#pragma mark -
#pragma mark Refresh

- (BOOL)isDataAvailable
{
    
}

- (void)fetch:(NSError **)error
{
    
}

- (void)fetchInBackgroundWithBlock:(PCFObjectResultBlock)block
{
    
}

- (void)fetchInBackgroundWithTarget:(id)target selector:(SEL)selector
{
    
}

#pragma mark -
#pragma mark Delete

- (BOOL)delete:(NSError **)error
{
    
}

- (void)deleteInBackground
{
    
}

- (void)deleteInBackgroundWithBlock:(PCFBooleanResultBlock)block
{
    
}

- (void)deleteInBackgroundWithTarget:(id)target
                            selector:(SEL)selector
{
    
}

#pragma mark -
#pragma Dirtiness

- (BOOL)isDirty
{
    
}

- (BOOL)isDirtyForKey:(NSString *)key
{
    
}

@end

