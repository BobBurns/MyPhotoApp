//
//  RBDetailViewController.m
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/30/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "RBDetailViewController.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "Folders.h"
#import "Photos.h"

@interface RBDetailViewController ()

@property (nonatomic, strong) Folders *currentFolder;

- (void)savePhoto;
- (void)setupFirstFolder;

@end

@implementation RBDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.tabBarController.tabBar.hidden = YES;
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                               target:self
                               action:@selector(savePhoto)];
    self.navigationItem.rightBarButtonItem = button;
    
    [self.assetImageView setImage:self.assetImage];
    
    //set up current folder
    //CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    //_currentFolder = cdh.defaultFolder;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    self.assetImageView = nil;
}
- (void)dealloc
{
    _assetImage = nil;
    _assetImageView = nil;
    
}
- (void)setupFirstFolder {

    
}

- (IBAction)selectButton:(id)sender {
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    Photos *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:cdh.context];
    // get name metadata 
    
    /*
    if (_currentFolder == nil) {
        NSLog(@"no current folder");
        _currentFolder = cdh.defaultFolder; //possibly overkill
    }
    */
    
    newPhoto.photo =  UIImageJPEGRepresentation(self.assetImage, 1.0); // best quality compression
    newPhoto.date = [NSDate date];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged"
                                                        object:nil];
    
    //[_currentFolder addImagesObject:newPhoto];
    [cdh saveContext];
    
    
    
}

- (void)savePhoto
{
    NSLog(@"This is where we save the picture to our own Library");
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   // self.tabBarController.tabBar.hidden = NO;
}

@end
