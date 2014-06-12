//
//  PCFObject.m
//  
//
//  Created by DX123-XL on 2014-05-30.
//
//

#import <AFNetworking/AFNetworking.h>

#import "PCFObject+Internal.h"
#import "PCFDataSignIn+Internal.h"
#import "PCFDataError.h"


#define FAIL_AND_RETURN_WITH_CODE(errorcode) \
    FAIL_AND_RETURN([NSError errorWithDomain:kPCFDataServicesErrorDomain code:(errorcode) userInfo:nil])

#define FAIL_AND_RETURN(error) \
    if (failure) { \
        failure((error)); \
    } \
    return;

#define SUCCEED_AND_RETURN(object) \
    if (success) { \
        success((object)); \
    } \
    return;

@interface PCFObject ()

@property (readwrite) NSString *className;
@property (nonatomic, readwrite) NSMutableDictionary *contentsDictionary;

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

- (NSString *)URLPath
{
    return [NSString stringWithFormat:@"%@/%@", self.className, self.objectID];
}

- (void)saveOnSuccess:(void (^)(PCFObject *object))success
              failure:(void (^)(NSError *error))failure
{
    [self performMethod:@"PUT" parameters:self.contentsDictionary onSuccess:success failure:failure];
}

#pragma mark -
#pragma mark Refresh

- (void)mergeContentsDictionaryWithRemoteValues:(NSDictionary *)remoteValues
{
    [self.contentsDictionary setValuesForKeysWithDictionary:remoteValues];
}

- (NSError *)authorizationRequiredError
{
    return [NSError errorWithDomain:kPCFDataServicesErrorDomain code:PCFDataServicesAuthorizationRequired userInfo:nil];
}

- (NSError *)failureError:(NSError *)error
{
    if ([self isUnauthorizedAccessError:error]) {
        return [self authorizationRequiredError];
        
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
    [self performMethod:@"GET" parameters:nil onSuccess:success failure:failure];
}

#pragma mark -
#pragma mark Delete

- (void)deleteOnSuccess:(void (^)(PCFObject *object))success
                failure:(void (^)(NSError *error))failure
{
    [self performMethod:@"DELETE" parameters:nil onSuccess:success failure:failure];
}

#pragma mark -
#pragma mark HTTP Methods

- (void)performMethod:(NSString *)method
           parameters:(NSDictionary *)parameters
            onSuccess:(void (^)(PCFObject *object))success
              failure:(void (^)(NSError *error))failure
{
    [self performMethod:method withNumberOfAttempts:2 parameters:parameters onSuccess:success failure:failure];
}

- (void)performMethod:(NSString *)method
 withNumberOfAttempts:(NSInteger)attempts
           parameters:(NSDictionary *)parameters
            onSuccess:(void (^)(PCFObject *object))success
              failure:(void (^)(NSError *error))failure
{
    if (!self.objectID || self.objectID.length <= 0) {
        FAIL_AND_RETURN_WITH_CODE(PCFDataServicesObjectIDRequired);
    }
    
    if (attempts <= 0) {
        FAIL_AND_RETURN_WITH_CODE(PCFDataServicesAuthorizationRequired);
    }
    
    NSError *error;
    AFHTTPClient *client = [[PCFDataSignIn sharedInstance] dataServiceClient:&error];
    
    if (!client) {
        FAIL_AND_RETURN(error);
    }
    
    void (^successBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        SUCCEED_AND_RETURN(self);
    };
    
    void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error){
        if ([self isUnauthorizedAccessError:error]) {
            [[PCFDataSignIn sharedInstance] authenticateWithInteractiveOption:NO success:^(AFOAuthCredential *credential) {
                [self performMethod:method withNumberOfAttempts:attempts-1 parameters:parameters onSuccess:success failure:failure];
                
            } failure:^(NSError *error) {
                FAIL_AND_RETURN([self failureError:error]);
            }];
            
        } else {
            [self signOutIfRequired:error];
            
            FAIL_AND_RETURN([self failureError:error]);
        }
    };
    
    if ([method isEqualToString:@"DELETE"]) {
        [client deletePath:[self URLPath] parameters:parameters success:successBlock failure:failureBlock];
        
    } else if ([method isEqualToString:@"PUT"]) {
        [client putPath:[self URLPath] parameters:parameters success:successBlock failure:failureBlock];
        
    } else if ([method isEqualToString:@"GET"]) {
        void (^fetchSuccessBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
            if (responseObject) {
                NSError *error;
                NSDictionary *fetchedContents = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
                
                if (fetchedContents) {
                    [self mergeContentsDictionaryWithRemoteValues:fetchedContents];
                    SUCCEED_AND_RETURN(self);
                    
                } else {
                    FAIL_AND_RETURN(error);
                }
            } else {
                NSDictionary *userInfo = operation ? @{ @"HTTPRequestOperation" : operation } : nil;
                NSError *error = [NSError errorWithDomain:kPCFDataServicesErrorDomain code:PCFDataServicesEmptyResponseData userInfo:userInfo];
                FAIL_AND_RETURN(error);
            }
        };
        
        [client getPath:[self URLPath] parameters:parameters success:fetchSuccessBlock failure:failureBlock];
    }
}

@end

