//
//  CDFullCollectViewController.h
//  HAP
//
//  Created by WozniBob on 8/29/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDFullCollectViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSString *folderName;
@property (nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSIndexPath * startIndex;

- (IBAction)handleDelete:(id)sender;
- (IBAction)handleExport:(id)sender;

@end
