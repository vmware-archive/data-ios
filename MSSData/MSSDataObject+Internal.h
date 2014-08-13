//
//  Copyright (C) 2014 Pivotal Software, Inc. All rights reserved.
//

#import "MSSDataObject.h"

typedef void (^HTTPSuccessBlock)(MSSAFHTTPRequestOperation *, id);
typedef void (^HTTPFailureBlock)(MSSAFHTTPRequestOperation *, NSError *);

@interface MSSDataObject (Internal)

@property (nonatomic, readonly) NSMutableDictionary *contentsDictionary;

@end
