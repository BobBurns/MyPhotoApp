//
//  CoreDataGroupVC.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/30/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CoreDataGroupVC : UIViewController


@property (nonatomic, strong) UIImage *myPhotoImage;
@property (nonatomic, strong) NSString *myPhotoName;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;

@end
