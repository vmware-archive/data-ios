//
//  PCFShowJSONViewController.m
//  PCFDataServices Example
//
//  Created by Elliott Garcea on 2014-06-11.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import "PCFShowJSONViewController.h"

@interface PCFShowJSONViewController ()

@property (weak, nonatomic) IBOutlet UITextView *showJSONTextView;

@end

@implementation PCFShowJSONViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.showJSONTextView setText:self.formattedJSON];
}

@end
