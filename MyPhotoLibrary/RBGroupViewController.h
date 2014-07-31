//
//  GroupViewController.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/27/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface RBGroupViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray *assetArray;
@property (nonatomic, strong) NSURL *assetGroupURL;
@property (nonatomic, strong) NSString *assetGroupName;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UITableView *assetTableView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

- (void)addButtonTouched;
- (void)image:(UIImage *) image didFinshSavingWithError: (NSError *) error contnextInfo: (void *) contextInfo;

@end
