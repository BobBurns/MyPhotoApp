//
//  CDFullCollectViewController.m
//  HAP
//
//  Created by WozniBob on 8/29/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "CDFullCollectViewController.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "Photos.h"
#import "FullSize.h"
#import "Folders.h"
#import "CDFullCollectionViewCell.h"
#import "Faulter.h"
#import "CDContainerViewController.h"

@import MediaPlayer;
@import Photos;

#define debug 1

@interface CDFullCollectViewController ()

@property (nonatomic, strong) NSArray *resultsArray;
@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;
@property (nonatomic) int currentIndex;
@end

@implementation CDFullCollectViewController

#pragma mark - utility file

- (NSString *)applicationSupportDirectoryPath {
    NSString *applicationSupportPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    [[NSFileManager defaultManager]
     createDirectoryAtPath:applicationSupportPath
     withIntermediateDirectories:YES
     attributes:nil
     error:nil];
    
    return applicationSupportPath;
    
}

static NSString *reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [self.collectionView setPagingEnabled:YES];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(performFetch)
                                                 name:@"SomethingChanged"
                                               object:nil];
    [self performFetch];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [self.collectionView scrollToItemAtIndexPath:self.startIndex
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
    
    [self playMovieControllerWhenBackgroundIsTouhed];
}
- (void)viewWillAppear:(BOOL)animated {
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)performFetch {
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    NSError *error = nil;
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photos"];
    
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"photoAlbum"
                                                                                      ascending:YES],
                               [NSSortDescriptor sortDescriptorWithKey:@"date"
                                                             ascending:YES],
                               nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"photoAlbum.name = %@", self.folderName];
    [request setPredicate:predicate];
    [request setFetchBatchSize:30];
    
    [cdh.context performBlockAndWait:^{
        NSLog(@"performing block");
        NSError *fetchError = nil;
        _resultsArray = [cdh.context executeFetchRequest:request error:&fetchError];
        
        if (!_resultsArray) {
            NSLog(@"Error = %@", error);
        } else {
            NSLog(@"got object array");
            
            
        }
    }];
    
    
    
    [self.collectionView reloadData]; // incase of any changes
    
}
#pragma mark - collection view delegate


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _resultsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    CDFullCollectionViewCell *myCell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    Photos *photoObject = [self.resultsArray objectAtIndex:indexPath.row];
    
    if (photoObject.isVideo.boolValue) {
        myCell.fullImageView.image = [UIImage imageWithData:photoObject.thumb];
        myCell.playView.hidden = NO;
        return myCell;
    }
    //UIImage *groupImage = [UIImage imageWithData:photoObject.photo];
    UIImage *fullsize = [UIImage imageWithData:photoObject.full.fullsizeImage];
    
    myCell.fullImageView.image = fullsize;
    // try to increase fps
    myCell.layer.shouldRasterize = YES;
    myCell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [self.collectionView addGestureRecognizer:myCell.scrollView.pinchGestureRecognizer];
    [self.collectionView addGestureRecognizer:myCell.scrollView.panGestureRecognizer];
    
    // try and save memory with faulting
    [Faulter faultObjectWithID:photoObject.objectID inContext:cdh.context];
    
    //release the image pointer
    myCell.playView.hidden = YES;
    return myCell;
}
- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(CDFullCollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get the cell instance and ...
    [self.collectionView removeGestureRecognizer:cell.scrollView.pinchGestureRecognizer];
    [self.collectionView removeGestureRecognizer:cell.scrollView.panGestureRecognizer];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.collectionView.frame.size;
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.collectionView setAlpha:0.0f];
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    CGPoint currentOffset = [self.collectionView contentOffset];
    self.currentIndex = currentOffset.x / self.collectionView.frame.size.width;
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // Force realignment of cell being displayed
    if (self.moviePlayer) {
        self.moviePlayer.view.frame = self.collectionView.frame;
        return;
    }
    CGSize currentSize = self.collectionView.bounds.size;
    float offset = self.currentIndex * currentSize.width;
    [self.collectionView setContentOffset:CGPointMake(offset, 0)];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    [UIView animateWithDuration:0.125f animations:^{
        [self.collectionView setAlpha:1.0f];
    }];
}


#pragma mark - interaction

- (void)playMovieControllerWhenBackgroundIsTouhed {
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playMovie)];
    [tgr setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tgr];
    
}


- (void)playMovie {
    NSUInteger movieIndex = [[[self.collectionView indexPathsForVisibleItems] lastObject] row];
    Photos *movie = [self.resultsArray objectAtIndex:movieIndex];
    if (!movie.isVideo) return;
    
    // get path
    NSString *path = [[self applicationSupportDirectoryPath] stringByAppendingPathComponent:movie.fileName];
    NSURL *movieURL = [NSURL fileURLWithPath:path];
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    self.moviePlayer = player;
    self.moviePlayer.shouldAutoplay = YES;
    [self.moviePlayer prepareToPlay];
    self.moviePlayer.view.frame = self.collectionView.frame;
    self.moviePlayer.backgroundView.backgroundColor = [UIColor whiteColor];
    //[self.view addSubview:self.moviePlayer.view];
    
    __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note)
                           {
                               if (self.moviePlayer.readyForDisplay) {
                                   [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                   [self.view addSubview:self.moviePlayer.view];
                               }
                           }];
    
}
#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"showContainer"]) {
        Photos *showURl = [self.resultsArray objectAtIndex:[[self.collectionView indexPathForCell:sender] row]];
        if (showURl.isVideo) {
            return NO;
        }
    }
    return NO;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    Photos *showURl = [self.resultsArray objectAtIndex:[[self.collectionView indexPathForCell:sender] row]];
    if ([segue.identifier isEqualToString:@"showContainer"] && showURl.isVideo) {
        
        NSString *path = [[self applicationSupportDirectoryPath] stringByAppendingPathComponent:showURl.fileName];
        CDContainerViewController *containerVC = segue.destinationViewController;
        containerVC.videoURL = [NSURL fileURLWithPath:path];
        
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    if (alertView.tag == 3001) {
        if (buttonIndex == 1) {
            [self deletePhoto];
            
        } else {
            NSLog(@"Cancled Delete");
        }
    } else if (alertView.tag == 3002) {
        if (buttonIndex == 1) {
            [self exportPhoto];
        } else {
            NSLog(@"Canceled Export");
        }
    }
}

- (void)deletePhoto {
    
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    NSUInteger movieIndex = [[[self.collectionView indexPathsForVisibleItems] lastObject] row];
    Photos *photoToDelete = [self.resultsArray objectAtIndex:movieIndex];
    
    NSError *error;
    
    NSLog(@"remove item error: %@", error);
    if ([photoToDelete.isVideo boolValue]) {
        NSError *error;
        NSString *path = [[self applicationSupportDirectoryPath] stringByAppendingPathComponent:photoToDelete.fileName];
        NSURL *URLtoDelete = [NSURL fileURLWithPath:path];
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtURL:URLtoDelete error:&error];
        if (error) {
            NSLog(@"error deleting video: %@ '%@'", error, error.description);
        }
    }
    [cdh.context deleteObject:photoToDelete];
    [cdh backgroundSaveContext];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged"
                                                        object:nil];
    NSLog(@"Photo Deleted");
    [[self navigationController] popViewControllerAnimated:YES];
}
- (void)exportPhoto {
    NSUInteger movieIndex = [[[self.collectionView indexPathsForVisibleItems] lastObject] row];
    Photos *photoToExport = [self.resultsArray objectAtIndex:movieIndex];
    __block BOOL exportVideo = photoToExport.isVideo.boolValue;
    NSString *path = [[self applicationSupportDirectoryPath] stringByAppendingPathComponent:photoToExport.fileName];
    __block NSURL *videoURL = [NSURL fileURLWithPath:path];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetChangeRequest = nil;
        
        if (exportVideo) {
            assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
        } else {
            assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:[UIImage imageWithData:photoToExport.full.fullsizeImage]];
        }
        PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:nil];
        
        [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
    } completionHandler:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Error creating asset: %@", error);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Export Successful" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alert show];
                
                // [[self navigationController] popViewControllerAnimated:YES];
            });
        }
    }];
}

- (IBAction)handleDelete:(id)sender {
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    
    UIAlertView * deleteAlertView = [[UIAlertView alloc] initWithTitle:@"Delete Photo?"
                                                      message:@"Are you sure you want to delete this photo?"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Delete", nil];
    deleteAlertView.tag = 3001;
    [deleteAlertView show];
}

- (IBAction)handleExport:(id)sender {
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    
    UIAlertView *exportAlertView = [[UIAlertView alloc] initWithTitle:@"Export Photo?"
                                                               message:@"Are you sure you want to export this photo?"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Export", nil];
    exportAlertView.tag = 3002;
    [exportAlertView show];
}
@end
