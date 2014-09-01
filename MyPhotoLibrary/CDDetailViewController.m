//
//  CDDetailViewController.m
//  MyPhotoLibrary
//
//  Created by WozniBob on 8/14/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "CDDetailViewController.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "Photos.h"

@import CoreData;
@import AVFoundation;
@import AVKit;
@import Photos;


#define debug 1

@interface CDDetailViewController ()

@end

@implementation CDDetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self popViewControllerWhenBackgroundIsTouhed];
    [self.photoScrollView setDelegate:(id)self];
    if (!self.isVideo) {
        self.videoContainerView.hidden = YES;
    }
    
    
}
- (void)viewWillAppear:(BOOL)animated {
    
}
#pragma mark - utility file

- (NSString *)applicationSupportDirectoryPath {
    NSString *applicationSupportPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    [[NSFileManager defaultManager]
     createDirectoryAtPath:applicationSupportPath
     withIntermediateDirectories:YES
     attributes:nil
     error:nil];
    
    return applicationSupportPath;
    
}

#pragma mark - interaction

- (void)popViewControllerWhenBackgroundIsTouhed {
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popImage)];
    [tgr setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tgr];
    
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [scrollView viewWithTag:999];
}

- (void)popImage {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidAppear:(BOOL)animated{
    
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    self.photoView.image = self.displayPhoto;
    NSString *dateString = [NSDateFormatter localizedStringFromDate:self.displayDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    self.navigationItem.title = dateString;
    /*
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    if (![self.photoID isTemporaryID]) {
        Photos *photoToDisplay = (Photos *)[cdh.context objectWithID:self.photoID];
        self.photoView.image = [UIImage imageWithData:photoToDisplay.photo];
        self.navigationItem.title = photoToDisplay.name;
        
    } else {
        NSLog(@"Couldn't get photo from temp ID");
    }
     */
}
- (void)viewWillDisappear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showVideo"]) {
        AVPlayerViewController *playerViewController = segue.destinationViewController;
        playerViewController.player = [AVPlayer playerWithURL:self.videoURL];
    }
}

#pragma mark - Trash Button

- (IBAction)handleDeletePhoto:(id)sender {
    
    
}
- (void)dealloc {
    _photoView.image = nil;
    _photoView = nil;
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    if (alertView == self.deleteAlertView) {
        if (buttonIndex == 1) {
            [self deletePhoto];
            
        } else {
            NSLog(@"Cancled Delete");
        }
    } else if (alertView.tag == 2001) {
        if (buttonIndex == 1) {
            [self exportPhoto];
        } else {
            NSLog(@"Canceled Export");
        }
    }
}

- (IBAction)handleExportButton:(id)sender {
}

- (IBAction)handleTrashBarButton:(id)sender {
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    
    self.deleteAlertView = [[UIAlertView alloc] initWithTitle:@"Delete Photo?"
                                                      message:@"Are you sure you want to delete this photo?"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Delete", nil];
    [self.deleteAlertView show];
}

- (IBAction)handleExportBarButton:(id)sender {
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Export Photo?"
                                                      message:@"Are you sure you want to export this photo?"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Export", nil];
    alert.tag = 2001;
    [alert show];
    
}
- (void)deletePhoto {
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    Photos *photoToDelete = (Photos *)[cdh.context objectWithID:self.photoID];
    if ([photoToDelete.isVideo boolValue]) {
        NSError *error;
        //NSURL *URLtoDelete = [NSURL URLWithString:photoToDelete.fileName];
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtURL:self.videoURL error:&error];
        if (error) {
            NSLog(@"error deleting video: %@ '%@'", error, error.description);
        }
    }
    if (![self.photoID isTemporaryID]) {
        NSLog(@"attempting to delte object with tempID");
        
    } else {
        NSLog(@"Couldn't delete Temp ID");
    }
    [cdh.context deleteObject:photoToDelete];
    [cdh backgroundSaveContext];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged"
                                                        object:nil];
    NSLog(@"Photo Deleted");
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)exportPhoto {
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    Photos *photoToExport = (Photos *)[cdh.context objectWithID:self.photoID];
    __block BOOL exportVideo = photoToExport.isVideo.boolValue;
    __block NSURL *videoURL = self.videoURL;
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetChangeRequest = nil;
        
        if (exportVideo) {
            assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
        } else {
            assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:self.displayPhoto];
        }
        PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:nil];
        
        [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
    } completionHandler:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Error creating asset: %@", error);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Export Successful" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alert show];
                
                // [[self navigationController] popViewControllerAnimated:YES];
            });
        }
    }];
}
@end
