//
//  FetchGroupCollectionVC.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 8/14/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface FetchGroupCollectionVC : UICollectionViewController

@property (nonatomic, strong) NSArray *resultArray;
@property (strong, nonatomic) NSFetchedResultsController *frc;
@property (strong, nonatomic) NSString *folderName;

- (void)performFetch;

@end
