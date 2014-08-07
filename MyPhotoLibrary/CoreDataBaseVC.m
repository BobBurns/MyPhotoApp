//
//  CoreDataBaseVC.m
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/30/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "CoreDataBaseVC.h"
#import "AppDelegate.h"
#import "CoreDataGroupVC.h"
#import "CoreDataGroupTVC.h"
#import "Photos.h"
#import "Folders.h"
#import "Faulter.h"

#define debug 1

@interface CoreDataBaseVC ()



@end

@implementation CoreDataBaseVC


#define debug 1

#pragma mark - FETCHING

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


- (void)doNothing {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source




// missed this

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
- (void)configureFetch
{
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    NSError *error = nil;
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    
    NSFetchRequest *folderRequest = [NSFetchRequest fetchRequestWithEntityName:@"Folders"];
    folderRequest.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                            ascending:YES],
                                     nil];
    
    NSPredicate *folderPredicate = [NSPredicate predicateWithFormat:@"name == 'defaultFolder'"];
    [folderRequest setPredicate:folderPredicate];
    self.navigationItem.title = @"default folder";
    
    NSArray *folderFetch = [cdh.context executeFetchRequest:folderRequest error:&error];
    if (!folderFetch) {
        NSLog(@"Error fetching defaultFolder %@ '%@'", error, error.description);
    }
    NSLog(@"folder count: %lu", (unsigned long)[folderFetch count]);
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photos"];
    
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"photoAlbum"
                                                             ascending:YES], nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"photoAlbum.name = 'defaultFolder'"];
    [request setPredicate:predicate];
    
    [request setFetchBatchSize:50];
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                   managedObjectContext:cdh.context
                                                     sectionNameKeyPath:nil
                                                              cacheName:nil];
    NSLog(@" fetched objects = %lu", (unsigned long)self.frc.fetchedObjects.count);
    self.frc.delegate = (id)self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - VIEW

- (void)viewDidLoad
{
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    [self configureFetch];
    [self performFetch];
    //self.clearConfirmActionSheet.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(performFetch)
                                                 name:@"SomethingChanged"
                                               object:nil];
}
- (void)dealloc
{
    self.frc = nil;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    //NSInteger returnCount = 0;
    //id <NSFetchedResultsSectionInfo> sectionInfo = [self.frc sections][section];
    NSInteger objects = [[self.frc fetchedObjects] count];
   
    // not sure how to deal with frc controller and multiple objects in a row
    return objects;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    static NSString *cellIdentifier = @"GroupPhotoCell";
    CoreDataGroupTVC *cell =
    [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    //CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    
    Photos *photoObject = [self.frc.fetchedObjects objectAtIndex:indexPath.row];
    UIImage *groupImage = [UIImage imageWithData:photoObject.photo];
    cell.photoImageView.image = groupImage;
    cell.photoImageName.text = photoObject.name;
    
    //fault objects to save memory
    
    return cell;
}

- (UIImage *)createThumbnail:(UIImage *)inPhoto {
    CGSize size = CGSizeMake(60.0, 60.0);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [inPhoto drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumbnail;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Folders *deletedTarget = [self.frc objectAtIndexPath:indexPath];
        [self.frc.managedObjectContext deleteObject:deletedTarget];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    
    //Folders *item = (Folders *)[self.frc.managedObjectContext existingObjectWithID:_itemID error:nil];
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark - INTERACTION




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    if ([segue.identifier isEqualToString:@"showImage"]) {
        
        NSIndexPath *indexPath =
        [_tableView indexPathForSelectedRow];
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        
        Photos *photoObject = [self.frc.fetchedObjects objectAtIndex:indexPath.row];
        UIImage *groupImage = [UIImage imageWithData:photoObject.photo];
        
        CoreDataGroupVC *groupVC = segue.destinationViewController;
        [groupVC setMyPhotoImage:groupImage];
        [groupVC setMyPhotoName:photoObject.name];
        
        //Fault object to save memory
        [Faulter faultObjectWithID:photoObject.objectID inContext:cdh.context];
        groupImage = nil;
        
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
