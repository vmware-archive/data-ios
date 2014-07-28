//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import "MSSDataObject.h"

typedef void (^HTTPSuccessBlock)(AFHTTPRequestOperation *, id);
typedef void (^HTTPFailureBlock)(AFHTTPRequestOperation *, NSError *);

@interface MSSDataObject (Internal)

@property (nonatomic, readonly) NSMutableDictionary *contentsDictionary;

@end
