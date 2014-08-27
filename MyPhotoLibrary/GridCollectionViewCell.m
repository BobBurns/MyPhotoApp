//
//  GridCollectionViewCell.m
//  NewPhotoAPI
//
//  Created by WozniBob on 8/12/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "GridCollectionViewCell.h"

@interface GridCollectionViewCell ()


@property (strong) IBOutlet UIImageView *imageView;


@end

@implementation GridCollectionViewCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.selectedBackgroundView =
        [[UIView alloc] initWithFrame:CGRectZero];
        
        [self.selectedBackgroundView
         setBackgroundColor:[UIColor greenColor]];
        if (self.isChecked) {
            self.checkMarkView.hidden = NO;
        }
        
    }
    return self;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    self.imageView.image = thumbnailImage;
}


@end
