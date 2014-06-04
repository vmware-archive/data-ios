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

- (BOOL)saveSynchronously:(NSError **)error
{
    NSURLRequest *request = [[PCFDataSignIn sharedInstance].dataServiceClient requestWithMethod:@"PUT"
                                                                                           path:[self URLPath]
                                                                                     parameters:self.contentsDictionary];
    NSHTTPURLResponse *response;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:error];
    
    if (responseData) {
        self.isDirty = NO;
        return YES;
    } else {
        return NO;
    }
}

- (void)saveOnSuccess:(void (^)(void))success
              failure:(void (^)(NSError *error))failure
{
    __block PCFObject *selfReference = self;
    [[PCFDataSignIn sharedInstance].dataServiceClient putPath:[self URLPath]
                                                   parameters:self.contentsDictionary
                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                          selfReference.isDirty = NO;
                                                          success();
                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                          failure(error);
                                                      }];
}

#pragma mark -
#pragma mark Refresh

- (BOOL)fetchSynchronously:(NSError **)error
{
    NSURLRequest *request = [[PCFDataSignIn sharedInstance].dataServiceClient requestWithMethod:@"GET"
                                                                                           path:[self URLPath]
                                                                                     parameters:nil];
    
    if (!request) {
        if (error) {
            *error = [NSError errorWithDomain:kPCFDataServicesErrorDomain code:PCFDataServicesAuthorizationRequired userInfo:nil];
        }
        return NO;
    }
    
    NSHTTPURLResponse *response;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:error];
    if (!responseData) {
        return NO;
    }
    
    NSDictionary *fetchedContents = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:error];
    
    if (!fetchedContents) {
        return NO;
    }
    
    [self.contentsDictionary setValuesForKeysWithDictionary:fetchedContents];
    
    self.isDirty = NO;
    return YES;
}

- (void)fetchOnSuccess:(void (^)(PCFObject *object))success
               failure:(void (^)(NSError *error))failure
{
    [[PCFDataSignIn sharedInstance].dataServiceClient getPath:[self URLPath]
                                                   parameters:nil
                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                          NSError *error;
                                                          id JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
                                                          
                                                          if (!JSON) {
                                                              failure(error);
                                                              
                                                          } else {
                                                              [self.contentsDictionary setValuesForKeysWithDictionary:JSON];
                                                              self.isDirty = NO;
                                                              success(self);
                                                          }
                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                          failure(error);
                                                      }];
}

#pragma mark -
#pragma mark Delete

- (BOOL)deleteSynchronously:(NSError **)error
{
    NSURLRequest *request = [[PCFDataSignIn sharedInstance].dataServiceClient requestWithMethod:@"DELETE"
                                                                                           path:[self URLPath]
                                                                                     parameters:nil];
    NSHTTPURLResponse *response;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:error];
    
    if (responseData) {
        self.isDirty = YES;
        return YES;
    } else {
        return NO;
    }
}

- (void)deleteOnSuccess:(void (^)(void))success
                failure:(void (^)(NSError *error))failure
{
    __block PCFObject *selfReference = self;
    [[PCFDataSignIn sharedInstance].dataServiceClient deletePath:[self URLPath]
                                                      parameters:nil
                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                             selfReference.isDirty = YES;
                                                             success();
                                                             
                                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                             failure(error);
                                                         }];
}

@end

