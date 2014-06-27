//
//  MSSDataTableViewController.m
//  MSSDataServices Example
//
//  Created by Elliott Garcea on 2014-06-06.
//  Copyright (c) 2014 Pivotal. All rights reserved.
//

#import <MSSDataServices/MSSDataServices.h>

#import "MSSDataTableViewController.h"
#import "MSSShowJSONViewController.h"

#pragma mark - MSSArrayObject

@interface MSSArrayObject : NSObject

@property NSString *keyString;
@property NSString *valueString;

@end

@implementation MSSArrayObject

+ (instancetype)objectWithKey:(NSString *)key value:(NSString *)value
{
    MSSArrayObject *newObj = [[self alloc] init];
    if (newObj) {
        newObj.keyString = key;
        newObj.valueString = value;
    }
    
    return newObj;
}

+ (instancetype)objectWithCollectionName:(NSString *)name objectID:(NSString *)objectID
{
    MSSArrayObject *newObj = [[self alloc] init];
    if (newObj) {
        newObj.keyString = name;
        newObj.valueString = objectID;
    }
    
    return newObj;
}

- (NSString *)collectionName
{
    return self.keyString;
}

- (NSString *)objectID
{
    return self.valueString;
}

@end

#pragma mark - MSSTableViewCell

@interface MSSTableViewCell : UITableViewCell <UITextFieldDelegate>

@property MSSArrayObject *arrayObject;
@property (weak, nonatomic) IBOutlet UITextField *keyTextField;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;

@end

@implementation MSSTableViewCell

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.arrayObject.keyString = self.keyTextField.text;
    self.arrayObject.valueString = self.valueTextField.text;
}

- (IBAction)didEndExit:(id)sender {
    [sender resignFirstResponder];
}

@end

#pragma mark - MSSDataTableViewController

@interface MSSDataTableViewController ()

@property (nonatomic)  MSSObject *syncObject;
@property NSMutableArray *keyValuePairsArray;


@property (strong, nonatomic) IBOutletCollection(UIBarButtonItem) NSArray *barButtonCollection;

@end

@implementation MSSDataTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.toolbarHidden = NO;
    self.keyValuePairsArray = [NSMutableArray arrayWithObject:[MSSArrayObject objectWithCollectionName:@"objects" objectID:@"1234"]];
}

- (MSSObject *)syncObject
{
    if (self.keyValuePairsArray[0] && [self.keyValuePairsArray[0] collectionName] && [self.keyValuePairsArray[0] collectionName].length > 0) {
        if (!_syncObject || ![_syncObject.className isEqualToString:[self.keyValuePairsArray[0] collectionName]]) {
            _syncObject = [MSSObject objectWithClassName:[self.keyValuePairsArray[0] collectionName]];
        }
        return _syncObject;
    }
    
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 86.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.keyValuePairsArray.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row > 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        MSSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"objectIDCell" forIndexPath:indexPath];
        
        MSSArrayObject *arrayObject = self.keyValuePairsArray[indexPath.row];
        cell.arrayObject = arrayObject;
        
        [cell.keyTextField setText:arrayObject.collectionName];
        [cell.keyTextField setDelegate:cell];
        
        [cell.valueTextField setText:arrayObject.objectID];
        [cell.valueTextField setDelegate:cell];

        return cell;
    }

    MSSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"keyValueCell" forIndexPath:indexPath];

    if (indexPath.row < self.keyValuePairsArray.count) {
        MSSArrayObject *arrayObject = self.keyValuePairsArray[indexPath.row];
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
        MSSArrayObject *arrayObject = self.keyValuePairsArray[indexPath.row];
        [self.syncObject removeObjectForKey:arrayObject.keyString];
        
        [self.keyValuePairsArray removeObjectAtIndex:indexPath.row];
        
        [self.tableView reloadData];
    }
}

- (void)resetKeyValuePairsArray
{
    if (self.keyValuePairsArray.count > 1) {
        [self.keyValuePairsArray removeObjectsInRange:NSMakeRange(1, self.keyValuePairsArray.count - 1)];
    }
}

- (IBAction)fetchButtonClicked:(id)sender
{
    if (self.syncObject && [self.keyValuePairsArray[0] objectID]) {
        self.syncObject.objectID = [self.keyValuePairsArray[0] objectID];
        
        [self.syncObject fetchOnSuccess:^(MSSObject *object) {
            [self resetKeyValuePairsArray];
            
            [object.allKeys enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
                [self.keyValuePairsArray addObject:[MSSArrayObject objectWithKey:key value:object[key]]];
            }];

            [self.tableView reloadData];
            
        } failure:^(NSError *error) {
            if (![sender isKindOfClass:[UITextField class]]) {
                UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Fetch Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [view show];
            }
        }];
    }
}

- (IBAction)saveButtonClicked:(id)sender
{
    [self populateSyncObject];
    [self.syncObject saveOnSuccess:^(MSSObject *object){
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Save Success" message:@"Save was successful." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [view show];
        
    } failure:^(NSError *error) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Save Failed" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [view show];
    }];
}

- (IBAction)addButtonClicked:(id)sender
{
    [self.keyValuePairsArray addObject:[MSSArrayObject objectWithKey:@"" value:@""]];
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.keyValuePairsArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (IBAction)objectIDReturned:(UITextField *)sender
{
    [self.keyValuePairsArray[0] setValueString:sender.text];
    
    if ([self.keyValuePairsArray[0] collectionName] && self.keyValuePairsArray.count == 1) {
        [self fetchButtonClicked:sender];
        
    }
    [sender resignFirstResponder];
}

- (IBAction)collectionNameReturned:(UITextField *)sender
{
    [self.keyValuePairsArray[0] setKeyString:sender.text];
    
    if ([self.keyValuePairsArray[0] objectID] && self.keyValuePairsArray.count == 1) {
        [self fetchButtonClicked:sender];
        
    }
    [sender resignFirstResponder];
}

- (IBAction)deleteButtonClicked:(id)sender
{
    self.syncObject.objectID = [self.keyValuePairsArray[0] objectID];
    
    if ([self.keyValuePairsArray[0] objectID]) {
        [self.syncObject deleteOnSuccess:^(MSSObject *object){
            [self resetKeyValuePairsArray];
            [self.tableView reloadData];
            
        } failure:^(NSError *error) {            
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

- (void)populateSyncObject
{
    self.syncObject.objectID = [self.keyValuePairsArray[0] objectID];
    [self.keyValuePairsArray enumerateObjectsUsingBlock:^(MSSArrayObject *obj, NSUInteger idx, BOOL *stop) {
        if (idx > 0 && obj.keyString.length > 0) {
            self.syncObject[obj.keyString] = obj.valueString;
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self populateSyncObject];
    NSDictionary *dict = [self.syncObject performSelector:@selector(contentsDictionary)];
    NSString *formattedString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    [(MSSShowJSONViewController *)[segue destinationViewController] setFormattedJSON:formattedString];
}

@end
