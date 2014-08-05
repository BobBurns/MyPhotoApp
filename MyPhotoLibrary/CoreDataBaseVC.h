//
//  CoreDataBaseVC.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/30/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h> 
#import "CoreDataHelper.h"
#import "Folders.h"

@interface CoreDataBaseVC : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *frc;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSManagedObjectID *itemID;

- (void)performFetch;
- (void)doNothing;

@end
