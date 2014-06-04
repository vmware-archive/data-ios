//
//  PCFDataTestHelpers.h
//  PCFDataServices Spec
//
//  Created by Elliott Garcea on 2014-06-05.
//
//

#import <Foundation/Foundation.h>

void (^setupForSuccessfulSilentAuth)(void);

void (^setupPCFDataSignInInstance)(id<PCFSignInDelegate>);