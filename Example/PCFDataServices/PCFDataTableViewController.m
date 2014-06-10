//
//  PCFDataTableViewController.m
//  PCFDataServices Example
//
//  Created by Elliott Garcea on 2014-06-06.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <PCFDataServices/PCFDataServices.h>

#import "PCFDataTableViewController.h"

#pragma mark - PCFArrayObject

@interface PCFArrayObject : NSObject

@property NSString *keyString;
@property NSString *valueString;

@end

@implementation PCFArrayObject

+ (instancetype)objectWithKey:(NSString *)key value:(NSString *)value
{
    PCFArrayObject *newObj = [[self alloc] init];
    if (newObj) {
        newObj.keyString = key;
        newObj.valueString = value;
    }
    
    return newObj;
}

@end

#pragma mark - PCFTableViewCell

@interface PCFTableViewCell : UITableViewCell <UITextFieldDelegate>

@property PCFArrayObject *arrayObject;
@property (weak, nonatomic) IBOutlet UITextField *keyTextField;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;

@end

@implementation PCFTableViewCell

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.arrayObject.keyString = self.keyTextField.text;
    self.arrayObject.valueString = self.valueTextField.text;
}

- (IBAction)didEndExit:(id)sender {
    [sender resignFirstResponder];
}

@end

#pragma mark - PCFDataTableViewController

@interface PCFDataTableViewController ()

@property PCFObject *syncObject;
@property NSString *objectID;
@property NSMutableArray *keyValuePairsArray;

@property (strong, nonatomic) IBOutletCollection(UIBarButtonItem) NSArray *barButtonCollection;

@end

@implementation PCFDataTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.toolbarHidden = NO;
    self.syncObject = [PCFObject objectWithClassName:@"objects"];
    self.keyValuePairsArray = [NSMutableArray array];
    
    UILabel *dirtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
    dirtyLabel.textAlignment = NSTextAlignmentRight;
    dirtyLabel.text = @"Dirty";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:dirtyLabel];
    [self updateDirtyLabel];
}

- (void)updateDirtyLabel
{
    [(UILabel *)self.navigationItem.rightBarButtonItem.customView setTextColor:self.syncObject.isDirty ? [UIColor redColor] : [UIColor lightGrayColor]];
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
    return self.keyValuePairsArray.count + 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row > 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"objectIDCell" forIndexPath:indexPath];
        [(UITextField *)[cell viewWithTag:1] setText:self.objectID];

        return cell;
    }

    PCFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"keyValueCell" forIndexPath:indexPath];

    if (indexPath.row -1 < self.keyValuePairsArray.count) {
        PCFArrayObject *arrayObject = self.keyValuePairsArray[indexPath.row-1];
        cell.arrayObject = arrayObject;

        [cell.keyTextField setText:arrayObject.keyString];
        [cell.keyTextField setDelegate:cell];
        
        [cell.valueTextField setText:arrayObject.valueString];
        [cell.valueTextField setDelegate:cell];
    }
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PCFArrayObject *arrayObject = self.keyValuePairsArray[indexPath.row - 1];
        [self.syncObject removeObjectForKey:arrayObject.keyString];
        
        [self.keyValuePairsArray removeObjectAtIndex:indexPath.row - 1];
        [self updateDirtyLabel];
        
        [self.tableView reloadData];
    }
}

- (IBAction)fetchButtonClicked:(id)sender
{
    if (self.objectID) {
        self.syncObject.objectID = self.objectID;
        
        [self.syncObject fetchOnSuccess:^(PCFObject *object) {
            self.keyValuePairsArray = [NSMutableArray array];
            [object.allKeys enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
                [self.keyValuePairsArray addObject:[PCFArrayObject objectWithKey:key value:object[key]]];
            }];

            [self updateDirtyLabel];
            [self.tableView reloadData];
            
        } failure:^(NSError *error) {
            [self updateDirtyLabel];
            
            if (![sender isKindOfClass:[UITextField class]]) {
                UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Fetch Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [view show];
            }
        }];
    }
}

- (IBAction)saveButtonClicked:(id)sender
{
    [self.keyValuePairsArray enumerateObjectsUsingBlock:^(PCFArrayObject *obj, NSUInteger idx, BOOL *stop) {
        
        if (obj.keyString.length > 0) {
            self.syncObject[obj.keyString] = obj.valueString;
        }
    }];
    
    [self.syncObject saveOnSuccess:^{
        [self updateDirtyLabel];
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Save Success" message:@"Save was successful." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [view show];
        
    } failure:^(NSError *error) {
        [self updateDirtyLabel];
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Save Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [view show];
    }];
}

- (IBAction)addButtonClicked:(id)sender
{
    [self.keyValuePairsArray addObject:[PCFArrayObject objectWithKey:@"" value:@""]];
    [self updateDirtyLabel];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.keyValuePairsArray.count inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (IBAction)objectIDReturned:(UITextField *)sender
{
    self.objectID = sender.text;
    
    if (self.keyValuePairsArray.count == 0) {
        [self fetchButtonClicked:sender];
        
    }
    [sender resignFirstResponder];
}

- (IBAction)deleteButtonClicked:(id)sender
{
    if (self.objectID) {
        [self.syncObject deleteOnSuccess:^{
            self.objectID = nil;
            self.keyValuePairsArray = [NSMutableArray array];
            [self updateDirtyLabel];
            [self.tableView reloadData];
            
        } failure:^(NSError *error) {
            [self updateDirtyLabel];
            
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Delete Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [view show];
        }];
    }
}

- (IBAction)editButtonClicked:(id)sender
{
    self.tableView.editing = !self.tableView.editing;
    
    [self.barButtonCollection enumerateObjectsUsingBlock:^(UIBarButtonItem *item, NSUInteger idx, BOOL *stop) {
        if (item != sender) {
            item.enabled = !self.tableView.editing;
        }
    }];
}
@end
