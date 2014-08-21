//
//  LibraryRootViewController.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 8/12/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Photos;

@interface LibraryRootViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *libraryFolderName;

@end
