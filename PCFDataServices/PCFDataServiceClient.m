//
//  PCFDataServiceClient.m
//  
//
//  Created by Elliott Garcea on 2014-06-06.
//
//

#import <AFNetworking/AFNetworking.h>

#import "PCFDataServiceClient.h"
#import "PCFDataError.h"

void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@implementation PCFDataServiceClient

- (NSData *)putPath:(NSString *)path
         parameters:(NSDictionary *)parameters
              error:(NSError **)error
{
    NSURLRequest *request = [self requestWithMethod:@"PUT"
                                               path:path
                                         parameters:parameters];
    
    return [self executeRequest:request error:error];
}

- (NSData *)getPath:(NSString *)path
         parameters:(NSDictionary *)parameters
              error:(NSError **)error
{
    NSURLRequest *request = [self requestWithMethod:@"GET"
                                               path:path
                                         parameters:parameters];
    
    return [self executeRequest:request error:error];
}

- (NSData *)deletePath:(NSString *)path
        parameters:(NSDictionary *)parameters
             error:(NSError **)error
{
    NSURLRequest *request = [self requestWithMethod:@"DELETE"
                                               path:path
                                         parameters:parameters];
    
    return [self executeRequest:request error:error];
}

- (NSData *)executeRequest:(NSURLRequest *)request error:(NSError **)error
{
    if (![self verifyRequest:request error:error]) {
        return NO;
    }
    
    AFURLConnectionOperation *operation = [[AFURLConnectionOperation alloc] initWithRequest:request];
    
    runOnMainQueueWithoutDeadlocking(^{
        [operation start];
        [operation waitUntilFinished];
    });
    
    if (error) {
        *error = [self populateErrorFromOperation:operation];
        
        if (*error) {
            return nil;
        }
    }
    
    return operation.responseData;
}

- (BOOL)verifyRequest:(NSURLRequest *)request error:(NSError **)error
{
    if (!request) {
        if (error) {
            *error = [NSError errorWithDomain:kPCFDataServicesErrorDomain code:PCFDataServicesAuthorizationRequired userInfo:nil];
        }
        return NO;
    }
    return YES;
}

- (NSError *)populateErrorFromOperation:(AFURLConnectionOperation *)operation {
    NSError *error;
    
    if (operation.error) {
        error = operation.error;
        
    } else if (![self hasAcceptableStatusCode:operation.response]) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:operation.responseString forKey:NSLocalizedRecoverySuggestionErrorKey];
        [userInfo setValue:[operation.request URL] forKey:NSURLErrorFailingURLErrorKey];
        [userInfo setValue:operation.request forKey:AFNetworkingOperationFailingURLRequestErrorKey];
        [userInfo setValue:operation.response forKey:AFNetworkingOperationFailingURLResponseErrorKey];
        
        NSInteger statusCode = [self statusCodeFromResponse:operation.response];
        [userInfo setValue:[NSString stringWithFormat:@"Unexpected status code in, got %ld", (long)statusCode] forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:AFNetworkingErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
    }
    
    return error;
}

- (NSUInteger)statusCodeFromResponse:(NSURLResponse *)response
{
    return ([response isKindOfClass:[NSHTTPURLResponse class]]) ? [(NSHTTPURLResponse *)response statusCode] : 200;
}

- (BOOL)hasAcceptableStatusCode:(NSURLResponse *)response {
	if (!response) {
		return NO;
	}
    
    NSUInteger statusCode = [self statusCodeFromResponse:response];
    return ![AFHTTPRequestOperation acceptableStatusCodes] || [[AFHTTPRequestOperation acceptableStatusCodes] containsIndex:statusCode];
}

@end
