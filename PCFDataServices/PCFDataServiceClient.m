//
//  PCFDataServiceClient.m
//  
//
//  Created by Elliott Garcea on 2014-06-06.
//
//

#import "PCFDataServiceClient.h"
#import "PCFDataError.h"

@implementation PCFDataServiceClient

- (BOOL)putPath:(NSString *)path
     parameters:(NSDictionary *)parameters
          error:(NSError **)error
{
    NSURLRequest *request = [self requestWithMethod:@"PUT"
                                               path:path
                                         parameters:parameters];
    
    if (![self verifyRequest:request error:error]) {
        return NO;
    }
    
    NSHTTPURLResponse *response;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&response
                                                             error:error];

}

- (BOOL)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
          error:(NSError **)error
{
    NSURLRequest *request = [self requestWithMethod:@"GET"
                                               path:path
                                         parameters:parameters];

}

- (BOOL)deletePath:(NSString *)path
        parameters:(NSDictionary *)parameters
             error:(NSError **)error
{
    NSURLRequest *request = [self requestWithMethod:@"DELETE"
                                               path:path
                                         parameters:parameters];

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

@end
