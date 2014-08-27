//
//  SelectPhotoViewController.h
//  NewPhotoAPI
//
//  Created by WozniBob on 8/12/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

@import UIKit;
@import Photos;
@import StoreKit;

@interface SelectPhotoViewController : UIViewController <UICollectionViewDataSource, UIApplicationDelegate, UIAlertViewDelegate, SKProductsRequestDelegate>

@property (strong) PHFetchResult *assetsFetchResults;
@property (strong) PHAssetCollection *assetCollection;
@property (nonatomic, strong) NSString *selectFolderName;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *handleActionButton;

- (IBAction)makePhotoHidden:(id)sender;

@end
