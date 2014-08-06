//
//  RBDetailViewController.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/30/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CloudKit/CloudKit.h>

@interface RBDetailViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView *assetImageView;
@property (nonatomic, strong) UIImage *assetImage;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) NSString *assetName;
@property (strong, nonatomic) NSURL *assetURL;


- (IBAction)selectButton:(id)sender;
- (IBAction)moveButton:(id)sender;


@end
