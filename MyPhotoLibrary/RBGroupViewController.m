//
//  GroupViewController.m
//  MyPhotoLibrary
//
//  Created by WozniBob on 7/27/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "RBGroupViewController.h"
#import "RBGroupTableViewCell.h"
#import "RBDetailViewController.h"


@interface RBGroupViewController ()

- (void)retrieveAssetGroupByURL;
- (void)enumerateGroupAssetsForGroup:(ALAssetsGroup *)group;
- (BOOL)writeImageToFile:(UIImage *)image;

@end

@implementation RBGroupViewController

- (void)dealloc
{
    _assetArray = nil;
    _assetGroupURL = nil;
    _assetGroupName = nil;
    _assetsLibrary = nil;
}

- (void)addButtonTouched
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        
        [imagePicker setDelegate:(id)self];
        
        [self presentViewController:imagePicker
                           animated:YES
                         completion:nil];
    } else {
        NSString *errMsg = @"Camera Not Available";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:errMsg
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}
#pragma mark - Image Picker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!selectedImage) {
        selectedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    
    if (![self writeImageToFile:selectedImage]) {
        NSLog(@"Error writing image");
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinshSavingWithError:(NSError *)error contnextInfo:(void *)contextInfo
{
    if (error != nil) {
        NSLog(@"Error Saving:%@", error.localizedDescription);
        return;
    }
    [self.assetArray removeAllObjects];
    [self retrieveAssetGroupByURL];
}



#pragma mark - CoreData File

- (BOOL)writeImageToFile:(UIImage *)image
{
    NSLog(@"writeImageToFile called");
    return YES;
}

#pragma mark - TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger returnCount = 0;
    
    if (_assetArray && ([_assetArray count] > 0)) {
        if ([_assetArray count] % 4 == 0) {
            returnCount = ([_assetArray count] / 4);
        } else {
            returnCount = ([_assetArray count] / 4) + 1;
        }
    }
    return returnCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"AssetGroupTableCell";
    RBGroupTableViewCell *cell = (RBGroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    
    ALAsset *firstAsset = [_assetArray objectAtIndex:indexPath.row * 4];
    
    [cell.assetButton1 setImage:[UIImage imageWithCGImage:[firstAsset thumbnail]]
                       forState:UIControlStateNormal];
    
    [cell.assetButton1 setTag:indexPath.row * 4];
    
    if (indexPath.row * 4 + 1 < [_assetArray count]) {
        ALAsset *secondAsset = [_assetArray objectAtIndex:indexPath.row * 4 + 1];
        
        [cell.assetButton2 setImage:[UIImage imageWithCGImage:[secondAsset thumbnail]]
                           forState:UIControlStateNormal];
        [cell.assetButton2 setTag:indexPath.row * 4 + 1];
        [cell.assetButton2 setEnabled:YES];
        
    } else {
        [cell.assetButton2 setImage:nil
                           forState:UIControlStateNormal];
        cell.assetButton2.enabled = NO;
    }
    
    if (indexPath.row * 4 + 2 < [_assetArray count]) {
        ALAsset *thirdAsset = [_assetArray objectAtIndex:indexPath.row * 4 + 2];
        
        [cell.assetButton3 setImage:[UIImage imageWithCGImage:[thirdAsset thumbnail]]
                           forState:UIControlStateNormal];
        
        [cell.assetButton3 setTag:indexPath.row * 4 + 2];
        [cell.assetButton3 setEnabled:YES];
    } else {
        [cell.assetButton3 setImage:nil
                           forState:UIControlStateNormal];
        
        [cell.assetButton3 setEnabled:NO];
    }
    
    if (indexPath.row * 4 + 3 < [_assetArray count]) {
        ALAsset *fourthAsset = [_assetArray objectAtIndex:indexPath.row * 4 + 3];
        
        [cell.assetButton4 setImage:[UIImage imageWithCGImage:[fourthAsset thumbnail]]
                           forState:UIControlStateNormal];
        
        [cell.assetButton4 setTag:indexPath.row * 4 + 3];
        [cell.assetButton4 setEnabled:YES];
    } else {
        [cell.assetButton4 setImage:nil
                           forState:UIControlStateNormal];
        
        [cell.assetButton4 setEnabled:NO];
    }
    
    return cell;
}

#pragma mark - Asset Methods

- (void)retrieveAssetGroupByURL
{
    void (^retrieveGroupBlock)(ALAssetsGroup *) =
    ^(ALAssetsGroup * group)
    {
        if (group) {
            [self enumerateGroupAssetsForGroup:group];
        }
        else
        {
            NSLog(@"Error, Can't find group!");
        }
    };
    void (^handleAssetGroupErrorBlock)(NSError*) =
    ^(NSError* error)
    {
        NSString *errMsg = @"Error accessing group";
        
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:nil message:errMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    };
    
    [self.assetsLibrary groupForURL:self.assetGroupURL
                        resultBlock:retrieveGroupBlock
                       failureBlock:handleAssetGroupErrorBlock];
}

- (void) enumerateGroupAssetsForGroup:(ALAssetsGroup *)group
{
    NSInteger lastIndex = [group numberOfAssets] - 1;
    
    void (^addAsset)(ALAsset*, NSUInteger, BOOL*) =
    ^(ALAsset* result, NSUInteger index, BOOL* stop)
    {
        if (result != nil) {
            [self.assetArray addObject:result];
        }
        
        if (index == lastIndex) {
            [self.assetTableView reloadData];
        }
    };
    
    [group enumerateAssetsUsingBlock:addAsset];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
   // self.tabBarController.tabBar.hidden = NO;
    UIBarButtonItem *button = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
                               target:self
                               action:@selector(addButtonTouched)];
    self.navigationItem.rightBarButtonItem = button;
    
    self.title = _assetGroupName;
    
    NSRange camerRollLoc = [self.assetGroupName rangeOfString:@"Camera Roll"];
    if (camerRollLoc.location == NSNotFound) {
        [self.addButton setEnabled:NO];
    }
    
    ALAssetsLibrary *setupAssetsLibrary = [[ALAssetsLibrary alloc] init];
    [self setAssetsLibrary:setupAssetsLibrary];
    
    NSMutableArray *setupArray = [[NSMutableArray alloc] init];
    [self setAssetArray:setupArray];
    
    [self retrieveAssetGroupByURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"ViewAssetImage1"] ||
        [segue.identifier isEqualToString:@"ViewAssetImage2"] ||
        [segue.identifier isEqualToString:@"ViewAssetImage3"] ||
        [segue.identifier isEqualToString:@"ViewAssetImage4"])
    {
        NSInteger indexForAsset = [sender tag];
        
        ALAsset *selectedAsset = [_assetArray objectAtIndex:indexForAsset];
        
        RBDetailViewController *detailVC = segue.destinationViewController;
        
        ALAssetRepresentation *aRep = [selectedAsset defaultRepresentation];
        
        UIImage *img = [UIImage imageWithCGImage:[aRep fullScreenImage]];
        
        [detailVC setAssetImage:img];
        
    }
}


@end
