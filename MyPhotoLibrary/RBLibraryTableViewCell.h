//
//  RBLibraryTableViewCell.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/26/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBLibraryTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *assetGroupNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *assetGroupInfoLabel;
@property (nonatomic, strong) IBOutlet UIImageView *assetGroupTopImageView;

@end
