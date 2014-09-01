//
//  CDFullCollectionViewCell.m
//  HAP
//
//  Created by WozniBob on 8/29/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "CDFullCollectionViewCell.h"
@import AVKit;
@import AVFoundation;

@implementation CDFullCollectionViewCell

- (void)awakeFromNib{
    self.scrollView.minimumZoomScale=1;
    self.scrollView.maximumZoomScale=6.0;
    
    self.scrollView.delegate=self;
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.fullImageView;
}
@end
