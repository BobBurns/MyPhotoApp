//
//  SelectPhotoViewController.m
//  NewPhotoAPI
//
//  Created by WozniBob on 8/12/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "SelectPhotoViewController.h"
#import "GridCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>


#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "Folders.h"
#import "Photos.h"
#import "FullSize.h"

#import "Faulter.h"

#define debug 1
#define kMaxSelections 5
#define proVersion 1

@import Photos;
@import CoreLocation;


@implementation NSIndexSet (Convenience)
- (NSArray *)aapl_indexPathsFromIndexesWithSection:(NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}
@end


@implementation UICollectionView (Convenience)
- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}
@end

@implementation CIImage (Convenience)

- (NSData *)aapl_jpegRepresentationWithCompressionQuality:(CGFloat)compressionQuality {
    static CIContext *ciContext = nil;
    if (!ciContext) {
        EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        ciContext = [CIContext contextWithEAGLContext:eaglContext];
    }
    CGImageRef outputImageRef = [ciContext createCGImage:self fromRect:[self extent]];
    UIImage *uiImage = [[UIImage alloc] initWithCGImage:outputImageRef scale:1.0 orientation:UIImageOrientationUp];
    if (outputImageRef) {
        CGImageRelease(outputImageRef);
    }
    NSData *jpegRepresentation = UIImageJPEGRepresentation(uiImage, compressionQuality);
    return jpegRepresentation;
}

@end


@interface SelectPhotoViewController () <PHPhotoLibraryChangeObserver>
@property (strong) IBOutlet UIBarButtonItem *addButton;
@property (strong) PHCachingImageManager *imageManager;
@property CGRect previousPreheatRect;

@property (nonatomic, strong) Folders *currentFolder;
@property (nonatomic, strong) NSMutableArray *importedPhotos;
@property BOOL allowImport;

@end


@implementation SelectPhotoViewController


static NSString * const CellReuseIdentifier = @"Cell";
static CGSize AssetGridThumbnailSize;

#pragma mark - views

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)awakeFromNib
{
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    self.imageManager = [[PHCachingImageManager alloc] init];
    [self resetCachedAssets];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    _allowImport = YES;
    
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    self.imageManager = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    [super viewWillAppear:animated];
    
   // UIBarButtonItem *importButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(moveItems)];
    UIBarButtonItem *import = [[UIBarButtonItem alloc] initWithTitle:@"Import" style:UIBarButtonItemStylePlain target:self action:@selector(moveItems)];
    self.navigationItem.rightBarButtonItem = import;
    
    // get default folder
    NSError *error = nil;
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Folders"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSString *folderRequest = self.selectFolderName;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", folderRequest];
    [request setPredicate:predicate];
    NSArray *results = [cdh.context executeFetchRequest:request error:&error];
    
    if ([results count] == 0) {
        NSLog(@"Error fetching folders: %@ '%@'", error, error.description);
        //self.currentFolder = [NSEntityDescription insertNewObjectForEntityForName:@"Folders" inManagedObjectContext:cdh.context];
       // _currentFolder.name = self.selectFolderName;
       // [cdh backgroundSaveContext];
        
    } else {
        _currentFolder = [results lastObject];
        
    }
    
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
    [self.collectionView setAllowsMultipleSelection:YES];
    
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateCachedAssets];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    for (NSIndexPath *index in self.collectionView.indexPathsForSelectedItems) {
        [self.collectionView deselectItemAtIndexPath:index animated:NO];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*
     NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
     AAPLAssetViewController *assetViewController = segue.destinationViewController;
     assetViewController.asset = self.assetsFetchResults[indexPath.item];
     assetViewController.assetCollection = self.assetCollection;
     */
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // check if there are changes to the assets (insertions, deletions, updates)
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
        if (collectionChanges) {
            
            // get the new fetch result
            self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
            
            UICollectionView *collectionView = self.collectionView;
            
            if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
                // we need to reload all if the incremental diffs are not available
                [collectionView reloadData];
                
            } else {
                // if we have incremental diffs, tell the collection view to animate insertions and deletions
                [collectionView performBatchUpdates:^{
                    NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                    if ([removedIndexes count]) {
                        [collectionView deleteItemsAtIndexPaths:[removedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                    NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                    if ([insertedIndexes count]) {
                        [collectionView insertItemsAtIndexPaths:[insertedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                    NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                    if ([changedIndexes count]) {
                        [collectionView reloadItemsAtIndexPaths:[changedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                } completion:NULL];
            }
            
            [self resetCachedAssets];
        }
    });
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.assetsFetchResults.count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GridCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
    
    // Increment the cell's tag
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;
    
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    [self.imageManager requestImageForAsset:asset
                                 targetSize:AssetGridThumbnailSize
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  
                                  // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                  if (cell.tag == currentTag) {
                                      cell.thumbnailImage = result;
                                  }
                                  
                              }];
    cell.isChecked = NO;
    for (NSIndexPath *index in _importedPhotos) {
        if (indexPath.row == index.row) {
            cell.isChecked = YES;
        }
    }
    
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.navigationItem.title = [NSString stringWithFormat:@"%lu items", (unsigned long)self.collectionView.indexPathsForSelectedItems.count];
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Item selected at indexPath: %@",indexPath);
    NSUInteger selectCount = _collectionView.indexPathsForSelectedItems.count;
    
    if (selectCount > kMaxSelections) {
        [self allowMultipleImport];
        [_collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
    self.navigationItem.title = [NSString stringWithFormat:@"%lu items", (unsigned long)self.collectionView.indexPathsForSelectedItems.count];

}

#pragma mark - Asset Caching

- (void)resetCachedAssets
{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets
{
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:AssetGridThumbnailSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:AssetGridThumbnailSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.assetsFetchResults[indexPath.item];
        [assets addObject:asset];
    }
    return assets;
}

#pragma mark - Actions

- (IBAction)handleAddButtonItem:(id)sender
{
   
}

- (IBAction)actionButtonClicked:(id)sender {
   
}

- (NSString *)applicationSupportDirectoryPath {
    NSString *applicationSupportPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    [[NSFileManager defaultManager]
     createDirectoryAtPath:applicationSupportPath
     withIntermediateDirectories:YES
     attributes:nil
     error:nil];
    
    return applicationSupportPath;
    
}

- (void)moveItems {
    NSMutableArray *assets = [[NSMutableArray alloc] initWithArray:[self assetsAtIndexPaths:self.collectionView.indexPathsForSelectedItems]];
    
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    
    for (PHAsset *asset in assets) {
        
        BOOL isVideo = NO;
        Photos *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:cdh.context];
        FullSize *fullsize = [NSEntityDescription insertNewObjectForEntityForName:@"FullSize" inManagedObjectContext:cdh.context];
        
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"purchasedPro"] == NO) {
                NSLog(@"Asset is video");
                [self allowVideoImport];
                return;
            } else {
                // first get thumbnail
                CGSize size = CGSizeMake(80.0, 80.0);
                [self.imageManager requestImageForAsset:asset
                                             targetSize:size
                                            contentMode:PHImageContentModeAspectFill
                                                options:nil
                                          resultHandler:^(UIImage *result, NSDictionary *info) {
                                              
                                              newPhoto.thumb = UIImageJPEGRepresentation(result, 1);
                                          }];
                
                // import video
                //__block NSData *imageData;
                isVideo = YES;
                CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
                CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuid);
                NSString *filename = [NSString stringWithFormat:@"%@.mov", uuidString];
                __block NSString *path = [[self applicationSupportDirectoryPath] stringByAppendingPathComponent:filename];
                CFRelease(uuid);
                CFRelease(uuidString);
                newPhoto.fileName = filename;
                newPhoto.isVideo = [NSNumber numberWithBool:YES];
                
                //write image to file
                
                
                //remove the previous file, if any
                if (newPhoto.fileName != nil) {
                    NSString *previousPath = [[self applicationSupportDirectoryPath] stringByAppendingPathComponent:newPhoto.fileName];
                    [[NSFileManager defaultManager] removeItemAtPath:previousPath error:nil];
                }
                [self.imageManager requestExportSessionForVideo:asset
                                                        options:nil
                                                   exportPreset:AVAssetExportPresetLowQuality
                 
                                                  resultHandler:^(AVAssetExportSession *session, NSDictionary *info){
                                                  // handle export session here
                                                      NSURL *vidPath = [NSURL fileURLWithPath:path];
                                                      session.outputURL = vidPath;
                                                      session.outputFileType = AVFileTypeQuickTimeMovie;
                                                      [session exportAsynchronouslyWithCompletionHandler:^(void) {
                                                          if (AVAssetExportSessionStatusCompleted == session.status)
                                                          {
                                                              NSLog(@"done writing video!");
                                                          }
                                                      }];
                                                  }];
            }
        
            
        } else {
            CGSize size = CGSizeMake(400.0, 400.0);
            
            /*
             __block NSData *imageData;
             CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
             CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuid);
             NSString *filename = [NSString stringWithFormat:@"%@.jpeg", uuidString];
             __block NSString *path = [[self applicationSupportDirectoryPath] stringByAppendingPathComponent:filename];
             CFRelease(uuid);
             CFRelease(uuidString);
             newPhoto.fileName = filename;
             
             //write image to file
             
             
             //remove the previous file, if any
             if (newPhoto.fileName != nil) {
             NSString *previousPath = [[self applicationSupportDirectoryPath] stringByAppendingPathComponent:newPhoto.fileName];
             [[NSFileManager defaultManager] removeItemAtPath:previousPath error:nil];
             }
             */
            //PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            //options.resizeMode = PHImageRequestOptionsResizeModeNone;
            
            //self.imageManager.allowsCachingHighQualityImages = YES;
            
            [self.imageManager requestImageForAsset:asset
                                         targetSize:size
                                        contentMode:PHImageContentModeAspectFill
                                            options:nil
                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                                          
                                          
                                          // imageData = UIImageJPEGRepresentation(result, 1);
                                          //newPhoto.photo =  UIImageJPEGRepresentation(result, .9);
                                          
                                          // [imageData writeToFile:path atomically:YES];
                                          // imageData = nil;
                                          fullsize.fullsizeImage = UIImageJPEGRepresentation(result, .9);
                                          
                                          CGSize size = CGSizeMake(80.0, 80.0);
                                          UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
                                          [result drawInRect:CGRectMake(0, 0, size.width, size.height)];
                                          UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
                                          UIGraphicsEndImageContext();
                                          result = nil;
                                          
                                          newPhoto.thumb = UIImageJPEGRepresentation(thumbnail, 1);
                                          // save filename in the photo object
                                          
                                          
                                      }];
            
            
            newPhoto.full = fullsize;
            newPhoto.date = [NSDate date];
            [Faulter faultObjectWithID:fullsize.objectID inContext:cdh.context];
            [Faulter faultObjectWithID:newPhoto.full.objectID inContext:cdh.context];
        }
        
        [_currentFolder addImagesObject:newPhoto];
        [Faulter faultObjectWithID:newPhoto.objectID inContext:cdh.context];
        
    }
    
    self.imageManager = nil;
    [cdh backgroundSaveContext];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged"
                                                        object:nil];
    
    _importedPhotos = [[NSMutableArray alloc] initWithArray:self.collectionView.indexPathsForSelectedItems];
    
    for (NSIndexPath *ip in _collectionView.indexPathsForSelectedItems) {
        [_collectionView deselectItemAtIndexPath:ip animated:NO];
    }
   // [self updateCachedAssets];
    //[_collectionView reloadData];
    self.navigationItem.title = [NSString stringWithFormat:@"%lu items", (unsigned long)self.collectionView.indexPathsForSelectedItems.count];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}


- (IBAction)makePhotoHidden:(id)sender {
    
}

#pragma mark - alert views

- (void)allowMultipleImport {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Too many imports"
                                                    message:@"Unlock this feature for $1 USD"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Unlock", @"Restore", nil];
    alert.tag = 1002;
    [alert show];
}
- (void)allowVideoImport {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video not supported"
                                                    message:@"Unlock this feature for $1 USD"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Unlock", @"Restore", nil];
    alert.tag = 1003;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1002 || alertView.tag == 1003) {
        if (buttonIndex == 1) {
            /* not set up in itunes
             
            if (![SKPaymentQueue canMakePayments]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't purchase!" message:@"You don't have purchacing privaliges" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alert show];
                return;
            }
            SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"proID"]];
            request.delegate = self;
            [request start];
             */
            
            NSURL *url = [NSURL URLWithString:@"http://www.chefspecialapp.com"];
            
            if (![[UIApplication sharedApplication] openURL:url]) {
                NSLog(@"%@%@",@"Failed to open url:",[url description]);
            }
            
        }
        if (buttonIndex == 2) {
            // not set up
            // [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
            NSLog(@"Restore button pressed");
        }
    }
}

#pragma mark - store kit delegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    SKProduct *product = response.products[0];
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    SKPaymentQueue *paymentQueue = [SKPaymentQueue defaultQueue];
    [paymentQueue addPayment:payment];
}
@end
