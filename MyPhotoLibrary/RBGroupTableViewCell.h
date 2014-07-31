//
//  RBGroupTableViewCell.h
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/29/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBGroupTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *assetImageView1;
@property (nonatomic, strong) IBOutlet UIImageView *assetImageView2;
@property (nonatomic, strong) IBOutlet UIImageView *assetImageView3;
@property (nonatomic, strong) IBOutlet UIImageView *assetImageView4;

@property (nonatomic, strong) IBOutlet UIButton *assetButton1;
@property (nonatomic, strong) IBOutlet UIButton *assetButton2;
@property (nonatomic, strong) IBOutlet UIButton *assetButton3;
@property (nonatomic, strong) IBOutlet UIButton *assetButton4;

@end
