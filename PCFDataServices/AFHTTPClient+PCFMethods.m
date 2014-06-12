//
//  AFHTTPClient+PCFMethods.m
//  
//
//  Created by Elliott Garcea on 2014-06-12.
//
//

#import "AFHTTPClient+PCFMethods.h"

@implementation AFHTTPClient (PCFMethods)

- (void)method:(NSString *)method
          path:(NSString *)path
    parameters:(NSDictionary *)parameters
       success:(HTTPSuccessBlock)success
       failure:(HTTPFailureBlock)failure
{
    if ([method isEqualToString:@"DELETE"]) {
        [self deletePath:path parameters:parameters success:success failure:failure];
        
    } else if ([method isEqualToString:@"PUT"]) {
        [self putPath:path parameters:parameters success:success failure:failure];
        
    } else if ([method isEqualToString:@"GET"]) {
        [self getPath:path parameters:parameters success:success failure:failure];
    }
}

@end
