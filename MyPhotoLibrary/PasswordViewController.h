//
//  PasswordViewController.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/28/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordViewController : UIViewController <UIDynamicAnimatorDelegate>

@property (strong, nonatomic) IBOutlet UILabel *passLabel;
@property (nonatomic, strong) IBOutlet UITextField* passText;
@property (strong, nonatomic) IBOutlet UIView *passView;
@property (strong, nonatomic) IBOutlet UIImageView *PassImageView;
@end
