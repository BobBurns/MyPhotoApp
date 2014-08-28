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
@property (nonatomic, strong) UIImage *displayPhoto;
@property (nonatomic, strong) NSDate *displayDate;
@property (nonatomic, strong) NSString *displayPhotoFilename;
@property (strong, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property (strong, nonatomic) IBOutlet UIView *videoContainerView;
@property (strong, nonatomic) NSURL *videoURL;
@property BOOL isVideo;

- (IBAction)handleDeletePhoto:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *handleExportPhoto;
- (IBAction)handleExportButton:(id)sender;
- (IBAction)handleTrashBarButton:(id)sender;
- (IBAction)handleExportBarButton:(id)sender;

@end
