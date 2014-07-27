//
//  RBLibraryTableViewCell.m
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/26/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "RBLibraryTableViewCell.h"

@implementation RBLibraryTableViewCell

@synthesize assetGroupNameLabel;
@synthesize assetGroupInfoLabel;
@synthesize assetGroupTopImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
