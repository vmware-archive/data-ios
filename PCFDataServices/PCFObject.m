//
//  PCFObject.m
//  
//
//  Created by DX123-XL on 2014-05-30.
//
//

#import "PCFObject.h"

@interface PCFObject ()

@property (readwrite) NSString *className;

@property (nonatomic) NSMutableDictionary *contentsDictionary;

@end

@implementation PCFObject

+ (instancetype)objectWithClassName:(NSString *)className
{
    return [[self alloc] initWithClassName:className];
}

+ (instancetype)objectWithClassName:(NSString *)className dictionary:(NSDictionary *)dictionary
{
    PCFObject *instance = [[self alloc] initWithClassName:className];
    [instance setObjectsForKeysWithDictionary:dictionary];
    return instance;
}

- (id)initWithClassName:(NSString *)className
{
    if (!className || className == (id)[NSNull null] || className.length <= 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"invalid className argument " userInfo:nil];
    }
    
    self = [super init];
    if (self) {
        self.className = className;
        self.contentsDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray *)allKeys
{
    return [self.contentsDictionary allKeys];
}

#pragma mark -
#pragma mark Get and set

- (id)objectForKey:(NSString *)key
{
    return self.contentsDictionary[key];
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    self.contentsDictionary[key] = object;
}

- (void)setObjectsForKeysWithDictionary:(NSDictionary *)dictionary
{
    [self.contentsDictionary addEntriesFromDictionary:dictionary];
}

- (void)removeObjectForKey:(NSString *)key
{
    [self.contentsDictionary removeObjectForKey:key];
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    return self.contentsDictionary[key];
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    self.contentsDictionary[key] = object;
}

#pragma mark -
#pragma mark Save

- (BOOL)saveSynchronously:(NSError **)error
{
    return YES;
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
    return YES;
}

- (void)fetchSynchronously:(NSError **)error
{
    
}

- (void)fetchOnSuccess:(void (^)(void))success
               failure:(void (^)(NSError *error))failure
{
    
}

#pragma mark -
#pragma mark Delete

- (BOOL)deleteSynchronously:(NSError **)error
{
    return YES;
}

- (void)deleteOnSuccess:(void (^)(void))success
                failure:(void (^)(NSError *error))failure
{
    
}

#pragma mark -
#pragma Dirtiness

- (BOOL)isDirty
{
    return YES;
}

- (BOOL)isDirtyForKey:(NSString *)key
{
    return YES;
}

@end

