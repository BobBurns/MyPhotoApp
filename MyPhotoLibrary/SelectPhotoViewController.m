//
//  SelectPhotoViewController.m
//  NewPhotoAPI
//
//  Created by WozniBob on 8/12/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "SelectPhotoViewController.h"
#import "GridCollectionViewCell.h"

#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "Folders.h"
#import "Photos.h"
#import "FullSize.h"

#import "Faulter.h"

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
@end


@implementation SelectPhotoViewController


static NSString * const CellReuseIdentifier = @"Cell";
static CGSize AssetGridThumbnailSize;

- (void)awakeFromNib
{
    self.imageManager = [[PHCachingImageManager alloc] init];
    [self resetCachedAssets];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // get default folder
    NSError *error = nil;
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Folders"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == 'defaultFolder'"];
    [request setPredicate:predicate];
    NSArray *results = [cdh.context executeFetchRequest:request error:&error];
    
    if ([results count] == 0) {
        NSLog(@"Error fetching folders: %@ '%@'", error, error.description);
        NSLog(@"inserting defaultFolder");
        _currentFolder = [NSEntityDescription insertNewObjectForEntityForName:@"Folders"
                                                       inManagedObjectContext:cdh.context];
        
        _currentFolder.name = @"defaultFolder";
        
    } else {
        for (int i = 0; i < [results count]; ++i) {
            Folders *object = [results objectAtIndex:i];
            if ([object.name isEqualToString:@"defaultFolder"]) {
                NSLog(@"default Folder exists");
                _currentFolder = object;
                break;
            }
        }
        
    }
    
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
    [self.collectionView setAllowsMultipleSelection:YES];
    
    
    if (!self.assetCollection || [self.assetCollection canPerformEditOperation:PHCollectionEditOperationAddContent]) {
        self.navigationItem.rightBarButtonItem = self.addButton;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateCachedAssets];
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
    
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Item selected at indexPath: %@",indexPath);
    /*
     
     if (selectedCell.isChecked) {
     selectedCell.isChecked = NO;
     selectedCell.checkMarkView.hidden = YES;
     } else
     {
     selectedCell.isChecked = YES;
     selectedCell.checkMarkView.hidden = NO;
     }
     [self.collectionView reloadData];
     */
    
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
    // Create a random dummy image.
    CGRect rect = rand() % 2 == 0 ? CGRectMake(0, 0, 400, 300) : CGRectMake(0, 0, 300, 400);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0f);
    [[UIColor colorWithHue:(float)(rand() % 100) / 100 saturation:1.0 brightness:1.0 alpha:1.0] setFill];
    UIRectFillUsingBlendMode(rect, kCGBlendModeNormal);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Add it to the photo library
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
        if (self.assetCollection) {
            PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:self.assetCollection];
            [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
        }
    } completionHandler:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Error creating asset: %@", error);
        }
    }];
}

- (IBAction)actionButtonClicked:(id)sender {
    
    void (^completionHandler)(BOOL, NSError *) = ^(BOOL success, NSError *error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self navigationController] popViewControllerAnimated:YES];
            });
        } else {
            NSLog(@"Error: %@", error);
        }
    };
    
    
    NSMutableArray *assets = [[NSMutableArray alloc] initWithArray:[self assetsAtIndexPaths:self.collectionView.indexPathsForSelectedItems]];
    for (PHAsset *asset in assets) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:asset];
            if ([asset canPerformEditOperation:PHAssetEditOperationProperties]) {
                request.hidden = YES;
                NSLog(@"hiding asset");
            } else {
                NSLog(@"can't edit asset");
            }
            
        } completionHandler:completionHandler];
    }
    
    
}
- (void)moveItems {
    void (^completionHandler)(BOOL, NSError *) = ^(BOOL success, NSError *error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[self navigationController] popViewControllerAnimated:YES];
            });
        } else {
            NSLog(@"Error: %@", error);
        }
    };
    
    
    NSMutableArray *assets = [[NSMutableArray alloc] initWithArray:[self assetsAtIndexPaths:self.collectionView.indexPathsForSelectedItems]];
    for (PHAsset *asset in assets) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:asset];
            if ([asset canPerformEditOperation:PHAssetEditOperationProperties]) {
                request.hidden = YES;
                NSLog(@"hiding asset");
            } else {
                NSLog(@"can't edit asset");
            }
            
        } completionHandler:completionHandler];
    }
}

- (IBAction)makePhotoHidden:(id)sender {
    void (^completionHandler)(BOOL, NSError *) = ^(BOOL success, NSError *error) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"dismiss view here");
                //[[self navigationController] popViewControllerAnimated:YES];
                
            });
        } else {
            NSLog(@"Error: %@", error);
        }
    };
    
    //get default folder
    
    
    NSMutableArray *assets = [[NSMutableArray alloc] initWithArray:[self assetsAtIndexPaths:self.collectionView.indexPathsForSelectedItems]];
    
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    
    for (PHAsset *asset in assets) {
        Photos *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photos" inManagedObjectContext:cdh.context];
        FullSize *fullsize = [NSEntityDescription insertNewObjectForEntityForName:@"FullSize" inManagedObjectContext:cdh.context];
        
        CGSize size = CGSizeMake(200.0, 200.0);
        
        [self.imageManager requestImageForAsset:asset
                                     targetSize:size
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      
                                      fullsize.fullsizeImage = UIImageJPEGRepresentation(result, .8);
                                      //newPhoto.photo =  UIImageJPEGRepresentation(result, .9);
                                      
                                      CGSize size = CGSizeMake(60.0, 60.0);
                                      UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
                                      [result drawInRect:CGRectMake(0, 0, size.width, size.height)];
                                      UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
                                      UIGraphicsEndImageContext();
                                       
                                    
                                      newPhoto.thumb = UIImageJPEGRepresentation(thumbnail, 1);
                                      
                                  }];
        
    
        newPhoto.date = [NSDate date];
        //newPhoto.name = asset.location.description;
        
        newPhoto.full = fullsize;
        
        [_currentFolder addImagesObject:newPhoto];
        
        /*
        size = CGSizeMake(200.0, 200.0);
        
        [self.imageManager requestImageForAsset:asset
                                     targetSize:size
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      
                                      //newPhoto.photo =  UIImageJPEGRepresentation(result, .9);
         
                                       CGSize size = CGSizeMake(80.0, 80.0);
                                       UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
                                       [result drawInRect:CGRectMake(0, 0, size.width, size.height)];
                                       UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
                                       UIGraphicsEndImageContext();
                                       
         
                                      newPhoto.full.fullsizeImage = UIImageJPEGRepresentation(result, .9);
                                      
                                  }];
    */
        [cdh backgroundSaveContext];
        [Faulter faultObjectWithID:newPhoto.full.objectID inContext:cdh.context];
        [Faulter faultObjectWithID:newPhoto.objectID inContext:cdh.context];
        
        /*
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            //PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:asset];
            if ([asset canPerformEditOperation:PHAssetEditOperationDelete]) {
                
                [PHAssetChangeRequest deleteAssets:@[asset]];
                NSLog(@"deleting asset");
            } else {
                NSLog(@"can't edit asset");
            }
            
            
        } completionHandler:completionHandler];
         */
    }
    
   // [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged"
      //                                                  object:nil];
}

@end
