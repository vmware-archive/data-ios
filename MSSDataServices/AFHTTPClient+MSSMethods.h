//
//  AFHTTPClient+MSSMethods.h
//  
//
//  Created by Elliott Garcea on 2014-06-12.
//
//

#import "AFHTTPClient.h"

typedef void (^HTTPSuccessBlock)(AFHTTPRequestOperation *, id);
typedef void (^HTTPFailureBlock)(AFHTTPRequestOperation *, NSError *);

@interface AFHTTPClient (MSSMethods)

- (void)method:(NSString *)method
          path:(NSString *)path
    parameters:(NSDictionary *)parameters
       success:(HTTPSuccessBlock)success
       failure:(HTTPFailureBlock)failure;

@end
