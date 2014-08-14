//
//  GridCollectionViewCell.h
//  NewPhotoAPI
//
//  Created by WozniBob on 8/12/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

@import UIKit;

@interface GridCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *thumbnailImage;
@property BOOL isChecked;

@property (strong, nonatomic) IBOutlet UIImageView *checkMarkView;

@end
