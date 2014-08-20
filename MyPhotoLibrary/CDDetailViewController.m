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

#import <CoreData/CoreData.h>

#define debug 1

@interface CDDetailViewController ()

@end

@implementation CDDetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self popViewControllerWhenBackgroundIsTouhed];
    [self.photoScrollView setDelegate:(id)self];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Trash Button

- (IBAction)handleDeletePhoto:(id)sender {
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
            CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
            if (![self.photoID isTemporaryID]) {
                Photos *photoToDelete = (Photos *)[cdh.context objectWithID:self.photoID];
                [cdh.context deleteObject:photoToDelete];
                [cdh backgroundSaveContext];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged"
                                                                    object:nil];
                NSLog(@"Photo Deleted");
                [[self navigationController] popViewControllerAnimated:YES];
                
            } else {
                NSLog(@"Couldn't delete Temp ID");
                return;
            }
        } else {
            NSLog(@"Cancled Delete");
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
