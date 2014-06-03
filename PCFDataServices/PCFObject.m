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

+ (instancetype)objectWithClassName:(NSString *)className dictionary:(NSDictionary *)dictionary
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

- (BOOL)saveAndWait:(NSError **)error
{
    
}

- (void)save
{
    
}

- (void)saveOnSuccess:(void (^)(void))success
              failure:(void (^)(NSError *error))failure
{
    
}

#pragma mark -
#pragma mark Refresh

- (BOOL)isDataAvailable
{
    
}

- (void)fetchAndWait:(NSError **)error
{
    
}

- (void)fetchOnSuccess:(void (^)(void))success
               failure:(void (^)(NSError *error))failure
{
    
}

#pragma mark -
#pragma mark Delete

- (BOOL)deleteAndWait:(NSError **)error
{
    
}

- (void)delete
{
    
}

- (void)deleteOnSuccess:(void (^)(void))success
                failure:(void (^)(NSError *error))failure
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

