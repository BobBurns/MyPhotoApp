//
//  CDGroupCell.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 8/13/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDGroupCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) IBOutlet UIImageView *myImageView;
@property (nonatomic, strong) NSString *hasValue;

@end
