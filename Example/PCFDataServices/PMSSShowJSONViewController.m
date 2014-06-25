//
//  PMSSShowJSONViewController.m
//  PMSSDataServices Example
//
//  Created by Elliott Garcea on 2014-06-11.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PMSSShowJSONViewController.h"

@interface PMSSShowJSONViewController ()

@property (weak, nonatomic) IBOutlet UITextView *showJSONTextView;

@end

@implementation PMSSShowJSONViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.showJSONTextView setText:self.formattedJSON];
}

@end
