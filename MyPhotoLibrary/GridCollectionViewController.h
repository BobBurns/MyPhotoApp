//
//  GridCollectionViewController.h
//  NewPhotoAPI
//
//  Created by WozniBob on 8/12/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

@import UIKit;
@import Photos;

@interface GridCollectionViewController : UICollectionViewController

@property (strong) PHFetchResult *assetsFetchResults;
@property (strong) PHAssetCollection *assetCollection;
@property (strong, nonatomic) IBOutlet UIImageView *checkView;
@property (strong, nonatomic) IBOutlet UINavigationItem *myNavigationItem;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *handleActionButton;

- (IBAction)actionButtonClicked:(id)sender;

@end
