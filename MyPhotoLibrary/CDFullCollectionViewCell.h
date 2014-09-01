//
//  CDFullCollectionViewCell.h
//  HAP
//
//  Created by WozniBob on 8/29/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDFullCollectionViewCell : UICollectionViewCell <UIScrollViewDelegate>

@property (nonatomic) IBOutlet UIImageView *fullImageView;
@property (nonatomic, strong) UIImage *image;
@property BOOL isVideo;
@property (nonatomic, strong) NSURL *videoURL;
@property (strong, nonatomic) IBOutlet UIImageView *playView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end
