//
//  RBDetailViewController.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/30/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBDetailViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIImageView *assetImageView;
@property (nonatomic, strong) UIImage *assetImage;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
- (IBAction)selectButton:(id)sender;


@end
