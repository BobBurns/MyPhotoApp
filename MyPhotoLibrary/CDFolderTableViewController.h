//
//  CDFolderTableViewController.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 8/20/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CDFolderTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSFetchedResultsController *frc;

@end
