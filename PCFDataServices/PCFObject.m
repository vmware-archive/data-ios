//
//  PCFObject.m
//  
//
//  Created by DX123-XL on 2014-05-30.
//
//

#import <AFNetworking/AFNetworking.h>

#import "PCFObject.h"
#import "PCFDataSignIn+Internal.h"
#import "PCFDataError.h"


@interface PCFObject ()

@property (readwrite) NSString *className;
@property (nonatomic) NSMutableDictionary *contentsDictionary;
@property (nonatomic) BOOL isDirty;
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
        self.isDirty = YES;
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
#pragma warning - Must set dirty flag
}

- (void)setObjectsForKeysWithDictionary:(NSDictionary *)dictionary
{
    [self.contentsDictionary addEntriesFromDictionary:dictionary];
#pragma warning - Must set dirty flag
}

- (void)removeObjectForKey:(NSString *)key
{
    [self.contentsDictionary removeObjectForKey:key];
#pragma warning - Must set dirty flag
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

- (NSString *)URLPath
{
    return [NSString stringWithFormat:@"%@/%@", self.className, self.objectID];
}

- (void)saveOnSuccess:(void (^)(void))success
              failure:(void (^)(NSError *error))failure
{
    NSError *error;
    AFHTTPClient *client = [[PCFDataSignIn sharedInstance] dataServiceClient:&error];
    
    if (!client) {
        if (failure) {
            failure(error);
        }
        return;
    }
    
    __block PCFObject *selfReference = self;
    [client putPath:[self URLPath]
         parameters:self.contentsDictionary
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                selfReference.isDirty = NO;
                success();
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self signOutIfRequired:error];
                failure([self failureError:error]);
            }];
}

#pragma mark -
#pragma mark Refresh

- (void)mergeContentsDictionaryWithRemoteValues:(NSDictionary *)remoteValues
{
    NSUInteger newKeys = remoteValues.allKeys.count;
    [self.contentsDictionary setValuesForKeysWithDictionary:remoteValues];
    self.isDirty = self.contentsDictionary.allKeys.count > newKeys;
}

- (NSError *)failureError:(NSError *)error
{
    if ([self isUnauthorizedAccessError:error]) {
        return [NSError errorWithDomain:kPCFDataServicesErrorDomain code:PCFDataServicesAuthorizationRequired userInfo:nil];
        
    } else {
        return error;
    }
}

- (BOOL)isUnauthorizedAccessError:(NSError *)error
{
    return error.domain == NSURLErrorDomain && error.code == 401;
}

- (void)signOutIfRequired:(NSError *)error
{
    if ([self isUnauthorizedAccessError:error]) {
        [[PCFDataSignIn sharedInstance] signOut];
    }
}

- (void)fetchOnSuccess:(void (^)(PCFObject *object))success
               failure:(void (^)(NSError *error))failure
{
    NSError *error;
    AFHTTPClient *client = [[PCFDataSignIn sharedInstance] dataServiceClient:&error];
    
    if (!client) {
        if (failure) {
            failure(error);
        }
        return;
    }
    
    [client getPath:[self URLPath]
         parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSError *error;
                NSDictionary *fetchedContents = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
                
                if (!fetchedContents) {
                    failure(error);
                    
                } else {
                    [self mergeContentsDictionaryWithRemoteValues:fetchedContents];
                    success(self);
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self signOutIfRequired:error];
                failure([self failureError:error]);
            }];
}

#pragma mark -
#pragma mark Delete

- (void)deleteOnSuccess:(void (^)(void))success
                failure:(void (^)(NSError *error))failure
{
    NSError *error;
    AFHTTPClient *client = [[PCFDataSignIn sharedInstance] dataServiceClient:&error];
    
    if (!client) {
        if (failure) {
            failure(error);
        }
        return;
    }
    
    __block PCFObject *selfReference = self;
    [client deletePath:[self URLPath]
            parameters:nil
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   selfReference.isDirty = YES;
                   success();
                   
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   [self signOutIfRequired:error];
                   failure([self failureError:error]);
               }];
}

@end

