//
//  PCFDataServiceClient.h
//  
//
//  Created by Elliott Garcea on 2014-06-06.
//
//

#import "AFHTTPClient.h"

@interface PCFDataServiceClient : AFHTTPClient

- (BOOL)putPath:(NSString *)path
     parameters:(NSDictionary *)parameters
          error:(NSError **)error;

- (BOOL)getPath:(NSString *)path
     parameters:(NSDictionary *)parameters
          error:(NSError **)error;

- (BOOL)deletePath:(NSString *)path
        parameters:(NSDictionary *)parameters
             error:(NSError **)error;

@end
