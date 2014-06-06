//
//  PCFDataServiceClient.h
//  
//
//  Created by Elliott Garcea on 2014-06-06.
//
//

#import "AFHTTPClient.h"

@interface PCFDataServiceClient : AFHTTPClient

- (NSData *)putPath:(NSString *)path
         parameters:(NSDictionary *)parameters
              error:(NSError **)error;

- (NSData *)getPath:(NSString *)path
         parameters:(NSDictionary *)parameters
              error:(NSError **)error;

- (NSData *)deletePath:(NSString *)path
            parameters:(NSDictionary *)parameters
                 error:(NSError **)error;

@end
