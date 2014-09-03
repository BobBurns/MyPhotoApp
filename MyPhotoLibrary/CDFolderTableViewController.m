//
//  CDFolderTableViewController.m
//  MyPhotoLibrary
//
//  Created by WozniBob on 8/20/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "CDFolderTableViewController.h"
#import "FetchGroupCollectionVC.h"
#import "AppDelegate.h"
#import "Folders.h"
#import "Photos.h"

#define kEnterFolderName 1
#define debug 1

@interface CDFolderTableViewController ()

@property (nonatomic, strong) UITextField *folderTextField;

@end

@implementation CDFolderTableViewController

#pragma mark - path

- (NSString *)applicationSupportDirectoryPath {
    NSString *applicationSupportPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    [[NSFileManager defaultManager]
     createDirectoryAtPath:applicationSupportPath
     withIntermediateDirectories:YES
     attributes:nil
     error:nil];
    
    return applicationSupportPath;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureFetch];
    [self performFetch];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

#pragma mark - add Folder

- (void)addItem:sender {
    UIAlertView* enterFolderName = [[UIAlertView alloc] initWithTitle:@"Please enter a name for your folder"
                                                              message:nil
                                                             delegate:(id)self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Ok", nil];
    enterFolderName.tag = kEnterFolderName;
    enterFolderName.alertViewStyle = UIAlertViewStylePlainTextInput;
    _folderTextField = [[UITextField alloc] init];
    _folderTextField = [enterFolderName textFieldAtIndex:0];
    
    [enterFolderName show];
    [_folderTextField becomeFirstResponder];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kEnterFolderName)
    {
        if (buttonIndex == 1) {
            if ([self.folderTextField.text isEqualToString: @""]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Title!" message:@"Please enter a name for your folder" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                alert.tag = kEnterFolderName;
                alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                _folderTextField = [UITextField new];
                _folderTextField = [alert textFieldAtIndex:0];
                [alert show];
                [_folderTextField becomeFirstResponder];
                return;
            }
            for (Folders *folder in self.frc.fetchedObjects) {
                if ([folder.name isEqualToString:_folderTextField.text]) {
                    NSLog(@"Same Folder Name");
                    UIAlertView *alreadyAlert = [[UIAlertView alloc] initWithTitle:@"Duplicate Folder" message:@"Please enter a different name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                    alreadyAlert.tag = kEnterFolderName;
                    alreadyAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    _folderTextField = [UITextField new];
                    _folderTextField = [alreadyAlert textFieldAtIndex:0];
                    [alreadyAlert show];
                    [_folderTextField becomeFirstResponder];
                    return;
                    
                }
            }
            
            CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
            Folders *newFolderName = [NSEntityDescription insertNewObjectForEntityForName:@"Folders" inManagedObjectContext:cdh.context];
            newFolderName.name = _folderTextField.text;
            [cdh backgroundSaveContext];
            [self performFetch];
        }
        
    }
}
#pragma mark - DELEGATE: NSFetchedResultsController

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self.tableView beginUpdates];
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    [self.tableView endUpdates];
}
- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            break;
            
    }
}
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    }
    UITableView *tableView = self.tableView;
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            if (!newIndexPath) {
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } else {
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

#pragma mark - DATA
- (void)performFetch
{
    if (debug==1) {
        NSLog(@"Running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    if (self.frc) {
        [self.frc.managedObjectContext performBlockAndWait:^{
            NSError *error = nil;
            if (![self.frc performFetch:&error]) {
                NSLog(@"Failed to perform fetch: %@", [error localizedDescription]);
            }
            [self.tableView reloadData];
        }];
    } else {
        NSLog(@"Failed to fetch, the fetched results controller is nil.");
    }
}

- (void)configureFetch
{
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    
    NSFetchRequest *folderRequest = [NSFetchRequest fetchRequestWithEntityName:@"Folders"];
    folderRequest.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                            ascending:YES],
                                     nil];
    
    
    [folderRequest setFetchBatchSize:50];
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:folderRequest
                                                   managedObjectContext:cdh.context
                                                     sectionNameKeyPath:nil
                                                              cacheName:nil];
    
    NSLog(@" fetched objects = %lu", (unsigned long)self.frc.fetchedObjects.count);
    self.frc.delegate = (id)self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [[self.frc fetchedObjects] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FolderCell" forIndexPath:indexPath];
    Folders *folder = [self.frc objectAtIndexPath:indexPath];
    cell.textLabel.text = folder.name;
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    self.navigationItem.rightBarButtonItem.enabled = NO;
}
- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    self.navigationItem.rightBarButtonItem.enabled = YES;
}
// override editing to hide button
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if(editing == YES)
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        // Your code for exiting edit mode goes here
    }
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source
        Folders *deletedTarget = [self.frc objectAtIndexPath:indexPath];
        // first delete BLOBS
        [self deleteBlobsWithFolderName:(NSString *)deletedTarget.name];
        [self.frc.managedObjectContext deleteObject:deletedTarget];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        [cdh backgroundSaveContext];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self addItem:self];
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
#pragma mark - handle delete folder

- (void)deleteBlobsWithFolderName:(NSString *)name {
    
    NSString *folderName = name;
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photos"];
    
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"photoAlbum"
                                                                                      ascending:YES],
                               [NSSortDescriptor sortDescriptorWithKey:@"date"
                                                             ascending:YES],
                               nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"photoAlbum.name = %@", folderName];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *folderResults = [cdh.context executeFetchRequest:request error:&error];
    if (!folderResults) {
        NSLog(@"error fetching folders to delete. Error %@", error);
    }
    for (Photos *photo in folderResults) {
        NSString *fileName = photo.fileName;
        if (photo.isVideo) {
            NSString *pathToDelete = [[self applicationSupportDirectoryPath] stringByAppendingPathComponent:fileName];
            [[NSFileManager defaultManager] removeItemAtPath:pathToDelete error:&error];
            if (error) {
                NSLog(@"error: %@", error);
            }
        }
    }
    
    
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"showCollectView"]) {
        
        NSIndexPath *indexPath =
        [self.tableView indexPathForSelectedRow];
        //CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        
        Folders *folderObject = [self.frc.fetchedObjects objectAtIndex:indexPath.row];
        
        FetchGroupCollectionVC *fVC = [segue destinationViewController];
        [fVC setFolderName:folderObject.name];
        
    }
}

@end
