//
//  CDGroupCell.m
//  MyPhotoLibrary
//
//  Created by WozniBob on 8/13/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "CDGroupCell.h"

@interface CDGroupCell ()


@end

@implementation CDGroupCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.selectedBackgroundView =
        [[UIView alloc] initWithFrame:CGRectZero];
        
        [self.selectedBackgroundView
         setBackgroundColor:[UIColor greenColor]];
        
    }
    return self;
}

- (void)setHasValue:(NSString *)hasValue
{
    _hasValue = hasValue;
    NSLog(@"setting hasValue");
}
- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    self.myImageView.image = thumbnailImage;
}


@end
