//
//  FetchGroupCollectionVC.m
//  MyPhotoLibrary
//
//  Created by WozniBob on 8/14/14.
//  Copyright (c) 2014 Bob_Burns. All rights reserved.
//

#import "FetchGroupCollectionVC.h"
#import "CDDetailViewController.h"
#import "LibraryRootViewController.h"

#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "Folders.h"
#import "Photos.h"
#import "FullSize.h"

#import "Faulter.h"
#import "CDMainVC.h"

#import "CDGroupCell.h"

#define debug 1

@interface FetchGroupCollectionVC ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (nonatomic, strong) NSManagedObjectID *selectedPhotoID;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@end

@implementation FetchGroupCollectionVC

#pragma mark - paths

- (NSString *)applicationSupportDirectoryPath {
    NSString *applicationSupportPath = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    [[NSFileManager defaultManager]
     createDirectoryAtPath:applicationSupportPath
     withIntermediateDirectories:YES
     attributes:nil
     error:nil];
    
    return applicationSupportPath;
    
}

static NSString * const reuseIdentifier = @"Cell";



- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)viewDidLoad {
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[CDGroupCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(performFetch)
                                                 name:@"SomethingChanged"
                                               object:nil];
    self.collectionView.allowsMultipleSelection = NO;
    
    [self performFetch];
    
    
}
- (void)viewDidAppear:(BOOL)animated {
    
    self.navigationItem.title = _folderName;
    if (!_resultArray) {
                
        [self performFetch];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
   //[self faultObjects];
   // _resultArray = nil;
    NSLog(@"view will disapear");
}
- (void)dealloc {
    _resultArray = nil;
}

- (void)performFetch {
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    NSError *error = nil;
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    /*
    NSFetchRequest *folderRequest = [NSFetchRequest fetchRequestWithEntityName:@"Folders"];
    folderRequest.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                            ascending:YES],
                                     nil];
    
    NSPredicate *folderPredicate = [NSPredicate predicateWithFormat:@"name == 'defaultFolder'"];
    [folderRequest setPredicate:folderPredicate];
    self.navigationItem.title = @"Photos";
    
    NSArray *folderFetch = [cdh.context executeFetchRequest:folderRequest error:&error];
    if (!folderFetch) {
        NSLog(@"Error fetching defaultFolder %@ '%@'", error, error.description);
    }
    NSLog(@"folder count: %lu", (unsigned long)[folderFetch count]);
    */
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photos"];
    
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"photoAlbum"
                                                                                      ascending:YES],
                               [NSSortDescriptor sortDescriptorWithKey:@"date"
                                                             ascending:YES],
                               nil];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"photoAlbum.name = %@", self.folderName];
    [request setPredicate:predicate];
    [request setFetchBatchSize:30];
    /*
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                   managedObjectContext:cdh.context
                                                     sectionNameKeyPath:nil
                                                              cacheName:nil];
    NSLog(@" fetched objects = %lu", (unsigned long)self.frc.fetchedObjects.count);
    self.frc.delegate = (id)self;
    
    if (self.frc) {
        [self.frc.managedObjectContext performBlockAndWait:^{
            NSError *error = nil;
            if (![self.frc performFetch:&error]) {
                NSLog(@"Failed to perform fetch: %@", [error localizedDescription]);
            }
            [self.collectionView reloadData];
        }];
    } else {
        NSLog(@"Failed to fetch, the fetched results controller is nil.");
    }
    */
    
    [cdh.context performBlockAndWait:^{
        /*
        NSLog(@"get main queue");
        UIView *overlay = [[UIView alloc] init];
        overlay = self.view;
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.layer.cornerRadius = 10;
        CGRect f = _indicatorView.frame;
        f = CGRectInset(f, -10, -10);
        _indicatorView.frame = f;
        
        CGRect cf = self.view.frame;
        cf = [self.view convertRect:cf fromView:self.view];
        _indicatorView.center = CGPointMake(CGRectGetMidX(cf), CGRectGetMidY(cf));
        _indicatorView.tag = 1001;
        [overlay addSubview:_indicatorView];
        [_indicatorView startAnimating];
        */
        NSLog(@"performing block");
        NSError *fetchError = nil;
        _resultArray = [cdh.context executeFetchRequest:request error:&fetchError];
        
        if (!_resultArray) {
            NSLog(@"Error = %@", error);
        } else {
            NSLog(@"got object array");
            
            
        }
    }];
    
    
    
    [self.collectionView reloadData]; // incase of any changes
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }

    

    if ([segue.identifier isEqualToString:@"showPhoto"]) {
        //CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
        
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        Photos *selPhoto = [_resultArray objectAtIndex:indexPath.row];
        
        CDDetailViewController *detailVC = segue.destinationViewController;
        //[self.collectionView reloadData];
        
        NSData *fulldata = selPhoto.full.fullsizeImage;
        detailVC.displayPhoto = [UIImage imageWithData:fulldata];
        detailVC.photoID = selPhoto.objectID;
        detailVC.displayPhotoFilename = selPhoto.fileName;
        detailVC.displayDate = selPhoto.date;
        
        //[Faulter faultObjectWithID:selPhoto.full.objectID inContext:cdh.context];
        
        //_resultArray = nil;
    } else if ([segue.identifier isEqualToString:@"importSegue"]) {
        
        LibraryRootViewController *lVC = [segue destinationViewController];
        NSString *folderName = self.folderName;
        [lVC setLibraryFolderName:folderName];
        
    } else if ([segue.identifier isEqualToString:@"newDetail"]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        Photos *selPhoto = [_resultArray objectAtIndex:indexPath.row];
        NSLog(@"%d", [selPhoto.isVideo boolValue]);
        CDDetailViewController *detailVC = segue.destinationViewController;
        
        if ([selPhoto.isVideo boolValue]) {
            NSString *path = [[self applicationSupportDirectoryPath] stringByAppendingPathComponent:selPhoto.fileName];
            detailVC.videoContainerView.hidden = NO;
            detailVC.isVideo = YES;
            detailVC.videoURL = [NSURL fileURLWithPath:path];
            
            detailVC.photoID = selPhoto.objectID;
            
        } else {
            NSData *fulldata = selPhoto.full.fullsizeImage;
            detailVC.displayPhoto = [UIImage imageWithData:fulldata];
            detailVC.photoID = selPhoto.objectID;
            detailVC.displayPhotoFilename = selPhoto.fileName;
            detailVC.displayDate = selPhoto.date;
            detailVC.videoContainerView.hidden = YES;
        }
    }
}



#pragma mark <UICollectionViewDataSource>



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return _resultArray.count;
    //NSInteger objects = [[self.frc fetchedObjects] count];
    //return objects;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Configure the cell
    if (debug == 1) {
        NSLog(@"running %@ '%@'", self.class , NSStringFromSelector(_cmd));
    }
    CDGroupCell *myCell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
    //Photos *photoObject = [self.frc.fetchedObjects objectAtIndex:indexPath.row];
    
    Photos *photoObject = [self.resultArray objectAtIndex:indexPath.row];
    //UIImage *groupImage = [UIImage imageWithData:photoObject.photo];
    UIImage *thumbImage = [UIImage imageWithData:photoObject.thumb];
    
    myCell.thumbnailImage = thumbImage;
    // try to increase fps
    myCell.layer.shouldRasterize = YES;
    myCell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // try and save memory with faulting
    [Faulter faultObjectWithID:photoObject.objectID inContext:cdh.context];
    
    //release the image pointer
    thumbImage = nil;
    
    return myCell;
}
- (UIImage *)createThumbnail:(UIImage *)inPhoto {
    CGSize size = CGSizeMake(80.0, 80.0);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [inPhoto drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumbnail;
}

#pragma mark <UICollectionViewDelegate>



#pragma mark - fault objects

- (void)faultObjects {
    
    CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];

    for (Photos *photo in self.resultArray) {
        [Faulter faultObjectWithID:photo.objectID inContext:cdh.context];
    }
}



@end
