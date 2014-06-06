//
//  PCFDataViewController.m
//  PCFDataServices Example
//
//  Created by Elliott Garcea on 2014-06-06.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFDataViewController.h"

#import <PCFDataServices/PCFDataServices.h>

@interface PCFDataViewController ()

@property (weak, nonatomic) IBOutlet UITextField *objectIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *keyTextField;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;

@property PCFObject *syncObject;

@end

@implementation PCFDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.syncObject = [PCFObject objectWithClassName:@"objects"];
}

- (IBAction)saveButtonClicked:(id)sender {
    self.syncObject.objectID = self.objectIDTextField.text;
    
    self.syncObject[self.keyTextField.text] = self.valueTextField.text;
    [self.syncObject saveOnSuccess:^{
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Save Success!" message:@"Save on remote server was successful." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [view show];
        
    } failure:^(NSError *error) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Save Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [view show];
    }];
}

- (IBAction)fetchButtonClicked:(id)sender {
    if (self.objectIDTextField.text.length > 0) {
        self.syncObject.objectID = self.objectIDTextField.text;
        
        [self.syncObject fetchOnSuccess:^(PCFObject *object) {
            NSString *key = [object allKeys][0];
            
            if (self.keyTextField.text.length > 0) {
                key = self.keyTextField.text;
            }
            
            self.keyTextField.text = key;
            self.valueTextField.text = object[key];
            
        } failure:^(NSError *error) {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Fetch Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [view show];
        }];
    }
}
@end
