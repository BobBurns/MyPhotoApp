//
//  FetchGroupCollectionVC.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 8/14/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FetchGroupCollectionVC : UICollectionViewController

@property (nonatomic, strong) NSArray *resultArray;

- (void)performFetch;

@end
