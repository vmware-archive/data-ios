//
//  PCFDataTableViewController.m
//  PCFDataServices Example
//
//  Created by Elliott Garcea on 2014-06-06.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <PCFDataServices/PCFDataServices.h>

#import "PCFDataTableViewController.h"

@interface PCFDataTableViewController ()

@property PCFObject *syncObject;

@end

@implementation PCFDataTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.syncObject = [PCFObject objectWithClassName:@"objects"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 44.0f;
    } else {
        return 86.0f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.syncObject.allKeys.count + 2;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row > 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"objectIDCell" forIndexPath:indexPath];
        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"keyValueCell" forIndexPath:indexPath];

    if (indexPath.row -1 < self.syncObject.allKeys.count) {
        NSString *key = self.syncObject.allKeys[indexPath.row-1];
        [(UITextField *)[cell viewWithTag:1] setText:key];
        [(UITextField *)[cell viewWithTag:2] setText:self.syncObject[key]];
    }
    
    return cell;
}

- (IBAction)fetchButtonClicked:(id)sender
{
    NSString *objectID = [(UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] viewWithTag:1] text];
    if (objectID) {
        self.syncObject.objectID = objectID;
        
        [self.syncObject fetchOnSuccess:^(PCFObject *object) {
            [self.tableView reloadData];
            
        } failure:^(NSError *error) {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Fetch Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [view show];
        }];
    }
}

- (IBAction)saveButtonClicked:(id)sender
{
    
}

@end
