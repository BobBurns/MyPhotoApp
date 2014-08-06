//
//  CoreDataGroupVC.m
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/30/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "CoreDataGroupVC.h"

@interface CoreDataGroupVC ()

@end

@implementation CoreDataGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.photoImageView.image = _myPhotoImage;
    self.navigationItem.title = _myPhotoName;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    _photoImageView = nil;
    _myPhotoImage = nil;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
