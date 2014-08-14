//
//  CDDetailViewController.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 8/14/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CDDetailViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, strong) NSManagedObjectID *photoID;
@property (nonatomic, strong) IBOutlet UIImageView *photoView;
@property (nonatomic, retain) UIAlertView *deleteAlertView;

- (IBAction)handleDeletePhoto:(id)sender;

@end
