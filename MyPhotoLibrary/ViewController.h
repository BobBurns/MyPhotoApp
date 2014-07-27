//
//  ViewController.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/25/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *assetGroupArray;
@property (nonatomic, strong) IBOutlet UITableView *assetGroupTableView;
@property (nonatomic, strong) NSURL *selectedGroupURL;

- (void)setUp;


@end

