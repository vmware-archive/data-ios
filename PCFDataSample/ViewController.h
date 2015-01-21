//
//  ViewController.h
//  PCFDataSample
//
//  Created by DX122-XL on 2015-01-16.
//  Copyright (c) 2015 Pivotal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCFKeyValueObject;

@interface ViewController : UIViewController

@property PCFKeyValueObject *object;

@property IBOutlet UITextField *textField;
@property IBOutlet UISwitch *etagSwitch;
@property IBOutlet UITextView *errorLabel;
@property IBOutlet UITextField *cachedContent;

@end

